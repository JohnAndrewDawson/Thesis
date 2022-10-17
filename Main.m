clear
close all
clc

%Calls other functions creating the climetologies


%Loads and Grids data
[Data, Arctic_places,Lat_p,Lon_p,x_p,y_p,ice_Conc] = load_insitu();
[bd] = bridge();%Loads pre Gridded OBI data
[by] = Buoy();%Loads CRREL data
by_new = Grid(Lat_p,Lon_p, by);%Grids CRREL data
[as] = Assist();%Loads ASSISt data
as_new =Grid(Lat_p,Lon_p, as);%Grids ASSIST data

%Creates area index for CAA
EPSG6931=projcrs(6931);
Aoilat = [68; 82; 60; 72];
Aoilon = [-132; -50; -100; -50];
[Aoix,Aoiy]=projfwd(EPSG6931,Aoilat,Aoilon);
b=boundary(Aoix,Aoiy);
area = inpolygon(x_p,y_p,Aoix(b),Aoiy(b));

% Creates Area index for coming interpolation with previous data
EPSG6931=projcrs(6931);
Aoilat = [68; 82; 68; 90];
Aoilon = [-132; -50; -155; -50];
[Aoix,Aoiy]=projfwd(EPSG6931,Aoilat,Aoilon);
b=boundary(Aoix,Aoiy);
area_AO = inpolygon(x_p,y_p,Aoix(b),Aoiy(b));

[Acx,Acy]=projfwd(EPSG6931,Arctic_places.Lat,Arctic_places.Lon);
area_ac = inpolygon(Acx,Acy,Aoix(b),Aoiy(b));
close all

%%

%Creates Kriging Interpolation
krig_10=  krig(Data,Arctic_places, [1980 2021],Lat_p,Lon_p,10,ice_Conc,'Uni', 'medi');
krig_11=  krig(Data,Arctic_places, [1980 2021],Lat_p,Lon_p,11,ice_Conc,'Uni', 'medi');
krig_12=  krig(Data,Arctic_places, [1980 2021],Lat_p,Lon_p,12,ice_Conc,'Uni', 'medi');
krig_1=  krig(Data,Arctic_places, [1980 2021],Lat_p,Lon_p,1,ice_Conc,'Uni', 'medi');
krig_2=  krig(Data,Arctic_places, [1980 2021],Lat_p,Lon_p,2,ice_Conc,'Uni', 'medi');
krig_3=  krig(Data,Arctic_places, [1980 2021],Lat_p,Lon_p,3,ice_Conc,'Uni', 'medi');
krig_4=  krig(Data,Arctic_places, [1980 2021],Lat_p,Lon_p,4,ice_Conc,'Uni', 'medi');

%Creates Inverse Distance Weighting Interpolations
idw_10=IDW(Data,Arctic_places,[1980 2021],Lat_p,Lon_p,10,ice_Conc,3,'medi');
idw_11=IDW(Data,Arctic_places,[1980 2021],Lat_p,Lon_p,11,ice_Conc,3,'medi');
idw_12=IDW(Data,Arctic_places,[1980 2021],Lat_p,Lon_p,12,ice_Conc,3,'medi');
isw_1 =IDW(Data,Arctic_places,[1980 2021],Lat_p,Lon_p,1,ice_Conc,3,'medi');
idw_2 =IDW(Data,Arctic_places,[1980 2021],Lat_p,Lon_p,2,ice_Conc,3,'medi');
idw_3 =IDW(Data,Arctic_places,[1980 2021],Lat_p,Lon_p,3,ice_Conc,3,'medi');
idw_4 =IDW(Data,Arctic_places,[1980 2021],Lat_p,Lon_p,4,ice_Conc,3,'medi');

%Creates Trend Analysis Interpolations
trend_10 = trend_a(Data,Arctic_places, [1980 2021],Lat_p,Lon_p,10,ice_Conc,'medi');
trend_11 = trend_a(Data,Arctic_places, [1980 2021],Lat_p,Lon_p,11,ice_Conc,'medi');
trend_12 = trend_a(Data,Arctic_places, [1980 2021],Lat_p,Lon_p,12,ice_Conc,'medi');
trend_1 = trend_a(Data,Arctic_places, [1980 2021],Lat_p,Lon_p,1,ice_Conc,'medi');
trend_2 = trend_a(Data,Arctic_places, [1980 2021],Lat_p,Lon_p,2,ice_Conc,'medi');
trend_3 = trend_a(Data,Arctic_places, [1980 2021],Lat_p,Lon_p,3,ice_Conc,'medi');
trend_4 = trend_a(Data,Arctic_places, [1980 2021],Lat_p,Lon_p,4,ice_Conc,'medi');

%Creates SnowModel-LG, w99m Climatology, or w99 Climatology
[~,~,~,~,~,~,t_mod_10,t_w99m10,t_w99_10]=Cryo(10);
[~,~,~,~,~,~,t_mod_11,t_w99m11,t_w99_11]=Cryo(11);
[~,~,~,~,~,~,t_mod_12,t_w99m12,t_w99_12]=Cryo(12);
[~,~,~,~,~,~,t_mod_1, t_w99m1, t_w99_1 ]=Cryo(1);
[~,~,~,~,~,~,t_mod_2, t_w99m2, t_w99_2 ]=Cryo(2);
[~,~,~,~,~,~,t_mod_3, t_w99m3, t_w99_3 ]=Cryo(3);
[~,~,~,~,~,~,t_mod_4, t_w99m4, t_w99_4 ]=Cryo(4);

%%

%Example of Comparison with fully gridded Data
[Diffk10,CCk10] = comparison(krig_10,t_mod_10,'clim','Krig','SnowModel-LG','oct');
%Example of Comparison with sparse data
[Diffk10,CCk10] = comparison(krig_4,bd,'data','Krig','SnowModel-LG','oct');

%%


% Creates the combined w99m and Kriging climatology for October
plot_w99(t_w99m12,12,'w99m',Lat_p);
Stich_lat = [68; 82]; 
Stich_lon = [-132; -50]
[Stich_x,Stich_y]=projfwd(EPSG6931,Stich_lat,Stich_lon);
p=polyfit(Stich_x,Stich_y,1);
h = polyval(p,Stich_x(1):Stich_x(2));
[Stich_b_lat,Stich_b_lon]=projinv(EPSG6931,(Stich_x(1):Stich_x(2)),h);
latt = reshape(krig_12.lat,size(Lat_p));
lonn = reshape(krig_12.lon,size(Lat_p));
vall = reshape(krig_12.SD,size(Lat_p));
vall(area_AO)=NaN;
surfm(latt,lonn,vall)
plotm(Stich_b_lat,Stich_b_lon,'LineWidth',2)
