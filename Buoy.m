function [T] = Buoy()

% Loads and preprocesses CRREL data

%Loads CRREL Buoy Data
files = dir ('data\Buoy');

%Initializes variables
ID=[];
lon = [];
lat = [];
SD  = [];
month = [];
year = [];
day = [];
ice_type_filled = [];

for i = 3:2:length(files)-1
name  = files(i).name;
name2 = files(i+1).name;

A1 = readtable(['data\Buoy\',name]);%Load measurement data
P1 = readtable(['data\Buoy\',name2]);%Loads Position data

T1 = outerjoin(A1,P1,'MergeKeys',true);%Merge Position and measurement data
T1 = renamevars(T1,["Latitude","Longitude"],["lat","lon"]);

%Removes duplicated rows 
[u,I]=unique(datetime(T1.Year,T1.Month,T1.Day,T1.HH,T1.MM,T1.SS), 'rows', 'first');
ixDupRows = setdiff(1:size(datetime(T1.Year,T1.Month,T1.Day,T1.HH,T1.MM,T1.SS),1), I);
T1(ixDupRows,:)=[];

%Removes entries with no snow depth measurements
T1.lat = fillmissing(T1.lat,'linear','SamplePoints',datetime(T1.Year,T1.Month,T1.Day,T1.HH,T1.MM,T1.SS));
T1.lon = fillmissing(T1.lon,'linear','SamplePoints',datetime(T1.Year,T1.Month,T1.Day,T1.HH,T1.MM,T1.SS));
T1(isnan(T1.SnowDepth),:)=[];

loc1 = T1.Month== 10|T1.Month== 11|T1.Month== 12|T1.Month== 1|T1.Month== 2|T1.Month== 3|T1.Month== 4;
loc2 = T1.lat < 45 | T1.lat > 85 | T1.lon < -145| T1.lon > -50 | isnan(T1.SnowDepth);

%Removes stations that are outside the Months of interest or the area of interest
T1(~loc1|loc2,:) = [];

%Stores data from each file
ID= [ID; repmat(str2num(name(1:4))+ convertCharsToStrings(name(5)), length(T1.lat),1)];
lat = [lat; T1.lat];
lon = [lon; T1.lon];
year = [year; T1.Year];
month = [month; T1.Month];
day = [day; T1.Day];
SD = [SD; T1.SnowDepth*100];
end

%Adds Sea ice type data from website 0 indicated first year ice and 1 indicates multi year ice
FYI_by = ['2014C';'2013A';'2012H';'2012G';'2012D';'2011D';'2008B'];
ice_type=ones(size(SD));
ice_type(ismember(ID,FYI_by))=0;

%stores Data in Table
T = table(lat,lon,year,month,day,SD,ID,ice_type);
end