clear; clc; close all;
%% ************************************************************************
% L1 QMG 220  (h6 Triton.vi)	Device:	EIMS  (PTM28611-44508749)																											
% L2 MID	ParaFile:	Duke ratios.rcp																											
% L3																													
% L4																													
% L5																													
% L6	UTC offset (s)	-18000																											
% L7 All masses (amu) are displayed in (A)																													
% L8																													
% L9 1: cycle #	2: time	3: 18	4: 28	5: 32	6: 40	7: 44	8: 45	9: TP
% 10: N2/Ar	11: O2/Ar	12: N2/O2	13: Valve	14: ID	15: S#	16: O2 (uM)	
% 17: O2 Sat (%)	18: Temp (C)	19: Calphase (C)	20: TCphase (C)	
% 21: C1 (C)	22: C2 (C)	23: C1amp (mV)	24: C2amp (mV)	25: Temp (mV)	
% 26: inlet	27: sock	28: outlet	29: MS	30: flow
% *************************************************************************
%% Choose cruise data name to be saved
cruise=input('Cruise data saved as [.mat]... ','s');
%% Initialize variables.
filename = dir('*.xlh');
delimiter = '\t';
startRow = 10;

%% Format string for each line of text:
formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';

%% Load data files
tic
all=ones(1,30).*-999; % Dummy to initiate matrix
for i=1:length(filename);
   fname=filename(i).name; 
   fileID = fopen(fname,'r');
   dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);
   data=[dataArray{1:end-1}];
   fout=fname; disp(['Importing ',fout]); 
   all=[all; data];
end
all(1,:)=[]; % remove dummyline
toc

%% Close the text file.
fclose(fileID);

%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

%% Cut first column of cycle numbers and move it to 2nd column
cyclenum=all(:,1); 
all=[all(:,2) cyclenum all(:,3:30)];

all(:,1)=x2mdate(all(:,1),0); %convert excel date format to matlab date format

% Change quebec time to UTC time for ship data merge
% offset=(datenum(2014,8,3,5,0,0)-datenum(2014,8,3,0,0,0));
% all(:,1)=all(:,1)+offset;

assignin('base', sprintf('%s',cruise), all)
save(sprintf('%s.mat',cruise),sprintf('%s',cruise)); 