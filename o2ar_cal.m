function [rs_o2ar_wtr_air,air_idx,is_success] = o2ar_cal(o2ar,mdcdate,valco,varargin)
%
% calibrate o2ar raw measurements
%
%
% Input
%
% o2ar: o2ar measurements in air and water
%          format (n,1), n is row #
% mdcdate: date of the measurements, in the number form
%          format (n,1), n is row #
% valco: label indicates air or water o2/ar measurements
%        NOTE: 1=air, 2=water
%          format (n,1), n is row #
% varargin:
%          Remove o2ar data which occurs after restarting the program. For some
%          reason, the o2ar is wrong when restarting the Quadstar software
%          If the difference between 2 dates >ITVL_BT_OBS minutes
%          remove RESET_TRCT_TIME minutes of data after switching on instrument
%              ITVL_BT_OBS = 4 (default);      % unit (minute)
%              RESET_TRCT_TIME = 80 (default); % unit (minute)
% 
%          samples will be discarded if the difference (%) between two consecutive 
%          o2/ar in air > AIR_O2AR_THR.
%              AIR_O2AR_THR = 2.0 (default); % unit (%)
%
%          truncate part of observations when measurements swith between air to water
%          truncate 4 (6) minute for o2/ar in air (water) in the boundary region
%              AIR_VALCO_SWCH_TRCT_TIME = 4 (default); % unit (minute)
%              WTR_VALCO_SWCH_TRCT_TIME = 6 (default); % unit (minute)
%
%          Range of o2/ar in air, beyond which observation is discarded
%              O2AR_AIR_RNG = [15;25] (default);
%
%          Pressure measurements which are used to control data quality
%              PRES;
%
%          Pressure range, beyond which observation observation is
%          discarded
%              PRES_RNG = [1e-6;9e-6] (default);
%
%          Display calibrated results
%              Display = 'on' (default);
%
% End
%
%
% Output
%
% rs_o2ar_wtr_air: calibrated O2/Ar measurements
%               format (date,o2/Ar in water,o2ar in air)
% air_idx: the indices of o2/ar in air used to calibrate measurements
% is_success: 0=fail, 1=success
%
% End
%
%
% NOTE
%
% 1. valco has two possible value, 1=o2/ar in air, 2=o2/ar in water
%
% End
%
%
% Example
%
% 1. using default parameters as shown in input parameter varargin:
%    o2ar_cal(o2ar,mdcdate,valco)
% 2. using customer parameters:
%    o2ar_cal(o2ar,mdcdate,valco,'ITVL_BT_OBS',2)
%    time interval between two observations is less than 2 minutes, other
%    parameters using default value. The same method can be used to set other
%    parameters.
%
% End
%
%
% Histry
%
% 1. revised by Rachel Eveleth, Yajuan Lin
% 2. revised by Zuchuan Li   03/11/2015
%
% End
%
% Authors: Nicolas Cassar
%

%% Some constants and default values
% Remove o2ar data which occurs after restarting the program. For some
% reason, the o2ar is wrong when restarting the Quadstar software
% If the difference between 2 dates >ITVL_BT_OBS minutes
% remove RESET_TRCT_TIME minutes of data after switching on instrument
global ITVL_BT_OBS;
global RESET_TRCT_TIME;
ITVL_BT_OBS = 4;      % unit (minute)
RESET_TRCT_TIME = 80; % unit (minute)


% samples will be discarded if the difference (%) between two consecutive 
% o2/ar in air > AIR_O2AR_THR.
global AIR_O2AR_THR;
AIR_O2AR_THR = 2.0; % unit (%)


% truncate part of observations when measurements swith between air to water
% truncate 4 (6) minute for o2/ar in air (water) in the boundary region
global AIR_VALCO_SWCH_TRCT_TIME;
global WTR_VALCO_SWCH_TRCT_TIME;
AIR_VALCO_SWCH_TRCT_TIME = 4; % unit (minute)
WTR_VALCO_SWCH_TRCT_TIME = 6; % unit (minute)


% the range of O2/Ar in air, beyong which calibration fails
global O2AR_AIR_RNG;
O2AR_AIR_RNG = [15;25];


% The pressure range, beyond which calibration fails
global PRES;
global PRES_RNG;
PRES_RNG = [1e-6;9e-6];
PRES = [];


% show calibrated results
global DISP;
DISP = 1;


%% parse input parameters
is_success = 0;
if mod(varargin,2) ~= 0
    disp('Input parameters are inconsistent!');
    return;
end

if ~parse_para(varargin)
    return;
end


%% Data control
% discard samples with pressure beyond a given range.
if length(PRES) > 0
    if length(PRES) == length(o2ar)
        p_ind = PRES_RNG(2) < PRES | PRES < PRES_RNG(1);
        o2ar(p_ind) = NaN;
    else
        disp('o2ar and pressure has different length!');
        return;
    end
