function [ws] = insitu2narr10m_SW(lat,lon,yr,mn,dy,narr_path,dayNum,obsNum,interp_method)
%
%
% Author: Zuchuan Li, edited by Seaver Wang
% Date  : 06/03/2018
%
% edited by Seaver Wang to use the NARR (North American Regional Reanalysis)
% wind speed data products found at:
% https://www.esrl.noaa.gov/psd/data/gridded/data.narr.monolevel.html
%
% u-wind at 10m, v-wind at 10m, once daily
%
% This script matches insitu measurements to NARR wind speed products
%
%
% Input
%
% lat: latitude in the format from -90 to 90 degrees
%
% lon: longitude in the format from -180 to 180 degrees
%
% yr: year
%
% mn: month
%
% dy: day
%
% narr_path: folder for saving narr wind speed;
%
% dayNum: number of days of wind speed time-series
%
% obsNum: number of observations in each day. For daily NARR, obsNum=1
% **Note: this script is written for NARR data which is once-daily, so this value should always be set equal to 1.**
%
% interp_method: interpolation method, can be 'nearest', 'linear', etc...
%
% End Input
%
%
% Output
%
% ws: wind speed; 
%     data is organized as follows (history ---> current):
%     row#    ws    ws  ...  ws   ws
%     1       -n   -n+1      -1   0     
%     .
%     .
%     .
%
% (0 means current day observations, -1 means yesterday, ..., -n means n day before)
%
% End Output
%
%
% History
%
% End History
%
%
%% some constants
% the ranges of NARR data
% refer to NARR website
narr_lat_rng = [];

% NOTE: longitude range is extended to 360 degree where value is the same
% as that in the longitude of 0 degree. This extention will facilitate
% interpolation of samples with longitude of <0 but >-2.5.
narr_lon_rng = [];

% number of observations
sampleNum = length(lat);
ws = zeros(sampleNum,dayNum.*obsNum);




% NOTE: convert longtitude from -180~180 to 0-360
lon(lon<0) = lon(lon<0) + 360.0;


%% date is converted to the day of a year
% for example, 01-31-2008 is 31, 02-01-2008 is 32
year_day  = datenum(yr,mn,dy) - datenum(yr,zeros(sampleNum,1),zeros(sampleNum,1));


%% match to NARR
narr = []; % ncep wind speed dataset
for j = 1: sampleNum
    disp(j);
    
    % upload wind speed
    % if the year of current observation differs from previous one, that
    % year's NARR data is also uploaded. Otherwise, the script proceeds
    % using just the previously uploaded wind speed. for the current year
    if j == 1 || yr(j) ~= yr(j-1)% "if this is the first data point, or if the year has changed from previous measurement"
        
        [narr, narr_lat_rng, narr_lon_rng] = load_ws(narr_path,yr(j));%then load current year data

        % date back to previous year
        if year_day(j) < dayNum% if year_day(j)<dayNum, then load previous year's data
[narr_prev, narr_lat_rng_prev, narr_lon_rng_prev]=load_ws(narr_path,yr(j)-1);
narr2=cat(3, narr, narr_prev);% add previous year's data at end of current year's data.

        else
            narr2=narr;
        end
    end
    
    % search for wind speed for a location
    for k = 1: dayNum
        index = obsNum .* (year_day(j) - k) + 1;
        
        % if index <=0, date back to previous year
        if index <= 0
            index=index+size(narr(:,:,3));% change by Seaver, pulls data from previous year's data, which has been appended to current year's.
        end
        
        for m = 1: obsNum
            
            ws(j,(k-1)*obsNum+m) = interp2(narr_lon_rng,narr_lat_rng,narr2(:,:,index+m-1),lon(j),lat(j),interp_method);

        end
    end
end


% NOTE: wind speed time-series order of (history ---> current)
ws = ws(:,end:-1:1);


end





%% upload wind speed of NARR for a given year
% ncep_path: the folder saving NARR product
% year: the year of data to upload

function [wind_speed, y, x] = load_ws(narr_path,year)   % upload U component
    uflist = dir(fullfile(narr_path, ['uwnd.10m.', num2str(year), '.nc']));%
    %ufilename = [narr_path,'\uwnd.*.',num2str(year),'.nc'];
    uwnd = ncread(fullfile(narr_path, uflist(1).name), 'uwnd');
    ulat = ncread(fullfile(narr_path, uflist(1).name), 'lat');
    ulon_unconv = ncread(fullfile(narr_path, uflist(1).name), 'lon');
    
    for zulu=1:size(uwnd,3)
    ulon=ulon_unconv;
    ulon(ulon_unconv<0)=ulon(ulon_unconv<0)+360;%convert longitude to 0 to 360 degree format
    x=180:0.25:360;%set new regularized grid with boundaries at limits of NARR grid
    y=[10:0.25:80]';
    uwndint(:,:,zulu)=griddata(double(ulon),double(ulat),uwnd(:,:,zulu),x,y,'linear');%interpolate data over new grid
    end
    
    % upload V component
    vflist = dir(fullfile(narr_path, ['vwnd.10m.', num2str(year), '.nc']));
    %vfilename = [narr_path,'\vwnd.*.',num2str(year),'.nc'];
    vwnd = ncread(fullfile(narr_path, vflist(1).name),'vwnd');
    
    for yankee=1:size(vwnd,3)
    vwndint(:,:,yankee)=griddata(double(ulon),double(ulat),vwnd(:,:,yankee),x,y,'linear');%interpolate data over new grid
    end
    
    % calculate wind speed from U and V
    wind_speed = (uwndint.^2+vwndint.^2).^0.5;%
    size(wind_speed)
end

