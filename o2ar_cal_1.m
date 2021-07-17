% function input: [filename,air_low,air_hi]
% function output: [date_calibrated,o2ar_calibrated]

function[S]=o2ar_cal(filename,air_low,air_hi);

%data=load(filename);
data=filename;
mdcdate=data(:,1);
o2ar=data(:,5)./data(:,6);
p=data(:,9);
v=data(:,13);

%If time average created strange valco position then round that value to
%nearest position
v=round(v);

%Find valco valve switching times
a=1;
for i=1:length(v)-1
    if v(i)~=v(i+1) & v
        tv(a)=mdcdate(i+1); 
        a=a+1;
    end
end

% figure
% plot(mdcdate,p,'.')

%**************************************************************************
% Remove o2ar that have too high or too low of a pressure (this is valid
% for both air calibrations and water measurements)

p_ind=find(p<1e-6 | p>9e-6);
o2ar(p_ind)=NaN;


% %**************************************************************************
% % Remove o2ar data which occurs after restarting the program. For some
% % reason, the o2ar is wrong when restarting the Quadstar software
% 
zz=-999;
for j=1:length(mdcdate)-1
    date1=mdcdate(j);
    date2=mdcdate(j+1);
    if date2-date1>datenum(0,0,0,0,4,0) %if the difference between 2 dates >4 minutes
        z=find(mdcdate>=date2 & mdcdate<date2+datenum(0,0,0,0,80,0)); % remove 80 minutes of data after switching on instrument
        o2ar(z)=NaN;
        zz=[zz;z];
    end
end
zz(1)=[];

%**************************************************************************
% Find the air calibrations within the mdc2min file , and create a vector
% that only has the water signal

a=0;
ind_air=1; % Initialize vector
ind_w=1; % Initialize vector, indices of air and water will be different to make sure they both do not capture the actifact of transition between the two

for i=1:length(tv)-1
    tbot=tv(i);
    ttop=tv(i+1);
    % Check that the difference is less than 1 hr, which implies air
    % calibration
    if (ttop-tbot)<datenum(0,0,0,1,0,0)
            a=a+1;
            % Add 4 minutes to the bottom time and remove 4 minutes to top
            % time to make sure the mean of air o2ar does not capture
            % transition artifact
            ind=find(mdcdate>(tbot+datenum(0,0,0,0,4,0)) & mdcdate<(ttop)-datenum(0,0,0,0,4,0)); 
            air_time(a)=(tbot+ttop)./2; % Time of air calibration
            air_mean(a)=nanmean(o2ar(ind)); %air mean value ("Warning: Divide by zero" may appear if no air o2ar values for the given time interval)
            
            % Remove 6 minutes to the bottom time and add 6 minutes to top
            % time to make sure the water o2ar does not capture
            % transition artifact
            indw=find(mdcdate>(tbot-datenum(0,0,0,0,6,0)) & mdcdate<(ttop)+datenum(0,0,0,0,6,0));
            
            ind_air=[ind_air;ind]; %Concatenate all indices for valco sampling air
            ind_w=[ind_w;indw];  % this vector of all indices will be used to remove air calibrations
    end        
end

o2ar_w=o2ar;
o2ar_w(ind_w)=NaN; %o2ar_w is the o2ar of the equilibrator, remove the air calibrations

%**************************************************************************

% Now interpolate the air_mean(a) and calculate the calibrated o2ar_w
% Where calibrated o2ar is the ((o2ar of the water / o2ar of
% interpolated air)-1)*100

clear i
o2ar_calibrated=-999; % Initialize vector
date_calibrated=-999;
interpolated_o2ar=-999;

