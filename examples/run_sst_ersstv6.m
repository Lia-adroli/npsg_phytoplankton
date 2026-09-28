% Set this before running:
% setenv('ERSST_V6_DIR','path to your ERSSTv6 NetCDF folder')

ersst_folder = getenv('ERSST_V6_DIR');
assert(isfolder(ersst_folder), ...
    'Set ERSST_V6_DIR to the folder containing ersst.v6.YYYYMM.nc files.');

S = npsg_ersst_v6(ersst_folder);

if ~isfolder('output')
    mkdir('output');
end

writetable(S.monthly,fullfile('output','ersstv6_roi_monthly.csv'));
writetable(S.annual,fullfile('output','ersstv6_roi_annual.csv'));
writetable(S.gridTrend,fullfile('output','ersstv6_native_grid_trend.csv'));

disp(S.roiTrend)