end



%% Find valco valve switching time
% label_swch=-1 indicates switch from water to air
% 1 indicates switch from air to water
valco_swch = diff(valco);
valco_swch_idx = find(valco_swch ~= 0);

% time interval for each measurement valco
tv(:,1) = [mdcdate(1);mdcdate(valco_swch_idx+1)]; % begin
tv(:,2) = [mdcdate(valco_swch_idx);mdcdate(end)]; % end

% index of air/water measurement segment
air_mea_seg_idx = find(valco_swch(valco_swch_idx) == 1);
wtr_mea_seg_idx = find(valco_swch(valco_swch_idx) == -1);


%% truncate boundary observations if time interval >ITVL_BT_OBS
time_dif = diff(mdcdate);
excd_obs_idx = find(time_dif > datenum(0,0,0,0,ITVL_BT_OBS,0));
excd_obs_idx = excd_obs_idx + 1;

for j = 1: length(excd_obs_idx)
    upper_bnd = mdcdate(excd_obs_idx(j)) + datenum(0,0,0,0,RESET_TRCT_TIME,0);
    idx = find(mdcdate < upper_bnd);
    delt_rng = excd_obs_idx(j): idx(end);
    o2ar(delt_rng) = NaN;
end


%% Find the air calibrations
% indices of o2/ar in air
air_idx = [];

% time and mean of o2/ar in air
air_time = [];
air_mean = [];

for j = 1: length(air_mea_seg_idx)
    tbot = tv(air_mea_seg_idx(j),1);
    ttop = tv(air_mea_seg_idx(j),2);
    
    % discard o2/ar in air in a time window of AIR_VALCO_SWCH_TRCT_TIME
    % to avoid artificial values
    air_low_bnd   = mdcdate > tbot + datenum(0,0,0,0,AIR_VALCO_SWCH_TRCT_TIME,0);
    air_upper_bnd = mdcdate < ttop - datenum(0,0,0,0,AIR_VALCO_SWCH_TRCT_TIME,0);
    air_rng_idx = find(air_low_bnd & air_upper_bnd);
    air_idx = [air_idx;air_rng_idx];
    
    % Time of air calibration
    air_time(j) = (tbot + ttop) ./ 2.0;
    
    % air mean value ("Warning: Divide by zero" may appear if no air o2ar values for the given time interval)
    air_mean(j) = nanmean(o2ar(air_rng_idx));  
end


%% Extract o2/ar measurements in water
% index of o2/ar in water
wtr_idx = [];

for j = 1: length(wtr_mea_seg_idx)
    tbot = tv(wtr_mea_seg_idx(j),1);
    ttop = tv(wtr_mea_seg_idx(j),2);
    
    % discard o2/ar in water in a time window of WTR_VALCO_SWCH_TRCT_TIME
    % to avoid artificial values
    wat_low_bnd   = mdcdate > tbot + datenum(0,0,0,0,WTR_VALCO_SWCH_TRCT_TIME,0);
    wat_upper_bnd = mdcdate < ttop - datenum(0,0,0,0,WTR_VALCO_SWCH_TRCT_TIME,0);
    wat_rng_idx = find(wat_low_bnd & wat_upper_bnd);
    wtr_idx = [wtr_idx;wat_rng_idx];  
end

% o2ar_w is the o2ar of the equilibrator, remove the air calibrations
o2ar_wtr = ones(length(o2ar),1) .* NaN;
o2ar_wtr(wtr_idx) = o2ar(wtr_idx);


%% Calibrate o2ar_w (o2ar of the water / o2ar of interpolated air)-1)*100
o2ar_air_itpl = []; % interpolated o2/ar in air
o2ar_wtr_clbt = []; % calibrated o2/ar in water
date_clbt = [];     % date of calibrated data

for j = 1: length(air_time) - 1
    % linearly interpolate o2ar in air
    calind = find(air_time(j) < mdcdate & mdcdate < air_time(j+1));
    o2ar_airinter = interp1(air_time(j:j+1),air_mean(j:j+1),mdcdate(calind),'linear','extrap');
    
    % calibrate o2ar in water, if the difference in o2ar 
    % of the two consecutive air calibrations is <AIR_O2AR_THR; otherwise
    % padded with NaN
    dif = diff(air_mean(j:j+1)) ./ air_mean(j) .* 100.0;
    if abs(dif) > AIR_O2AR_THR
        o2ar_cal = NaN .* ones(length(calind),1);
    else
        o2ar_cal = ((o2ar_wtr(calind)./o2ar_airinter)-1.0) .* 100.0;
    end
    
    % save results
    o2ar_air_itpl = [o2ar_air_itpl;o2ar_airinter];
    o2ar_wtr_clbt = [o2ar_wtr_clbt;o2ar_cal];
    date_clbt = [date_clbt;mdcdate(calind)];
