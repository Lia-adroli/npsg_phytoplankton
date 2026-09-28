% Change only this path to your 324 NOAA ERSSTv6 monthly NetCDF files.
ersst_folder='G:\New folder\ersst_v6_data';
S=npsg_ersst_v6(ersst_folder);
if ~isfolder('output'), mkdir('output'); end
writetable(S.monthly,fullfile('output','ersstv6_roi_monthly.csv'));
writetable(S.annual,fullfile('output','ersstv6_roi_annual.csv'));
writetable(S.gridTrend,fullfile('output','ersstv6_native_grid_trend.csv'));
disp(S.roiTrend)
