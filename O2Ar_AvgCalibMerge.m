%% O2Ar_AvgCalibMerge 
% 2 Min Avg of EIMS data
% Calibrate O2/Ar
% Merge O2/Ar with ship data
clear
load eimsAN14;

%% EIMS 2 min avg
eims=eimsAN14;
firstdate=eims(1,1);
fake=minute(firstdate);
if mod(fake,2)==0 % Determines whether fake is odd or even number
    fake=fake-1; % If even, removes 1 to make it an odd number
end
fakedate=datenum(year(firstdate),month(firstdate), day(firstdate),hour(firstdate),fake,0);

eims2=[eims(1,:); eims]; % Duplicate first row
eims2(1,1)=fakedate; % replace first date with fake even flush date
clear eims fake fakedate firstdate %otherwise run out of memory
avgd = tavg(2,'minute',eims2);
eims2minAN14=avgd;
save('eims2minAN14.mat','eims2minAN14');

% Valco valve switching having problems with the strang valvo valve
% position. 

%% Calibrate O2/Ar based on eims2min
o2arAN14=o2ar_cal(eims2minAN14,15,25);
save('o2arAN14.mat','o2arAN14');

%% Merge with ship data
clear
load o2arAN14;
load ship2minAN14; 

%merge with O2ar data
ship2minAN14_o2ar=mergedata2(ship2minAN14,o2arAN14);
ship2minAN14_o2ar(ship2minAN14_o2ar(:,11)==0,11)=NaN; %Nan points where ship data but no O2Ar
ship2minAN14_o2ar(ship2minAN14_o2ar(:,2)==0,2:10)=NaN; %If no lat assume no ship data and fill with NaNs

save('ship2minAN14_o2ar.mat','ship2minAN14_o2ar')
