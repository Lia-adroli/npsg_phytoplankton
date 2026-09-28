% Set ERSST_V6_DIR to the folder with 324 monthly NOAA ERSSTv6 files.
ersst_folder=getenv('ERSST_V6_DIR');
assert(isfolder(ersst_folder), ...
    'Set ERSST_V6_DIR to your NOAA ERSSTv6 NetCDF folder.');
S=npsg_ersst_v6(ersst_folder);
if ~isfolder('output'), mkdir('output'); end
writetable(S.monthly,fullfile('output','ersstv6_roi_monthly.csv'));
writetable(S.annual,fullfile('output','ersstv6_roi_annual.csv'));
writetable(S.gridTrend,fullfile('output','ersstv6_native_grid_trend.csv'));
disp(S.roiTrend)
