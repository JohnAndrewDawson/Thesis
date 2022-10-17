function [T] = Assist()

%Loads and preprocesses ASSIST data

%Loads ASSIST data
files=dir ('data\Assist');

%Initializes Variables
year=[];
lat=[];
lon=[];
day=[];
month=[];
names=[];
SD=[];
SD2=[];
SD3=[];
plot_canada
%Save data from every file into sinlge variables
for i = 3:length(files)
name  = files(i).name;
A =readtable(['data\Assist\',name]);
lat = [lat; A.LAT];
lon = [lon; A.LON];
year = [year; A.Year];
month = [month; A.Month];
day = [day; A.Day];
SD = [SD; A.PSH];
SD2 = [SD2; A.SSH];
SD3 = [SD3; A.TSH];
names = [names; i*ones(length(A.Day),1)];
hold on
plotm(A.LAT,A.LON,'.')
end


size(lat);
loc = month== 10;
loc2 = lat < 45 | lon < -145| lon > -50 | isnan(SD) & isnan(SD2) & isnan(SD3);

%Removes data from outside the area of intrest and outside the time frame
month(~loc | loc2)=[];
lat(~loc   | loc2)=[];
lon(~loc   | loc2)=[];
SD(~loc    | loc2)=[];
SD2(~loc   | loc2)=[];
SD3(~loc   | loc2)=[];
year(~loc  | loc2)=[];
day(~loc   | loc2)=[];
names(~loc | loc2)=[];

%Creates table of vareiables
T1= table(lat,lon,year,month,day,SD );
T2= table(lat,lon,year,month,day,SD2);
T2 = renamevars(T2,'SD2','SD');
T3= table(lat,lon,year,month,day,SD3);
T3 = renamevars(T3,'SD3','SD');

T = table(lat,lon,year,month,day,SD,SD2,SD3);
end