for i=1:a-1
    t_calbot=air_time(i); % Time of bottom air calibration
    t_caltop=air_time(i+1); % Time of top air calibration (interpolation between these 2 points)
    calind=find(mdcdate>t_calbot & mdcdate<t_caltop); % find mdcdates that fall between these 2 air calibrations
  
    % o2ar of air interpolated is y, where y=mx+b, m is the slope, x is the
    % time change from the bottom calibration, and b is the o2ar of the
    % bottom air calibration
    delo2ar_time=(air_mean(i+1)-air_mean(i))./(t_caltop-t_calbot); %slope of o2ar_air between two points 
    o2ar_airinter=(mdcdate(calind)-t_calbot).*delo2ar_time+air_mean(i); % air o2/ar interpolated for the points between the two calibrations
    dat=mdcdate(calind);
    diff=((air_mean(i+1)-air_mean(i))./air_mean(i)).*100;
    
    % If the difference in o2ar of the two consecutive air calibrations is greater than
    % 2%, return -999 for all o2ar_w between these 2 calibration points
    
       if abs(diff)>2 % if difference is greater than 2%
        o2ar_cal=-999.*ones(length(calind),1);
       else
           o2ar_cal=((o2ar_w(calind)./o2ar_airinter)-1).*100; % o2ar of water calibrated in that interval;
       end
    interpolated_o2ar=[interpolated_o2ar;o2ar_airinter]; %Concatenate the interpolated o2ar of air (this is the o2ar of air interpolated to the point of water measurement, same size as air_calirated)
    date_calibrated=[date_calibrated;dat]; % Concatenate the dates of measurements kept
    o2ar_calibrated=[o2ar_calibrated;o2ar_cal]; % Concatenate the calibrated o2ar
end

%remove dummy first line
ind_air(1)=[];
interpolated_o2ar(1)=[];
date_calibrated(1)=[];
o2ar_calibrated(1)=[];
o2ar_calibrated(o2ar_calibrated==-999)=NaN;

% Find points where air calibrations are very different from expected value

x=find(interpolated_o2ar<air_low | interpolated_o2ar>air_hi);
o2ar_calibrated(x)=NaN;

%**************************************************************************
%**************************************************************************
% Figure of results
figure
ax(1)=subplot(3,1,1);
plot(mdcdate,p,'.')
%datetick('x',2)
ylim([1e-6 9e-6])
ylabel('Pressure')
grid minor

ax(2)=subplot(3,1,2);
plot(mdcdate,o2ar_w,'.',mdcdate(ind_air),o2ar(ind_air),'ro',date_calibrated,interpolated_o2ar,'g.')
ylabel('raw water O2Ar and interpolated air calibrations')
grid minor

% zero line for the plot
x=[mdcdate(1) mdcdate(length(mdcdate))];
y=zeros(length(x),1);

ax(3)=subplot(3,1,3);
plot(x,y,'r',date_calibrated,o2ar_calibrated,'.')
%datetick('x',6) 
ylabel('calibrated O2/Ar')
grid minor
linkaxes(ax,'x');
set(gcf,'color','white');


figure
plot(x,y,'r',date_calibrated,o2ar_calibrated,'.')
ylabel('Biological O_2 supersaturation (%)')
xlabel('Date')
grid minor
datetick('x',6) 
ylim([-5 25])
xlim([date_calibrated(1)-datenum(0,0,1,0,0,0), date_calibrated(length(date_calibrated))+datenum(0,0,1,0,0,0)])
set(gcf,'color','white');

S=[date_calibrated,o2ar_calibrated];


%save('o2ar_FINAL', 'o2ar')

% % figure
% % subplot(2,1,1)
% % % zero line
% % x=[mdcdate(1) mdcdate(length(mdcdate))];
% % y=zeros(length(x),1);
% % plot(x,y,mdcdate,((o2ar_w./22)-1).*100,'.',mdcdate(ind_air),((o2ar(ind_air)./22)-1).*100,'ro',date_calibrated,((interpolated_o2ar./22)-1).*100,'g.',date_calibrated,o2ar_calibrated,'k.')
% % datetick('x',2)
% % subplot(2,1,2)
% % plot(date_calibrated,o2ar_calibrated,'.')
% % datetick('x',2)  
% % 
