function [krig] = krig(Data,Arctic_places, year_range,Lat,Lon,months,ice_Conc,Type1, Add_string)
small_font=10;
med_font  =15;
large_font=20;

% Creates Kriging Interpolations


%Stores size of original matrix and creates vectors for lat and lon
size_p=size(Lat);
lat = Lat(:);
lon = Lon(:);

%creates projection
EPSG6931=projcrs(6931);
[x,y]= projfwd(EPSG6931,lat,lon);

unknown = [lat lon]; %Creates input for a custom distance function

%Restricts data to selected years
Rel_year = Data(Data.year >= year_range(1) & Data.year <= year_range(2),:); %removes data outside of selected years
months_Full= groupsummary(Rel_year, {'ID','Station','month'}, {'max','median','mean'}, {'IceThickness','SnowDepth'}); % Calculates mean or mean snow depth for all data of each month

%Removes Stations that do not have measurements in the selected years
Lia2 = ismember(Arctic_places.Station,months_Full.Station);
Arctic_places=Arctic_places(Lia2,:);

for i=months
  ice_c = false(size(ice_Conc(:,:,i))); ice_c(ice_Conc(:,:,i)>= 0.7) = true; %Converts Ice concentrations into a true false boolean
  bool = station_ice(Arctic_places,ice_Conc(:,:,i),lat,lon); % Runs function that find all stations that are not within 500 km of an cell with ice concentration
  Arctic_places_used=Arctic_places(bool,:); %Remoces stations that are not with 500 km of sea ice
    

  %Selects Data from selected month and creates a table with measurement and position data
  monthly = months_Full((months_Full.month == i),[1:end]); 
  monthly = innerjoin(Arctic_places_used,monthly(:,[2:end]));

    %Selectes either mean of median of station data
  if Add_string == 'mean'
  monthly_snow_depth = monthly.mean_SnowDepth;
  elseif Add_string == 'medi'
  monthly_snow_depth = monthly.median_SnowDepth;
  else
  error('mean or median("medi")')
  end
  
  %Enforces Stations have data
  Arctic_places_used = Arctic_places_used(ismember(Arctic_places_used.Station,monthly.Station),:);
  Stations = [Arctic_places_used.Lat Arctic_places_used.Lon];


%Creates Distance Matrix between each station
dis_matrix= squareform(pdist(Stations,@distfun));

%Calculates lag distances and semi variance for lag distance of 50 and lag distance of 1
[d,var_semi]=semivar(dis_matrix,monthly_snow_depth,50);
[d2,var_semi2]=semivar(dis_matrix,monthly_snow_depth,1);

%creates semivariogram models
[x_sph,x_exp,x_lin,rms_sph,rms_exp,rms_lin]=SemiModel(d,var_semi,d2,var_semi2,month_lkup(i));

%Selects semivariogram models with smallest RMSD
if      rms_sph < rms_exp & rms_sph < rms_lin
    Nugget = x_sph(1);
    sill   = x_sph(2);
    Range  = x_sph(3);
    Type2 = 'Sph';
elseif  rms_exp < rms_sph & rms_exp < rms_lin
     Nugget = x_exp(1);
     sill   = x_exp(2);
     Range  = x_exp(3);
     Type2 = 'Exp';
elseif  rms_lin < rms_sph & rms_lin < rms_exp
     Nugget = x_lin(1);
     sill   = x_lin(2);
     Range  = x_lin(3);
     Type2 = 'Lin';
else
    error('Problem in Model Selection')
end
    

%Calculate semivariance from model for each point in distance matrix
if Type2 == 'Exp'
varg = Nugget+sill*(1-exp(-1*dis_matrix/Range));
elseif Type2 == 'Sph'
varg = Nugget+sill*(1.5.*(dis_matrix./Range)-0.5.*(dis_matrix./Range).^3);
out_range = dis_matrix > Range;
varg(out_range) = Nugget+sill;
z = dis_matrix == 0;
varg(z) = 0;
elseif Type2 == 'Lin'
varg =Nugget+sill*(dis_matrix./Range);
out_range = dis_matrix > Range;
varg(out_range) = Nugget+sill;
null = dis_matrix ==0;
varg(null) = 0;
end


%Creates distane matrix from each station to each unknown point
for j = 1:length(Stations)
dis_point_a=sind((unknown(:,1)-Stations(j,1))/2).^2 + cosd(unknown(:,1)).*cosd(Stations(j,1)).*sind((unknown(:,2)-Stations(j,2))/2).^2;
dis_point(:,j) =(6371.009 *2*atan2(sqrt(dis_point_a), sqrt(1-dis_point_a)));
end

%Calculates variance from model for distance from each unknown point to each station
if Type2 == 'Exp'
varg_point =Nugget+sill*(1-exp(-1*dis_point./Range));
elseif Type2== 'Sph'
varg_point =Nugget+sill*(1.5.*(dis_point./Range)-0.5.*(dis_point./Range).^3);
out_range = dis_point > Range;
varg_point(out_range) = Nugget+sill;
elseif Type2 == 'Lin'
varg_point =Nugget+sill*(dis_point./Range);
out_range = dis_point > Range;
varg_point(out_range) = Nugget+sill;
null = dis_point ==0;
varg_point(null) = 0;
end


% Cov_point = (Nugget+sill)-varg_point;

%Creates A and B Matrix for kriging
A = [varg ones(length(varg),1);ones(length(varg),1)' 0];
B = [varg_point ones(size(dis_point,1),1)];


if Type1 == 'Ord'
w = A\B';%Calculates Ordinary Kriging
est = sum(w.*[monthly_snow_depth;0 ]);
sig_2 = sum(w.*B');

elseif Type1 == 'Uni'%Calculates Universal Kriging

A_ord   = [varg ones(length(varg),1);ones(length(varg),1)' 0]; 
A_uni_p = [Arctic_places_used.x Arctic_places_used.y Arctic_places_used.x.*Arctic_places_used.y Arctic_places_used.y.^2 Arctic_places_used.x.^2; 0 0 0 0 0];
A = [A_ord A_uni_p; A_uni_p' zeros(5)];
B = [varg_point ones(size(dis_point,1),1) x y x.*y y.^2 x.^2];
w = A\B';
est = sum(w.*[monthly_snow_depth;0 ;0;0;0;0;0]);
sig_2 = sum(w.*B');
end

%Rmoves calculations for areas that do not have ice consentration above 70%
ice_c=ice_c(:);
est(~ice_c)=NaN;
est(est<=0)=0;
SD = est';
sig_2=sig_2';
sig_2(~ice_c)=NaN;

%Creates clim table
krig=table(lat,lon,SD,sig_2);
%   writetable(krig,['C:\Users\johna\OneDrive\Desktop\CSV\Kriging_',month_lkup(i),'.csv']) 

%Reshapes Data for ploting
lat = reshape(lat,size_p);
lon = reshape(lon,size_p);
val = reshape(est,size_p);
sig_2v = reshape(sig_2,size_p);


plot_canada
surfm(lat,lon,val)
c = colorbar;
colormap(red)
c.Label.String = 'Snow Depth [cm]';
caxis
caxis([0 60])
land = readgeotable("landareas.shp");
geoshow(gca,land,"FaceColor",[0.5 0.7 0.5],"EdgeColor",[0.5 0.7 0.5])
plotm(Arctic_places_used.Lat, Arctic_places_used.Lon,'b*')
exportgraphics(gcf,['C:\Users\johna\OneDrive\Desktop\Classes\Thesis\OverleafFigs\presentaion\krig_',num2str(i),'.png']);

end
end
  