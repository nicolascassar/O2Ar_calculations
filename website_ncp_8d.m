function [] = website_ncp_8d(yr, path)
%
% produce 8-day satellite data for website 
%
%
% History
%
% 1. Keep product from algorithms of SVR and GP
%    Authors: Zuchuan Li  Date: 05/30/2017
%
% End
%
%
% Copy right
%
% Cassar Lab
% Earth & Ocean Sciences,
% Nicholas School of the Environment
% Duke University
%
% End
%
%
% Author: Zuchuan Li
% Date: 10/26/2015
%
%% some constants
% package of NCP algorithm
addpath('../NCP-Global');


% names of algorithms
% thses names are used as folder in sharing data
% so, just make sure that the name is what you want
folder = {'Eppley and Peterson 1979',...
          'Betzer et al. 1984',...
          'Baines et al. 1994',...
          'Laws et al. 2000',...
          'Laws et al. 2011',...
          'Dunne et al. 2005',...
          'Westberry et al. 2012',...
          'GP',...
          'SVR'};

% number of days coverage for a 8 days products
dys_8d = [ones(45, 1) .* 8; 5];
if mod(yr, 4) == 0
    dys_8d(end) = 6;
end


% 9km image size
rrs_nrow = 2160;
rrs_ncol = 4320;
sst_nrow = 2048;
sst_ncol = 4096;

% spatial resoltion
sp_res = 9;
SENSOR = 'SeaWiFS';


% data folder
npp_path = 'D:\1-Project\2-NCP\2-Data\recal_chl_npp';
sst_path = 'D:\2-Data\8-SST\8-day-2048-4096-AVHRR';
chl_path = 'D:\1-Project\2-NCP\2-Data\recal_chl_npp';
cur_path = pwd;