end


%% Control O2/Ar in air
idx = O2AR_AIR_RNG(2) < o2ar_air_itpl | o2ar_air_itpl < O2AR_AIR_RNG(1);
o2ar_wtr_clbt(idx) = NaN;


%% organizing output
rs_o2ar_wtr_air = [date_clbt,o2ar_wtr_clbt,o2ar_air_itpl];
is_success = 1;

% show calibrated figure
if DISP
    fg_o2ar_clbt(rs_o2ar_wtr_air,mdcdate,o2ar,air_idx);
end

end





%% ------------------------------------------------------------------------
% parse input parameters
function [is_success] = parse_para(arg)
    global ITVL_BT_OBS;
    global RESET_TRCT_TIME;
    global AIR_O2AR_THR;
    global AIR_VALCO_SWCH_TRCT_TIME;
    global WTR_VALCO_SWCH_TRCT_TIME;
    global O2AR_AIR_RNG;
    global PRES;
    global PRES_RNG;
    global DISP;
    
    is_success = 1;
    for j = 1: 2: length(arg)
        if strcmp(arg{j},'ITVL_BT_OBS')
            ITVL_BT_OBS = arg{j+1};
        elseif strcmp(arg{j},'RESET_TRCT_TIME')
            RESET_TRCT_TIME = arg{j+1};
        elseif strcmp(arg{j},'AIR_O2AR_THR')
            AIR_O2AR_THR = arg{j+1};
        elseif strcmp(arg{j},'AIR_VALCO_SWCH_TRCT_TIME')
            AIR_VALCO_SWCH_TRCT_TIME = arg{j+1};
        elseif strcmp(arg{j},'WTR_VALCO_SWCH_TRCT_TIME')
            WTR_VALCO_SWCH_TRCT_TIME = arg{j+1};
        elseif strcmp(arg{j},'O2AR_AIR_RNG')
            O2AR_AIR_RNG = arg{j+1};
        elseif strcmp(arg{j},'PRES')
            PRES = arg{j+1};
        elseif strcmp(arg{j},'PRES_RNG')
            PRES_RNG = arg{j+1};
        elseif strcmp(arg{j},'display')
            if strcmp(arg{j},'on')
                DISP = 1;
            elseif strcmp(arg{j},'off')
                DISP = 0;
            end
        else
            is_success = 0;
            return;
        end 
    end
end



%% Show calibrated results
function [] = fg_o2ar_clbt(o2ar_wtr_air,mdcdate,o2ar,air_idx)
    % global variables
    global PRES;
    global PRES_RNG;
    
    % validate calibration
    idx = ~isnan(o2ar_wtr_air(:,2));

    % date
    mdcdate_org = mdcdate;
    mdcdate = o2ar_wtr_air(idx,1);
    date_calibrated = mdcdate;

    % interpolated o2/ar in air
    interpolated_o2ar = o2ar_wtr_air(idx,3);

    % o2/ar in water
    o2ar_w = o2ar(idx);

    % calibrated O2/ar in water
    o2ar_calibrated = o2ar_wtr_air(idx,2);
    o2ar_calibrated(~idx) = [];

    % pressure
    clbt_idx = [];
    if length(PRES) > 0
        [~,clbt_idx,~] = intersect(mdcdate_org,mdcdate);
        p = pres(clbt_idx);
    end


    %% show figures
    h = figure;
    if length(PRES) > 0
        ax(1) = subplot(3,1,1);
        plot(mdcdate,p,'.');
        %datetick('x',2)
        ylim(PRES_RNG);
        ylabel('Pressure');
        grid minor;
    end

    ax(2) = subplot(3,1,2);
    plot(mdcdate,o2ar_w,'.',mdcdate_org(air_idx),o2ar(air_idx),'ro',date_calibrated,interpolated_o2ar,'g.');
    ylabel('raw water O2Ar and interpolated air calibrations');
    grid minor;

    % zero line for the plot
    x = [mdcdate(1) mdcdate(length(mdcdate))];
    y = zeros(length(x),1);

    ax(3) = subplot(3,1,3);
    plot(x,y,'r',date_calibrated,o2ar_calibrated,'.')
    %datetick('x',6) 
    ylabel('calibrated O2/Ar')
    grid minor;
    linkaxes(ax,'x');
    set(gcf,'color','white');

    % calibrated o2/ar in water
    h = figure;
    plot(x,y,'r',date_calibrated,o2ar_calibrated,'.');
    ylabel('Biological O_2 supersaturation (%)');
    xlabel('Date');
    grid minor;
    datetick('x',6);
    ylim([min(o2ar_calibrated),max(o2ar_calibrated)]);
    xlim([date_calibrated(1)-datenum(0,0,1,0,0,0), date_calibrated(length(date_calibrated))+datenum(0,0,1,0,0,0)]);
    set(gcf,'color','white');
end



