function [out]= tavg(tav,unit,data)
%
% Usage: output = tavg(tav,unit,data)
%
%     tav  = number of minutes etc over which to average
%     unit = unit of time for tav (i.e. 'year','month','day','hour','minute','second')
%     data = 2D matrix of data to average with time in days. First column is time in 
%            fraction of days (see matlab routine datenum) though the
%            records don't have to be in order. The following columns
%            contain the data 
%     out  = output file in the same format as data except the records are
%            in order (increasing in time) and averaged over the time
%            periods tav. Any periods with missing data are ignored.
%
% Averaging is a simple non-weighted average. i.e. if there are 3 readings
% within the time period then the average is simply 1/3 of the sum,
% ignoring irregular times between readings.
%
% Times for the output data (first column of out) are in the middle of each
% averaging period, and the averaging periods start from the earliest time
% in the data set
%

% Get size of data set
[nt nvar] = size(data);   % nt is number of time records
nvar=nvar-1;               % nvar is number of data columns  

% Set the time period for averaging
if unit(1:3) == 'yea'
    year = tav;
else 
    year = 0;
end
if unit(1:3) == 'mon'
    month = tav;
else 
    month = 0;
end
if unit(1:3) == 'day'
    day = tav;
else 
    day = 0;
end
if unit(1:3) == 'hou'
    hour = tav;
else 
    hour = 0;
end
if unit(1:3) == 'min'
    minute = tav;
else 
    minute = 0;
end
if unit(1:3) == 'sec'
    second = tav;
else 
    second = 0;
end
dtvector = [year month day hour minute second];
dt = datenum(dtvector);   % this is the time period for averaging in fractions of days

data=sortrows(data);      % Makes sure data is in order with time increasing downwards

date = data(:,1);            % first column is data
tot_time = date(nt)-date(1); % total time of data set
nt_out = fix(tot_time/dt);   % number of time records for output

out=[];
for j=1:nt_out               % for each of the averaging time slots
    datbot = date(1) + dt*(j-1.0);     % define limits of time slot
    dattop = date(1) + dt*j;
    sum=0.0;
    outsum=zeros(1,nvar);
    for j2 = 1:nt               
        if (date(j2)>=datbot) & (date(j2)<dattop) % search in data for records in this time slot
            for i=1:nvar
                outsum(1,i) = outsum(1,i) + data(j2,i+1);  % sum records...
            end
            sum = sum+1.0;                                 % ... and keep record of how many there are
        end
    end
    if (sum~=0)              % if there are no records within this time slot, don't use it
       for i=1:nvar
        outsum2(1,i) = outsum(1,i)/sum; % average
       end
       tmp = [0.5*(dattop+datbot) outsum2];
       out = [out' tmp']';   % if there are records, add this time slot to output
    end
end    

     