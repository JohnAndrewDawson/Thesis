function Trend = trend_a(Data,Arctic_places, year_range,lat,lon,months,ice_Conc,Add_string)
small_font=10;
med_font  =15;
large_font=20;

% Creates Trend Analysis interpolations

%Stores size of original matrix and creates vectors for lat and lon
size_p=size(lat);
lat = lat(:);
lon = lon(:);

%creates projection
EPSG6931=projcrs(6931);
[x,y]= projfwd(EPSG6931,lat,lon);
x(x==0)=NaN;
y(y==0)=NaN;

%Restricts data to selected years
Rel_year = Data(Data.year >= year_range(1) & Data.year <= year_range(2),:);

%Creates table of monthly averages for each station
months_Full= groupsummary(Rel_year, {'ID','Station','month'}, {'max','median','mean'}, {'IceThickness','SnowDepth'}); % Calculates mean or mean snow depth for all data of each month

%Restricts Stations locations to match stations in data
Lia2 = ismember(Arctic_places.Station,months_Full.Station);
Arctic_places=Arctic_places(Lia2,:);

for i=months

  false(size(ice_Conc(:,:,i))); ice_c(ice_Conc(:,:,i)>= 0.7) = true;%Enforces Ice concentraion above 70%
  bool = station_ice(Arctic_places,ice_Conc(:,:,i),lat,lon);%Selects stations within 500 km of ice
  Arctic_places_used=Arctic_places(bool,:);%Removes stations further then 500 km of ice 
  
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
  
  %Creates matrix of system of equations
A = [Arctic_places_used.x.^2 Arctic_places_used.y.^2 Arctic_places_used.x.*Arctic_places_used.y Arctic_places_used.x Arctic_places_used.y ones(size(Arctic_places_used.y))];
%Solves system of equations
g = A\monthly_snow_depth;

%calculate estimate at each unknown point
  val = g(1)*x.^2+g(2)*y.^2+g(3)*x.*y+g(4)*x+g(5)*y+g(6);
  val(~ice_c) = NaN;
  val(val <= 0) = 0;
  SD=val;
  %Creates Clim table
  Trend=table(lat,lon,SD);
%   writetable(Trend,['C:\Users\johna\OneDrive\Desktop\CSV\Trend_Analysis_',month_lkup(i),'.csv']) 
  %Reshapes data for ploting
    lat = reshape(lat,size_p);
    lon = reshape(lon,size_p);
    val = reshape(SD,size_p);


plot_canada
surfm(lat,lon,val)
c=colorbar;
colormap(red)
c.Label.String = 'Snow Depth [cm]';
caxis
caxis([0 60])
land = readgeotable("landareas.shp");
geoshow(gca,land,"FaceColor",[0.5 0.7 0.5],"EdgeColor",[0.5 0.7 0.5])
plotm(Arctic_places_used.Lat, Arctic_places_used.Lon,'b*')
exportgraphics(gcf,['C:\Users\johna\OneDrive\Desktop\Classes\Thesis\OverleafFigs\presentaion\trend_',num2str(i),'.png']);

end
end