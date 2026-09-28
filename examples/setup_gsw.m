function setup_gsw(gswFolder)
%SETUP_GSW Add a locally extracted TEOS-10 MATLAB toolbox to MATLAB path.
% Example: setup_gsw('PATH_TO_EXTRACTED_GSW_TOOLBOX')
if ~isfolder(gswFolder), error('GSW folder not found: %s',gswFolder); end
addpath(genpath(gswFolder));
rehash toolboxcache;
required={'gsw_SA_from_SP','gsw_CT_from_t','gsw_sigma0', ...
    'gsw_z_from_p','gsw_O2sol','gsw_rho'};
for k=1:numel(required)
    if exist(required{k},'file')~=2
        error('Missing GSW function %s: fully extract the toolbox.',required{k});
    end
end
fprintf('TEOS-10 GSW toolbox loaded.\n');
end
