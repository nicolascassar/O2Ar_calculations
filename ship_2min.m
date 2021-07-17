% 2 minute average of the data
clear
clc
load shipraw.mat

% data format is  ship=[dat,lat,lon,cdom,fluo1,fluo2,pH,phycocyanin,S,S_keel,turb,temp,temp_keel,temp_weather,depth,wd,wd_weather,ws,ws_weather,ws_beaufort,P,T_air];
shipdate=ship(:,1);
ship(:,1)=shipdate;

tic

%___________________________________________________________
%o2ar=mdc(:,5)./mdc(:,6); % Does not make difference whether take ratio and
%average or average of the ratio.

%mdc2=[mdc o2ar];
%mdcshort=mdc(1:100:length(mdc),:);
%___________________________________________________________

% In order for the averages to be flush on 2 minutes (e.g. 12:22:00am,
% 12:22:00am
% instead of 12:22:34, 12:24:34,...), create fake first value which ends in
% a flush odd minute (with odd, tavg will average on middle minute, e.g.
% 10:23:00 and 10:25:00 is averaged to 10:24:00)

firstdate=ship(1,1);
fake=minute(firstdate);
if mod(fake,2)==0 % Determines whether fake is odd or even number
    fake=fake-1; % If even, removes 1 to make it an odd number
end
fakedate=datenum(year(firstdate),month(firstdate), day(firstdate),hour(firstdate),fake,0);

ship2=[ship(1,:); ship]; % Duplicate first row
ship2(1,1)=fakedate; % replace first date with fake even flush date
clear ship fake fakedate firstdate %otherwise run out of memory
avgd = tavg(2,'minute',ship2);
ship2min=avgd;
save('ship2min', 'ship2min')
toc

