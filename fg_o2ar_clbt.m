function [] = fg_o2ar_clbt(o2ar_clbt,mdcdate,o2ar_wtr_air,o2ar,pres)
%
% show the calibrated results
%
%
% Input
%
% o2ar_clbt: calibrated O2/ar observations
% mdcdate: the date of observations
% o2ar_wtr_air:
% o2ar: original o2ar observations
% pres: original pressure data
%
% End
%
%
% Output
%
% End
%
%
% History
%
% 1. revised by Zuchuan Li 03/16/2015
%
% End
%
%
% Authors: Nicolas Cassar
%

%% Extract some variables
idx = ~isnan(o2ar_clbt);

% date
mdcdate_org = mdcdate;
mdcdate = o2ar_wtr_air(idx,1);
date_calibrated = mdcdate;

% interpolated o2/ar in air
interpolated_o2ar = o2ar_wtr_air(idx,3);

% o2/ar in water
o2ar_w = o2ar(idx);

% calibrated O2/ar in water
o2ar_calibrated = o2ar_clbt;
o2ar_calibrated(~idx) = [];

% pressure
[~,clbt_idx,~] = intersect(mdcdate_org,mdcdate);
p = pres(clbt_idx);


%% show figures
h = figure;
ax(1)=subplot(3,1,1);
plot(mdcdate,p,'.');
%datetick('x',2)
ylim([1e-6 9e-6]);
ylabel('Pressure');
grid minor;

ax(2)=subplot(3,1,2);
plot(mdcdate,o2ar_w,'.',mdcdate_org(air_idx),o2ar(air_idx),'ro',date_calibrated,interpolated_o2ar,'g.');
ylabel('raw water O2Ar and interpolated air calibrations');
grid minor;

% zero line for the plot
x=[mdcdate(1) mdcdate(length(mdcdate))];
y=zeros(length(x),1);

ax(3)=subplot(3,1,3);
plot(x,y,'r',date_calibrated,o2ar_calibrated,'.')
%datetick('x',6) 
ylabel('calibrated O2/Ar')
grid minor;
linkaxes(ax,'x');
set(gcf,'color','white');


h = figure;
plot(x,y,'r',date_calibrated,o2ar_calibrated,'.');
ylabel('Biological O_2 supersaturation (%)');
xlabel('Date');
grid minor;
datetick('x',6);
ylim([-5 25]);
xlim([date_calibrated(1)-datenum(0,0,1,0,0,0), date_calibrated(length(date_calibrated))+datenum(0,0,1,0,0,0)]);
set(gcf,'color','white');



