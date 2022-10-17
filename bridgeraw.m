function bd_raw=bridgeraw()

% Loads and preprocesses OIB data

%Loads OBI data not fitted to Ease Grid 2.0
files1 = dir ('data\Bridge\quicklooks');

%Initializes Variables
names=[];
lat=[];
lon=[];
count=[];
SD = [];
year= [];
month=[];
day=[];
year_d=[];
month_d=[];
SD_unc=[];
day_d=[];

for i = 1:length(files)
    
    name=files(i).name;
    A1=readtable(['data\Bridge\quicklooks\',name]);
    
%Restricts data to area of interest
    loc = A1.lat <45 |A1.lat > 85| A1.lon < 360-145| A1.lon> 360-50| A1.snow_depth == -99999;
    A1(loc,:)=[];
    
    %Skip files with no data in area of interest
    if isempty(A1.snow_depth)
        names = [names; i];
    
    else
        %Save data from every file into sinlge variables
    year  = [year; str2num(name(1:4))];
    month = [month; str2num(name(5:6))];
    day   = [day; str2num(name(7:8))];
    year_d= [year_d ; str2num(name(1:4)).*ones(size(A1.lat))];
    month_d=[month_d; str2num(name(5:6)).*ones(size(A1.lat))];
    day_d = [day_d; str2num(name(7:8)).*ones(size(A1.lat))];
        
    lat   = [lat; A1.lat];
    lon   = [lon; A1.lon];
    SD    = [SD; A1.snow_depth];
    SD_unc= [SD_unc; A1.snow_depth_unc];

    end

    %stores data in table
    bd_raw = table(lat,lon, SD, year_d,month_d,day_d);
end

end