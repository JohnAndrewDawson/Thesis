function bul=station_ice(Arctic_places,ice_Conc,Lat,Lon)
%Determines which in situ stations are within 500 km of sea ice

i = ice_Conc>= 0.7;
Lat(~i)= NaN;
Lon(~i)= NaN;

for i = 1:length(Arctic_places.Lat)
    [x,y]=Poly_C(Arctic_places.Lat(i),Arctic_places.Lon(i),500);
    if max(inpolygon(Lat,Lon,x,y),[],'all') == 1
        bul(i) = true;
    else
        bul(i) = false;
    end
end
end
