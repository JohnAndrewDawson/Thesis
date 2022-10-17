function plot_c()
% Creates a map figure of the CAA
figure()
latlim = [67.5 85];
lonlim = [-145 -50];
worldmap(latlim,lonlim)
setm(gca,'MLabelLocation',15)
setm(gca,'PLabelLocation',10)
land = readgeotable("landareas.shp");
geoshow(gca,land,"FaceColor",[0.5 0.7 0.5],"EdgeColor",[0.5 0.7 0.5])
setm(gca,'ffacecolor',[0.40 0.40 0.40])
end