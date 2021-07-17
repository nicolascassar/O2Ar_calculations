function [o2ar] = o2ar_air_o2ar_contr(o2ar,o2ar_air,air_low,air_hi)
%
% control the o2ar measurements within a range of o2ar measurement in air
%
%
% Input
% 
% o2ar: o2ar measurements in water
% o2ar_air: o2ar measurements in air
% air_low:
% air_hi:
%
% End
%
%
% Out
%
% o2ar: filtered o2ar measurements
%
% End
%
%
% NOTE
%
% 1. value out of given range of pressure will be given NaN
%
% END
%
%
% History
% End
%
%
% Authors: Nicolas Cassar, Zuchuan Li
% Date: 03/11/2015
%
%% Some constants
idx = air_hi < o2ar_air | o2ar_air < air_low;
o2ar(idx) = NaN;


