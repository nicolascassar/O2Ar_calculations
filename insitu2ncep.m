function [ws] = insitu2ncep(lat,lon,yr,mn,dy,ncep_path,dayNum,obsNum,interp_method)
%
% Match insitu measurements to NCEP wind speed products
%
%
% Input
%
% lat: latitude which is in the formate from -90 to 90 degree
%
% lon: longitude which is in the formate from -180 to 180 degree
%
% yr: year
%
% mn: month
%
% dy: day
%
% ncep_path: folder for saving ncep wind speed;
%
% dayNum: number of days of wind speed time-series
%
% obsNum: number of observations in each day. 
%        4-times daily NCEP, obsNum=4
%        daily NCEP,         obsNum=1
%
% interp_method: interpolate method, and it can be 'nearest', 'linear'...
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
% (0 means current day observations, -1 means yestday, ..., -n means n day before)
%
% End Output
%
%
% History
%
% End History
%
%
% Author: Zuchuan Li
% Date  : 09/09/2013
%
%% some constants
% the ranges of NCEP data
% refer to NCEP website
ncep_lat_rng = (90:-2.5:-90)';

% NOTE: longitude range is extended to 360 degree where value is the same
% as that in the longitude of 0 degree. This extention will facilitate
% interpolation of samples with longitude of <0 but >-2.5.
ncep_lon_rng = (0:2.5:360)';

% number of observations
sampleNum = length(lat);
ws = zeros(sampleNum,dayNum.*obsNum);

% NOTE: convert longtitude from -180~180 to 0-360
% This conversion depends on the NCEP dataset which is organized in the
% order of 0-360 in longitude.
lon(lon<0) = lon(lon<0) + 360.0;


%% date is converted to the day of a year
% for example, 01-31-2008 is 31, 02-01-2008 is 32
year_day  = datenum(yr,mn,dy) - datenum(yr,zeros(sampleNum,1),zeros(sampleNum,1));


%% match to NCEP
ncep = []; % ncep wind speed dataset
for j = 1: sampleNum
    disp(j);
    
    % upload wind speed
    % if the year of current observation differs from previous one, ncep
    % wind speed is uploaded. Otherwise, using previous uploaded wind speed.
    if j == 1 || yr(j) ~= yr(j-1)
        ncep = load_ws(ncep_path,yr(j));
        
        % date back to previous year
        if year_day(j) < dayNum
            tmp = load_ws(ncep_path,yr(j)-1);
            num1 = size(tmp,3);
            num2 = size(ncep,3);
            index = (num2+1): (num2+num1);
            ncep(:,:,index) = tmp;
        end
        
        % value at the longtitude of 360 degree
        ncep(end+1,:,:) = ncep(1,:,:);
    end
    
    % search for wind speed for a location
    for k = 1: dayNum
        index = obsNum .* (year_day(j) - k) + 1;
        
        % if index <=0, date back to previous year
        if index <= 0
            % change by Zuchuan Li and Rachel to account for the case the a
            % year with incomplete data
            % 4/24/2014
            index = index + size(ncep,3);%(year_day(j) + yeardays(yr(j)-1)) * obsNum;
        end
        
        for m = 1: obsNum
            ws(j,(k-1)*obsNum+m) = interp2(ncep_lat_rng,ncep_lon_rng,ncep(:,:,index+m-1),lat(j),lon(j),interp_method);
        end
    end
end


% NOTE: wind speed time-series order of (history ---> current)
ws = ws(:,end:-1:1);


end




%% upload wind speed of NCEP for a given year
% ncep_path: the folder saving NCEP product
% year: the year of data to upload
function [wind_speed] = load_ws(ncep_path,year)   % upload U component
    ufilename = [ncep_path,'\uwnd.sig995.',num2str(year),'.nc'];
    uwnd = ncread(ufilename,'uwnd');
    
    % upload V component
    vfilename = [ncep_path,'\vwnd.sig995.',num2str(year),'.nc'];
    vwnd = ncread(vfilename,'vwnd');
    
    % calculate wind speed from U and V
    wind_speed = (uwnd.^2+vwnd.^2).^0.5;
    size(wind_speed)
end






