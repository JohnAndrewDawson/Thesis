function [lat,lon,sd_w99m,ice_type,ice_Conc,sd_mod,t_mod,t_w99m,t_w99]=Cryo(month)

% Loads and preprocesses British Antarctic Survey CryoSat-2 data including loading the SnowModel-LG, the w99m climatology, and the w99 climatology

%Loads British Antarctic Survey Cryosat2 Data
for j=month   
file=dir(['data\CryoSat2\',month_lkup(j)]);%Loads all files from month j
file=file(3:end);

for i =1:length(file)
%saves variables from each file into variables
file_path = file(i).name;
%ncdisp(['C:\Users\johna\OneDrive\Desktop\Classes\Thesis\data\W99\',month_lkup(month),'\',file_path]);
lat(:,:,i)     = double(ncread(['data\CryoSat2\',month_lkup(month),'\',file_path],'Latitude'));
lon(:,:,i)     = double(ncread(['data\CryoSat2\',month_lkup(month),'\',file_path],'Longitude'));
sd_w99m(:,:,i)  = double(ncread(['data\CryoSat2\',month_lkup(month),'\',file_path],'Snow_Depth_W99'))*100;
ice_type(:,:,i)= double(ncread(['data\CryoSat2\',month_lkup(month),'\',file_path],'Sea_Ice_Type'));
ice_Conc(:,:,i)= double(ncread(['data\CryoSat2\',month_lkup(month),'\',file_path],'Sea_Ice_Concentration'));
sd_mod(:,:,i)  = double(ncread(['data\CryoSat2\',month_lkup(month),'\',file_path],'Snow_Depth'))*100;
un1(:,:,i)  = double(ncread(['data\CryoSat2\',month_lkup(month),'\',file_path],'Snow_Depth_Uncertainty'))*100;
un2(:,:,i)  = double(ncread(['data\CryoSat2\',month_lkup(month),'\',file_path],'Snow_Depth_Uncertainty_W99'))*100;

end

%reconstructs original W99 
sd_w99 = sd_w99m;
sd_w99(ice_type==0) = sd_w99m(ice_type==0)*2;
sd_w99= max(sd_w99,[],3,'omitnan');


%removes yearly variability by averaging grid cells from every year
lat=nanmean(lat,3);
lon=nanmean(lon,3);
sd_w99m=nanmean(sd_w99m,3);
ice_type=median(ice_type,3,'omitnan');
ice_Conc=nanmax(ice_Conc,[],3);
sd_mod=nanmean(sd_mod,3);


Lat_p = lat(:);
Lon_p = lon(:);

%Removes data from outside area of interest
Bad_mask = Lat_p < 67.25 & Lon_p < -100 | Lat_p < 50 & Lon_p > -95 & Lon_p < -75 | Lat_p <45 | Lon_p < -145| Lon_p> -50 | Lon_p < -90 & Lon_p > -105 & Lat_p < 55;
Lat_p(Bad_mask)=NaN;
Lon_p(Bad_mask)=NaN;
sd_mod_t = sd_mod(:); sd_mod_t(Bad_mask)=NaN;
sd_w99_tm = sd_w99m(:); sd_w99_tm(Bad_mask)=NaN;
sd_w99_t = sd_w99(:); sd_w99_t(Bad_mask)=NaN;

%Creates tables in the same format as climatologies
t_mod = table(Lat_p,Lon_p,sd_mod_t);
t_mod = renamevars(t_mod,["Lat_p","Lon_p","sd_mod_t"],["lat","lon","SD"]);
t_w99m = table(Lat_p,Lon_p,sd_w99_tm);
t_w99m = renamevars(t_w99m,["Lat_p","Lon_p","sd_w99_tm"],["lat","lon","SD"]);
t_w99 = table(Lat_p,Lon_p,sd_w99_t);
t_w99 = renamevars(t_w99,["Lat_p","Lon_p","sd_w99_t"],["lat","lon","SD"]);

end
end
