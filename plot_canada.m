function plot_canada()
% Creates a map figure of Canada
 figure()  
 worldmap('canada')
 land = readgeotable("landareas.shp");
 geoshow(gca,land,"FaceColor",[0.5 0.7 0.5],"EdgeColor",[0.5 0.7 0.5])
 setm(gca,'ffacecolor',[0.40 0.40 0.40])
end