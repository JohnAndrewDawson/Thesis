function plot_w99(t,i,Label,Lat_p)

% Plots SnowModel-LG, w99m climatology, or w99 climatology for Canada

size_p=size(Lat_p);
lat = reshape(t.lat,size_p);
lon = reshape(t.lon,size_p);
val = reshape(t.SD,size_p);

med_font=15;
plot_north
surfm(lat,lon,val)
c = colorbar;
colormap(red)
c.Label.String = 'Snow Depth [cm]';
caxis
caxis([0 60])
land = readgeotable("landareas.shp");
geoshow(gca,land,"FaceColor",[0.5 0.7 0.5],"EdgeColor",[0.5 0.7 0.5])
end