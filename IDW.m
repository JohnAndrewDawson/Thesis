function IDW_clim = IDW(Data,Arctic_places,year_range,Lat,Lon,months,ice_Conc,s,Add_string)
small_font=10;
med_font=15;
large_font=20;

% Creates Inverse Distance Weighting Interpolations

%Stores size of original matrix and creates vectors for lat and lon
size_p=size(Lat);
lat = Lat(:);
lon = Lon(:);

%creates projection
EPSG6931=projcrs(6931);
[x,y]= projfwd(EPSG6931,lat,lon);


%Restricts data to selected years
Rel_year = Data(Data.year >= year_range(1) & Data.year <= year_range(2),:);
months_Full= groupsummary(Rel_year, {'ID','Station','month'}, {'max','median','mean'}, {'IceThickness','SnowDepth'}); % Calculates mean or mean snow depth for all data of each month

%Removes Stations that do not have mesuremnts in the selected years
Lia2 = ismember(Arctic_places.Station,months_Full.Station);
Arctic_places=Arctic_places(Lia2,:);

for i = months
  ice_c = false(size(ice_Conc(:,:,i))); ice_c(ice_Conc(:,:,i)>= 0.7) = true; %Converts Ice concentrations into a true false boolean
  bool = station_ice(Arctic_places,ice_Conc(:,:,i),lat,lon); % Runs function that find all stations that are not within 500 km of an cell with ice concentration
  Arctic_places_used=Arctic_places(bool,:); %Remoces stations that are not with 500 km of sea ice
   
    
    %Selects Data from selected month and creates a table with measurement and position data
  monthly = months_Full((months_Full.month == i),[1:end]); 
  monthly = innerjoin(Arctic_places_used,monthly(:,[2:end]));

      %Selectes either mean of median of station data
  if Add_string == 'mean'
  monthly_snow_depth = monthly.mean_SnowDepth;
  elseif Add_string == 'medi'
  monthly_snow_depth = monthly.median_SnowDepth;
  else
  error('mean or median("medi")')
  end

    %Enforces Stations have data
  Arctic_places_used = Arctic_places_used(ismember(Arctic_places_used.Station,monthly.Station),:);
  Stations = [Arctic_places_used.Lat Arctic_places_used.Lon];

for k=1:length(Arctic_places_used.Station)
x = Arctic_places_used.Lat(k);
y = Arctic_places_used.Lon(k);
a=sind((x-Lat)/2).^2 + cosd(x).*cosd(Lat).*sind((y-Lon)/2).^2;
d(:,:,k) =6371*2*atan2d(sqrt(a), sqrt(1-a));%Calculates distance from each station to unknown point
w(:,:,k) = 1./d(:,:,k).^s;%Calculates the weight for each station
Station_inf(:,:,k)=w(:,:,k).*monthly_snow_depth(k);
end

val = nansum(Station_inf,3)./nansum(w,3);%Calculates the estimate at each station
val(~ice_c)=NaN;%Removes values with too low of ice concentration

%Reshapes for table
SD = val(:);
lat = Lat(:);
lon = Lon(:);

%Creates clim table
IDW_clim = table(lat,lon,SD);
%   writetable(IDW_clim,['C:\Users\johna\OneDrive\Desktop\CSV\IDW_',month_lkup(i),'.csv']) 

plot_canada
surfm(Lat,Lon,val)
c = colorbar;
caxis([0 60])
colormap(red)
c.Label.String = 'Snow Depth [cm]';
land = readgeotable("landareas.shp");
geoshow(gca,land,"FaceColor",[0.5 0.7 0.5],"EdgeColor",[0.5 0.7 0.5])
plotm(Arctic_places_used.Lat, Arctic_places_used.Lon,'b*')
exportgraphics(gcf,['C:\Users\johna\OneDrive\Desktop\Classes\Thesis\OverleafFigs\presentaion\IDW_',num2str(i),'.png']);
end
end