%% create folder for each year
for j = 1: length(folder)
    tmp = [path, '\', SENSOR, '\', folder{j}, '\', num2str(sp_res), 'km\8-day'];
    if exist([tmp, '\', num2str(yr)], 'dir')
        rmdir([tmp, '\', num2str(yr)], 's');
    end
    if ~exist([tmp, '\', num2str(yr)], 'dir')
        mkdir([tmp, '\', num2str(yr)]);
    end
end



%% list all data files
nppfile = dir([npp_path, '\npp.', num2str(yr), '*']);
sstfile = dir([sst_path, '\sst.', num2str(yr), '*.gz']);
chlfile = dir([chl_path, '\chl.', num2str(yr), '*']);

% loading annual npp
load(['../../2-Data/recal_chl_npp/a.npp.', num2str(yr), '.mat']);


%% export production with each column calculated by different algorithms
ep = zeros(rrs_nrow .* rrs_ncol, length(folder));



%% Eppley and Peterson (1979)
ef_eppley = ER_Eppley(npp_ann);



%% calculate 8-day average NCP
for j = 1: length(dys_8d)
    disp(j);
    
    %% Chl
    filename = [chl_path, '\', chlfile(j).name];
    load(filename);
    chl = chl(:);
    
    
    %% euphotic depth
    z_eu = euphotic_depth(chl);
    
    
    %% npp
    filename = [npp_path, '\', nppfile(j).name];
    load(filename);
    npp = npp(:);
    
    
    %% SST
    filename = [sst_path, '\', sstfile(j).name];
    
    % uzip sst
    cd(sst_path);
    if ~exist(filename(1:end-3), 'file')
        system(['7z e ', filename]);
    end
    cd(cur_path);
    
    filename = filename(1:end-3);
    data = hdfread(filename, '/sst', 'Index',{[1,1],[1,1],[sst_nrow,sst_ncol]});
    delete(filename);
    
    sst = imresize(data,[rrs_nrow, rrs_ncol]);
    sst = sst(:);
    sst(sst < -2.0 | sst > 32) = nan;
    
    
    %% Eppley and Peterson (1979)
    ep(:, 1) = ef_eppley .* npp;
    idx = ep(:, 1) < 0 | isnan(ep(:, 1)) | ...
          npp < 0 | npp_ann < 0 | ...
          ef_eppley < 0 | ef_eppley > 1;
    ep(idx, 1) = -999;
    
    
    %% Betzer et al. (1984)
    pe_ratio = ER_Betzer(npp_ann, z_eu);
    
    % delete invalidate pixels
    idx = pe_ratio > 1 | pe_ratio < 0 | isnan(pe_ratio) | ...
          npp_ann <= 0 | npp <= 0 | ...
          z_eu < 0 | chl <= 0;
    
    % annual value
    ep(:, 2) = pe_ratio .* npp;
    ep(idx, 2) = -999;
    
    
    %% Baines et al. (1994)
    pe_ratio = ER_Baines(chl);
    
    % pad invalidate pixels
    idx = pe_ratio > 1 | pe_ratio < 0 | isnan(pe_ratio) | ...
          npp <= 0 | chl <= 0;
    
    % annual value
    ep(:, 3) = pe_ratio .* npp;
    ep(idx, 3) = -999;
    
    
    %% Laws et al. (2000)
    % According to Laws et al (2000) C:N ratio of 5.7 by weight
    % Redfeld ratio C:N:P = 106:16:1
    % transform from (mg C m-2 day-1) to (mg N m-2 day-1)
    nitro_npp = npp ./ 5.7;

    % transform NPP to mass (mg N m-3 day-1) by divding euphotic zone depth
    % refer to VGPM and CbPM code
    nitro_npp = nitro_npp ./ z_eu;
    
    % Laws 2000
    idx = nitro_npp < 0 | isnan(sst);
    sst(idx) = 0;
    nitro_npp(idx) = 0;
    ef_ratio = ER_Laws(double(sst), double(nitro_npp));
    
    % pad invalidate pixels
    idx = isnan(ef_ratio) | ef_ratio > 1 | ef_ratio < 0 | ...
          npp <= 0 | chl <= 0 | ...
          isnan(sst) | z_eu <= 0;
    
    % annual value
    ep(:, 4) = npp .* ef_ratio;
    ep(idx, 4) = -999;


    %% equation (3)
    ef_ratio = ER_Laws_2011(sst, npp, 3);
    
    % pad invalidate pixels
    idx = isnan(ef_ratio) | ef_ratio > 1 | ef_ratio < 0 | ...
          npp <= 0 | chl <= 0 | ...
          isnan(sst);
    
    % annual value
    ep(:, 5) = npp .* ef_ratio;
    ep(idx, 5) = -999;


    %% Dunne et al. (2005)
    pe_ratio = ER_Dunne(sst, chl);
    
    % pad invalidate pixels
    idx = isnan(pe_ratio) | pe_ratio > 1 | pe_ratio < 0 | ...
          npp <= 0 | chl <= 0 | ...
          isnan(sst);
    
    % annual value
    ep(:, 6) = pe_ratio .* npp;
    ep(idx, 6) = -999;


    %% Westberry et al. (2013)
    % npp from (mg C m-2 d-1) to (mmol O2 m-2 d-1)
    npp_o2 = npp ./ 12.0107 .* 1.4;

    % npp from (mmol O2 m-2 d-1) to (mmol O2 m-3 d-1)
    npp_o2 = npp_o2 ./ z_eu;

    ncp = NCP_Westberry(npp_o2);
    ncp = ncp .* z_eu;
    
    % pad invalidate pixels
    idx = isnan(ncp) | ...
          npp <= 0 | chl <= 0 | ...
          z_eu <= 0;
    ep(:, 7) = ncp ./ 1.4 .* 12.0107;
    ep(idx, 7) = -999;


    %% Genetic programming
    % complexity of 6
    ncp = npp ./ (18.8 + sst);
    
    % pad invalidate pixels
    idx = isnan(ncp) | ncp < 0 | ...
          npp <= 0 | chl <= 0 | ...
          isnan(sst);
    ep(:, 8) = ncp ./ 1.4 .* 12.0107;
    ep(idx, 8) = -999;
    
    
    %% Support vector regression
    idx = npp > 0 & (~isnan(sst)) & chl > 0;
    X = [sst, log(npp)];
    ncp = exp(NCP_SVR_predict(X(idx, :)));
    
    ep(idx, 9) = ncp ./ 1.4 .* 12.0107;
    ep(~idx, 9) = -999;
    
    
    %% save data
    dy_bg = 1;
    if j > 1
        dy_bg = sum(dys_8d(1: j-1)) + 1;
    end
    dy_ed = sum(dys_8d(1: j));
    
    dy_bg_str = day2str(dy_bg, 3);
    dy_ed_str = day2str(dy_ed, 3);
    
    for k = 1: size(ep, 2)
        fname = ['S', num2str(yr), dy_bg_str, num2str(yr), dy_ed_str, '.hdf'];
        ncp = reshape(ep(:, k), rrs_nrow, rrs_ncol);
        save_ncp(folder{k}, ncp, fname, path, sp_res, [yr, dy_bg, dy_ed], SENSOR);
    end
end



end



%% save NCP
function [] = save_ncp(alg_name, ncp, fname, folder, sp_res, tmp_rng, ss_name)
    % resolution
    row = 2160;
    col = 4320;
    sp_res_deg = 0.0833;
    if sp_res == 4
        row = 4320;
        col = 8640;
        sp_res_deg = sp_res_deg ./ 2.0;
    end
    
    %% create file
    import matlab.io.hdf4.*
    sdID = sd.start(fname, 'create');
    ds_name = 'export';
    sdsID = sd.create(sdID, ds_name, 'double', size(ncp));
    
    % write data
    sd.writeData(sdsID, [0, 0], ncp);
    
    % file attributes
    sd.setAttr(sdID, 'Processing time', datestr(now));
    sd.setAttr(sdID, 'algorithm', alg_name);
    sd.setAttr(sdID, 'Latitude Step', sp_res_deg);
    sd.setAttr(sdID, 'Longitude Step', sp_res_deg);
    sd.setAttr(sdID, 'Sensor Name', ss_name);
    sd.setAttr(sdID, 'Projection Name', 'Equidistant Cylindrical');
    sd.setAttr(sdID, 'Latitude Center', 0);
    sd.setAttr(sdID, 'Longitude Center', 0);
    sd.setAttr(sdID, 'Latitude range', [90, -90]);
    sd.setAttr(sdID, 'Longtitude range', [-180,180]);
    sd.setAttr(sdID, 'Number of lines', row);
    sd.setAttr(sdID, 'Number of columns', col);
    sd.setAttr(sdID, 'Period start year', tmp_rng(1));
    sd.setAttr(sdID, 'Period start day', tmp_rng(2));
    sd.setAttr(sdID, 'Period end year', tmp_rng(1));
    sd.setAttr(sdID, 'Period end day', tmp_rng(3));
    
    % data attributes
    sd.setAttr(sdsID, 'units', 'mg C m-2 day-1');
    sd.setAttr(sdsID, 'Scaling', 'Linear');
    sd.setAttr(sdsID, 'Slope', 1);
    sd.setAttr(sdsID, 'Intercept', 0);
    sd.setAttr(sdsID, 'Padded value', -999);
    
    % close data file
    sd.endAccess(sdsID);
    sd.close(sdID);
    
    %% zip file
    system(['7z a ', fname, '.bz2 ', fname]);
    
    
    %% move to box for sharing
    path = [folder, '\', ss_name, '\', alg_name, '\', num2str(sp_res), ...
            'km\8-day\', num2str(tmp_rng(1))];
    copyfile([fname,'.bz2'], path);
    
    
    %% clean
    delete(fname);
    delete([fname,'.bz2']);
end













