% Run from repository root after addpath(fullfile(pwd,'src')).
optical=fullfile('data','monthly_Kd490_Zeu_ZSD.csv');
sample=false;
if ~isfile(optical)
    optical=fullfile('examples','fixtures','monthly_Kd490_Zeu_ZSD.csv');
    sample=true;
    fprintf('Using the 25-row sample optical file.\n');
end
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
if ~sample
    if ~isfolder('output'), mkdir('output'); end
    writetable(T,fullfile('output','monthly_surface_carbon.csv'));
    fprintf('Saved output/monthly_surface_carbon.csv\n');
end
cbpmFile=fullfile('data','CbPM_surface_only.csv');
if isfile(cbpmFile)
    C=npsg_cbpm_surface(cbpmFile);
    fprintf('CbPM monthly series: %d months; showing the first five.\n',height(C));
    disp(C(1:min(5,height(C)),{'Year','Month','bbp443', ...
        'Cphyto','chlC_obs'}));
    if ~isfolder('output'), mkdir('output'); end
    writetable(C,fullfile('output','CbPM_surface_with_carbon.csv'));
end
