%% Readme Order of scripts

%readshipdata.m (This script will vary depending on the format of the ship
%data)
    %reads in ship data in xls format and converts dates to datenum
    %data output: ship
    
%ship_2min.m 
    %loads ship and creates a new matrix with 2 min averaged ship data
    %data output: ship2min
    
%EIM_read_xlh
    %this script reads in EIMS data, creates one .mat file of
    %all 12 hr data chunks, and fixes the date so it is in matlab datenum
    %and set to UTC time
    %data output: eims
    
%O2Ar_AvgCalibMerge
    %calls on tavg,o2ar_cal and mergedata2 to get 2 min averaged,
    %calibrated o2ar data merged with your ship2min
    %data output: eims2min, o2ar, ship2min_o2ar
        
    