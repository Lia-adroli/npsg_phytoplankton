% Run from repository root after addpath(fullfile(pwd,'src')).
optical=fullfile('data','monthly_Kd490_Zeu_ZSD.csv');
assert(isfile(optical),'Place monthly_Kd490_Zeu_ZSD.csv in data/.');
daily=fullfile('data','daily_mean.csv');
if isfile(daily)
    T=npsg_surface_products(optical,daily);
else
    T=npsg_surface_products(optical);
    fprintf('daily_mean.csv absent: Chl:C remains NaN.\n');
end
fprintf('Optical monthly series: %d months; showing the first five.\n',height(T));
disp(T(1:min(5,height(T)),{'Date','bbp443','Cphyto_mgC_m3', ...
    'chl_monthly','Chl_to_C_mg_mg'}));
if ~isfolder('output'), mkdir('output'); end
writetable(T,fullfile('output','monthly_surface_carbon.csv'));
fprintf('Saved output/monthly_surface_carbon.csv\n');
cbpmFile=fullfile('data','CbPM_surface_only.csv');
assert(isfile(cbpmFile),'Place CbPM_surface_only.csv in data/.');
C=npsg_cbpm_surface(cbpmFile);
fprintf('CbPM monthly series: %d months; showing the first five.\n',height(C));
disp(C(1:min(5,height(C)),{'Year','Month','bbp443', ...
    'Cphyto','chlC_obs'}));
writetable(C,fullfile('output','CbPM_surface_with_carbon.csv'));
