function [ncp,wpv] = o2ar_ncp(o2ar,temp,mld,salt,ws,alg_id)
%
% This function calculation biological flux from O2/Ar measurements
%
%
% Input
%
% O2Ar: O2/Ar measurement with units of %; in column order
%
% temp: temperature; in column order
%
% mld: mixed layer depth; in column order
%
% ws: wind speed from previous to current in column order(i.e. -60,-59,...,-1,0);
%     each row is an observations, each column is the wind speed for a
%     given day.
%
% alg_id: the id for algorithms with the option of:
% 1: (Wanninkhof, 1992)
% 2: (Wanninkhof and McGillis 1999), 
% 3: (Ho et al. 2006),
% 4: (Nightingale et al 2000);
% 5: (Sweeney et al 2007)
%
% End Input
%
%
% Output
%
% ncp: net community production with units of mmol O2 m-2 day-1;
%
% End Output
%
%
% History
%
% 1. Take into account the case of using only instantaneous wind speed
%    Zuchuan Li    11/6/2013
%
% End
%
%
% Author: Zuchuan Li
% Date  : 9/9/2013
%

% sampleNum: number of samples
% ws_day_num: number of days for time series
[sampleNum,ws_day_num] = size(ws);
o2ar = o2ar(:);
temp = temp(:);
mld  = mld(:);
salt = salt(:);


%% constants for Schmidt number calculation (Wanninkhof, 1992)
a = 1953.4;
b = 128.00;
c = 3.9918;
d = 0.050091;
sc = a - b.*temp + c.* (temp.^2) - d.* (temp.^3); 

%quadratic relationship (Equation 3 of Wanninkhov 1992)
scmat = repmat(sc,1,ws_day_num);

pvmat = [];
if alg_id == 1
    pvmat = 0.074.*(ws.^2).*((scmat/660).^-0.5); % units of m/d
elseif alg_id == 2
    pvmat = 0.0068.*(ws.^3).*((scmat/660).^-0.5); % units of m/d
elseif alg_id == 3
    pvmat = 0.061.*(ws.^2).*((scmat/660).^-0.5); % units of m/d
elseif alg_id == 4
    pvmat = (0.053.*(ws.^2)+0.024.*ws).*((scmat/660).^-0.5); % units of m/d
elseif alg_id == 5
    pvmat = 0.065.*(ws.^2).*((scmat/660).^-0.5); % units of m/d
else
    disp('alg_id ranges from 1 to 5!');
    ncp = [];
    return;
end


%% calculating gas exchange rate weight for a time series through Reuer et
% al. (2007).
if length(mld) == sampleNum
    zmixmat = repmat(mld,1,ws_day_num);
elseif length(mld) == 1 % using a constant mld
    zmixmat = repmat(mld,sampleNum,ws_day_num);
else
    disp('Input inconsistent between MLD and other observations!');
    return;
end
fvent = pvmat ./ zmixmat;

weights = ones(sampleNum,ws_day_num);
for j = ws_day_num-1: -1: 1
    weights(:,j) = weights(:,j+1) .* (1-fvent(:,j+1));
end

wpv = [];
if ws_day_num > 1
    wpv = sum(weights.*pvmat,2) ./ sum(weights,2) ./ (1-weights(:,1));
else % using instantaneous wind speed
    wpv = pvmat;
end


%% calculating NCP from O2/Ar
% NCP in mmol m-2 d-1; seawater density in kg m-3, O2sol in microL kg-1
ncp = (o2ar./100) .* (O2sol(salt,temp)./1000) .* sw_dens0(salt,temp) .* wpv;




