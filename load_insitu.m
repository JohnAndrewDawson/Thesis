function [Data, Arctic_places,Lat_p,Lon_p,x_p,y_p,ice_Conc] = load_insitu()
% Loads and preprocesses Canadian Ice Thickness Program data

%Loads In situ Data until 2002
A = readtable('data\StationData.xls','Sheet',1);

%Loads In situ Data after 2002
B=[];
for i = [3,5,6,7,8,10,11]
b = readtable('data\current\Ice_thickness_2002_to_2021.xlsx','Sheet',i);
B = [B; b];
end

%Loads Projection
EPSG6931=projcrs(6931);

%Loads SnowModel-LG, W99m, Ice Type and Ice Concentration
for i=[1,2,3,4,10,11,12]
% land_mask_W99(:,:,i) =logical(readmatrix('C:\Users\johna\OneDrive\Desktop\Classes\Thesis\data\Land_Mask_w99','Sheet',i));
[Lat_w(:,:,i),Lon_w(:,:,i),sd(:,:,i),it(:,:,i),ice_Conc(:,:,i)]= Cryo(i);
end

%Creates a single array of the Ease-2.0 Grid
Lat_p=Lat_w(:,:,1); 
Lon_p=Lon_w(:,:,1);

%Creates a mask to remove data outside the area of interest
Bad_mask = Lat_p < 67.25 & Lon_p < -100 | Lat_p < 50 & Lon_p > -95 & Lon_p < -75 | Lat_p <45 | Lat_p > 85 | Lon_p < -145| Lon_p> -50 | Lon_p < -90 & Lon_p > -105 & Lat_p < 55;
Lat_p(Bad_mask)=NaN;
Lon_p(Bad_mask)=NaN;
x(Bad_mask)    =NaN;
y(Bad_mask)    =NaN;


%Loads Station Location Data
places = readtable('data\StationData.xls','Sheet',2);

%Creates a mask of the mask to remove stations not near the coasts
pe = places.Lat > 40 & places.Lon > -70;
ne = places.Lat > 50 & places.Lon > -95;
sf = places.Lat > 68.35;
ac = ne|sf|pe;


Arctic_places = places(ac,{'Station','Lat','Lon'});%Removes stations away from the Area of Interest in location variable
[Lia1] = ismember(A.Station,Arctic_places.Station);
Arctic_Full = A(Lia1,:);%Removes stations outside of the area of interest from general data


%Adds separate year, month and day data to general data variable
[year,month,day] = datevec(char(Arctic_Full.Date), 'dd-mmm-yyyy');
Arctic_Full=addvars(Arctic_Full,year,'After','Date');
Arctic_Full=addvars(Arctic_Full,month,'After','year');
Arctic_Full=addvars(Arctic_Full,day,'After','month');
years = grpstats(Arctic_Full,'ID',{'min','max'},'DataVars',{'year'});


low_data = ['LT1';'YNI';'YIV';'WTL';'YAH';'YYR';'YKL';'WLH';'HA1';'IC1';'PH1';'YG3';'YG2';'YG5';'YG6'];
high_data = ['WEU';'YCB';'YLT';'YRB';'YZS';'YUX';'YFB'];% IDs of stations that continue to take mesurments after 2002
Lia1=ismember(Arctic_Full.ID,low_data);
Arctic_Full = Arctic_Full(~Lia1,:);  % Removes Stations that are not on the Coast, had too few measurements, and lake measurements that are co-located with other stations from general data
Lia2 = ismember(Arctic_places.Station,Arctic_Full.Station);
Arctic_places=Arctic_places(Lia2,:); % Removes Stations that are not on the Coast, had too few measurements, and lake measurements that are co-located with other stations from position data
Arctic_Full(Arctic_Full.year<1940,:)=[];


% Adds separate time data to recent data
[year,month,day] = datevec(char(B.Date), 'dd-mmm-yyyy');
B=addvars(B,year,'After','Date');
B=addvars(B,month,'After','year');
B=addvars(B,day,'After','month');

%Combines Old and recent Data
Data = [Arctic_Full(:,[1:9]); B(:,[1:9])];

%Add projection Data to location data
[x_p, y_p] = projfwd(EPSG6931,Lat_p,Lon_p);
x_p(x_p==0)=NaN;
y_p(y_p==0)=NaN;
[ac_x,ac_y]=projfwd(EPSG6931,Arctic_places.Lat, Arctic_places.Lon);
Arctic_places=addvars(Arctic_places,ac_x,'After','Lon','NewVariableNames','x');
Arctic_places=addvars(Arctic_places,ac_y,'After','x','NewVariableNames','y');
end