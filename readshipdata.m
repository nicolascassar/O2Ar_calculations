% Open ship data
clear
clc
fid=fopen('Alldatasofar.dat','r');
g=textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','headerlines',4,'delimiter',':/');%,'delimiter',':/'
fclose(fid);
dat=datenum(g{1},g{2},g{3}, g{4},g{5},g{6});
lat=g{23};
lon=g{24};
cdom=g{7};
fluo1=g{9};
fluo2=g{10};
pH=g{13};
phycocyanin=g{15};
S=g{17}; % Salinity Ferribox
S_keel=g{34}; % Salinity at keel
turb=g{18}; % Turbidity
temp=g{19}; % Water Temperature ferribox
temp_keel=g{36}; % Water Temperature at keel
temp_weather=g{52}; % Water Temperature from weatherstation
depth=g{21};
wd=g{27}; % wind direction from System
wd_weather=g{49}; % wind direction from Weathersation
ws=g{28}; % wind speed (m/s) from System
ws_weather=g{50}; % wind speed (m/s) from Weatherstation
ws_beaufort=g{31}; %in Beaufort scale
P=g{37}; % Air pressure (hPa)
T_air=g{38}; % Air temperature (hPa)

ship=[dat,lat,lon,cdom,fluo1,fluo2,pH,phycocyanin,S,S_keel,turb,temp,temp_keel,temp_weather,depth,wd,wd_weather,ws,ws_weather,ws_beaufort,P,T_air];

save('shipraw.mat', 'ship')
