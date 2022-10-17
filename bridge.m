function  [bd] = bridge()

% Loads gridded and processed OIB data from saved file

%loads OIB files fitted to Ease Grid 2.0
files = dir ('data\BridgeGrided');

%Initializes variables
lat=[];
lon=[];
count=[];
SD = [];
year= [];
month=[];
day=[];
year_d=[];
month_d=[];
day_d=[];

%Stores data from each file
for i = 3:length(files)    
    name=files(i).name;
    A1=readtable(['data\BridgeGrided\',name]);
    year   = [year; str2num(name(1:4))];
    month  = [month; str2num(name(5:6))];
    day    = [day; str2num(name(7:8))];
    year_d = [year_d ; str2num(name(1:4)).*ones(size(A1.lat))];
    month_d= [month_d; str2num(name(5:6)).*ones(size(A1.lat))];
    day_d  = [day_d; str2num(name(7:8)).*ones(size(A1.lat))];
    lat    = [lat; A1.lat];
    lon    = [lon; A1.lon];
    count  = [count; A1.GroupCount];
    SD     = [SD;  A1.mean_data*100];
    
end

%stores data in table
bd = table(lat,lon, count, SD, year_d,month_d,day_d);
end