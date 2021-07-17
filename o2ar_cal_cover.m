function [] = o2ar_cal_cover()
%
% A container of o2ar calibration
% this is an example of processing eimsAN14 data from Rachel
%
% Date: 03/11/2015

%% load data
load eimsAN14;


%% EIMS 2 min avg
eims = eimsAN14;
firstdate = eims(1,1);
fake = minute(firstdate);
if mod(fake,2) == 0 % Determines whether fake is odd or even number
    fake = fake-1; % If even, removes 1 to make it an odd number
end
fakedate = datenum(year(firstdate),month(firstdate), day(firstdate),hour(firstdate),fake,0);

eims2=[eims(1,:); eims]; % Duplicate first row
eims2(1,1)=fakedate; % replace first date with fake even flush date
clear eims fake fakedate firstdate %otherwise run out of memory


%% NOTE: o2ar_cal uses 1=o2/ar in air, 2=o2/ar in water
% So, data should be consistent!!!
valco = eims2(:,valco_idx);


%% 2 minute average
dif = diff(valco);
idx = find(dif ~= 0);
idx = [0;idx;length(valco)];

avgd = [];
for j = 1: length(idx)-1
    row_rng = idx(j)+1: idx(j+1);
    tmp = tavg(2,'minute',eims2(row_rng,:));
    avgd = [avgd;tmp];
end


%% Extract data
% the column index depends on data
o2ar = avgd(:,o2ar_idx);
pres = avgd(:,pres_idx);
mdcdate = avgd(:,date_idx);
valco = avgd(:,valco_idx); % after averaged


%% Calibrate O2/Ar based on eims2min
[o2ar_wtr_air,air_idx,is_success] = o2ar_cal(o2ar,mdcdate,valco,'PRES',pres);
if is_success
    disp('calibrate success!');
else
    disp('calibrate fail!');
end








