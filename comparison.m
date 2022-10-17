function [Diff,CC] = comparison(Clim1,Clim2,auto,Clim1Label,Clim2Label,month_label)

%Creates difference maps and histograms of two inputted climatologies or data sets
%auto determines what plotting to use
% use auto = data for dispersed points
% use auto = clim for full gridded data

%Removes rounding errors from position data before matching
Clim1.lat = round(Clim1.lat,8);
Clim1.lon = round(Clim1.lon,8);
Clim2.lat = round(Clim2.lat,8);
Clim2.lon = round(Clim2.lon,8);
%Creates position index to reshape file later
if auto == 'clim'
index = reshape(1:130321,[361, 361]);
Clim1.inx=(1:130321)';
Clim2.idx=(1:130321)';
end

%Creates a table consisting of only co-located points
t= innerjoin(Clim1,Clim2,'Keys',{'lat','lon'});

%Calculates the Difference and Correlation Coefficient between co-located points
dif = t.SD_Clim1-t.SD_Clim2;
CC = nansum((t.SD_Clim1-nanmean(t.SD_Clim1)).*(t.SD_Clim2-nanmean(t.SD_Clim2)))./sqrt(nansum((t.SD_Clim1-nanmean(t.SD_Clim1)).^2)*nansum((t.SD_Clim2-nanmean(t.SD_Clim2)).^2)); 

%Creates normalized histogram for all co-located points
figure()
h1=histogram(t.SD_Clim1,'Normalization','pdf');
hold on
h2=histogram(t.SD_Clim2,'Normalization','pdf');
h1.BinWidth=1;
h2.BinWidth=1;
h1.BinEdges=h1.BinEdges-0.5;
h2.BinEdges=h2.BinEdges-0.5;
xl1=xline(median(t.SD_Clim1,'omitnan'),'-b');
xl2=xline(median(t.SD_Clim2,'omitnan'),'-r');
xl1.LineWidth = 2;
xl2.LineWidth = 2;
xlabel('Snow Depth [cm]')
ylabel('Normalized Measurement Count [%]')
legend(Clim1Label,Clim2Label,[Clim1Label,' Median'],[Clim2Label,' Median'])

%Creates CAA Area index
EPSG6931=projcrs(6931);
Aoilat = [68; 82; 60; 72];
Aoilon = [-132; -50; -100; -50];
[Aoix,Aoiy]=projfwd(EPSG6931,Aoilat,Aoilon);
b=boundary(Aoix,Aoiy);
[climx,climy]=projfwd(EPSG6931,t.lat,t.lon);
area = inpolygon(climx,climy,Aoix(b),Aoiy(b));

%Creates normalized histogram for all co-located points for CAA
figure()
h1=histogram(t.SD_Clim1(area),'Normalization','pdf');
hold on
h2=histogram(t.SD_Clim2(area),'Normalization','pdf');
h1.BinWidth=1;
h2.BinWidth=1;
h1.BinEdges=h1.BinEdges-0.5;
h2.BinEdges=h2.BinEdges-0.5;
xl1=xline(median(t.SD_Clim1(area),'omitnan'),'-b');
xl2=xline(median(t.SD_Clim2(area),'omitnan'),'-r');
xl1.LineWidth = 2;
xl2.LineWidth = 2;
xlabel('Snow Depth [cm]')
ylabel('Normalized Measurement Count [%]')
legend(Clim1Label,Clim2Label,[Clim1Label,' Median'],[Clim2Label,' Median'])

%Recreates 361 by 361 matrix for ploting with surfm
lat = NaN([361 361]);
lon = NaN([361 361]);
val = NaN([361 361]);

if auto =='clim'
lat(t.inx) = t.lat;
lon(t.inx) = t.lon;
val(t.inx) = dif;
end 

%Plots Difference values for the two data sets use scatter plot for
%comparison of dispersed points and use surfm for full grid data


plot_c
if auto == 'data'
scatterm(t.lat,t.lon,12,dif,'s','filled')
elseif auto == 'clim'
surfm(lat,lon,val)
else
    error('Unrecognized value for auto use "data" for dispersed points of "clim" full gridded data')
end

c = colorbar;
c.Label.String = 'Snow Depth Anomaly [cm]';
load coastlines
colormap(redblue)
setm(gca,'MLabelLocation',15)
setm(gca,'PLabelLocation',10)
title([Clim1Label,' - ',Clim2Label])
caxis([-max(abs(caxis)) max(abs(caxis))])





plot_canada
if auto == 'data'
    scatterm(t.lat,t.lon,3,dif,'s','filled')
elseif auto == 'clim'
    surfm(lat,lon,val)
else
    error('Unrecognized value for auto use "data" for dispersed points of "clim" full gridded data')
end
c = colorbar;
c.Label.String = 'Snow Depth Anomaly [cm]';
colormap(redblue)
setm(gca,'MLabelLocation',15)
caxis([-max(abs(caxis)) max(abs(caxis))])





%Creates table of diffrence values
 Diff = table(t.lat,t.lon,dif);
 Diff = renamevars(Diff,["Var1","Var2","Var3"],["lat","lon","dif"]);
 Diff(isnan(Diff.dif),:)=[];

end