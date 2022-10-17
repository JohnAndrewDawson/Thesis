function plot_north()
% Creates a map figure of the North Pole
 figure()  
 worldmap([50 90],[262.5-180 261.5-180])
 land = readgeotable("landareas.shp");
 geoshow(gca,land,"FaceColor",[0.5 0.7 0.5],"EdgeColor",[0.5 0.7 0.5])
 setm(gca,'ffacecolor',[0.40 0.40 0.40])
end