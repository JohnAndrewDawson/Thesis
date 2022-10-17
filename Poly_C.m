function [x,y] = Poly_C(Lat_c,Lon_c,radiusKm)

% Creates a mask distinguishing if points are within 100 km of selected center point

for i=1:length(Lat_c)
radiusLon = (1 / (111.319*cosd(Lat_c(i))))*radiusKm;
radiusLat = (1 / 110.574)*radiusKm;
theta = 0:360;
x(:,i)= Lat_c(i) + radiusLat*sind(theta);
y(:,i)= Lon_c(i) + radiusLon*cosd(theta);

end

end