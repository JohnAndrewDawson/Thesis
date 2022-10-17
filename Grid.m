function [t] = Grid(Lat_p,Lon_p,data)
%Replaces latitude and longitude coordinates of inputted data to Ease Grid 2.0

%removes empty data
Lat_p(isnan(Lat_p))=[];
Lon_p(isnan(Lon_p))=[];
Lat_p=Lat_p(:);
Lon_p=Lon_p(:);


% Calculated the distance from data point to each grid cell center
for j = 1:length(data.lat)
dis_point_a=sind((data.lat(j)-Lat_p)/2).^2 + cosd(data.lat(j)).*cosd(Lat_p).*sind((data.lon(j)-Lon_p)/2).^2;
dis_point(:,j) =(6371.009 *2*atan2(sqrt(dis_point_a), sqrt(1-dis_point_a)));
end

%{
EPSG6931=projcrs(6931);
[x_p, y_p] = projfwd(EPSG6931,Lat_p,Lon_p);
[data_x, data_y] = projfwd(EPSG6931,data.lat,data.lon);

for j = 1:length(data.lat)
dis_point_xy(:,j) =sqrt((data_x(j)-x_p).^2+(data_y(j)-y_p).^2);
end

[c1 index1] = min(abs(dis_point_xy));
%}

%Finds the location of minimum distance from data to grid cell
[c index] = min(abs(dis_point));
index=index';

%Replaces lat and lon with coordinates of closest grid cell
data.lat = Lat_p(index);
data.lon = Lon_p(index);

%creates new clim table by taking the mean of all points assigned to each
%cell for each month
t = groupsummary(data,{'lat','lon','month'},{'all'},{'SD'});
t = renamevars(t,'mean_SD','SD');

end