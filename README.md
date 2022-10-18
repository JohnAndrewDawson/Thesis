# Thesis
Thesis deliverables - Containing all functions required to create or modify snow depth on sea ice climetologies

Full thesis can be found at the Cold Climate Enginnering website https://aaltodoc.aalto.fi/bitstream/handle/123456789/116372/master_Dawson_John_2022.pdf?sequence=2&isAllowed=y

List of function descriptions

Main - Calls other functions creating the climetologies.

Assist - Loads and preprocesses ASSIST data.

bridge - Loads gridded and processed OIB data from saved file.

bridgeraw - Loads and preprocesses OIB data.

Buoy - Loads and preprocesses CRREL data.

comparison - Creates difference maps and histograms of two inputted climatologies or data sets.

Cryo - Loads and preprocesses British Antarctic Survey CryoSat2 data including loading the SnowModelLG, the w99m climatology, and the w99 climatology. 

distfun - Calculates great circle distance called by other functions.

Grid - Replaces latitude and longitude coordinates of inputted data to Ease Grid 2.0.

IDW - Creates Inverse Distance Weighting Interpolations.

krig - Creates Kriging Interpolations.

load_insitu - Loads and preprocesses Canadian Ice Thickness Program data.

month_lkup - Returns abbreviation of month for inputted number.

plot_c - Creates a map figure of the CAA.

plot_canada - Creates a map figure of Canada.

plot_north - Creates a map figure of the North Pole.

plot_w99 - Plots SnowModelLG, w99m climatology, or w99 climatology for Canada.

Poly_C - Creates a mask distinguishing if points are within 100 km of selected center point.

red - Creates a white to red colormap. Based on redblue by Adam Auton.

redblue - Creates a blue to white to red color map, written by Adam Auton [56] from MATLAB file exchange.

SemiModel - Creates semivariogram Models.

semivar - Calculates the semivariance of inputted data.

station_ice - Determines which in situ stations are within 500 km of sea ice.

trend_a - Creates Trend Analysis interpolations.

The MATLAB codes were added to the thesis using a package created by Florian Knorn
available on the MATLAB file exchange [57].

[56] Adam Auton (2022). Red Blue Colormap (https://www.mathworks.com/matlabcentral/fileexchange/25536redbluecolormap), MATLAB Central File Exchange. Retrieved July 1, 2022.


[57] Florian Knorn (2022). Mcode LaTeX Package (https://www.mathworks.com/matlabcentral/fileexchange/8015mcodelatexpackage), MATLAB Central File Exchange. Retrieved July 1, 2022.
