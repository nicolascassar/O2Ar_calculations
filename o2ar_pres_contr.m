function [o2ar] = o2ar_pres_contr(o2ar,pres,varargin)
%
% control the o2ar measurements within a range of pressure
%
%
% Input
% 
% o2ar: o2ar measurements
% pres: pressure
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
% pressure range, beyond which observation is discarded
PRES_RNG = [1e-6;9e-6];


%% Remove o2ar that have too high or too low of a pressure (this is valid
% for both air calibrations and water measurements)
p_ind = PRES_RNG(2) < pres | pres < PRES_RNG(1);
o2ar(p_ind) = NaN;



