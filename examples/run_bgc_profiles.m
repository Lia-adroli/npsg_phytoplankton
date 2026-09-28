% Full BGC outputs from the author's adjusted-value CSV.
file=fullfile('data','Final_BGC_Argo_All_Depth_Rows_With_Adjusted.csv');
assert(isfile(file),'Missing %s',file);
assert(exist('gsw_z_from_p','file')==2 && exist('gsw_O2sol','file')==2, ...
    'Run setup_gsw before BGC profiles.');
if ~isfolder('output'), mkdir('output'); end
fprintf('Reading BGC rows...\n'); raw=readtable(file,'VariableNamingRule','preserve');
years=[2016 2017 2020 2021 2022 2023 2024];
[chl,chlInfo]=npsg_bgc_filter(raw,'CHLA',years,5,10);
[bbp,bbpInfo]=npsg_bgc_filter(raw,'BBP700',years,5,10);
[oxygen,oxygenInfo]=npsg_bgc_filter(raw,'DOXY',years,5,10);
disp(chlInfo); disp(bbpInfo); disp(oxygenInfo);
if ~isempty(chl)
    chl.Depth_m=-gsw_z_from_p(chl.Pressure_dbar,chl.Latitude);
    [monthlyDCM,annualDCM]=npsg_dcm_series(table(chl.Year,chl.Month, ...
        chl.Depth_m,chl.Value,'VariableNames',{'Year','Month','Depth_m','Value'}));
    if ~isempty(monthlyDCM), writetable(monthlyDCM,fullfile('output','bgc_monthly_dcm.csv')); end
    if ~isempty(annualDCM), writetable(annualDCM,fullfile('output','bgc_annual_dcm.csv')); end
end
if ~isempty(bbp)
    [carbon,bbp470]=npsg_profile_carbon(bbp.Value);
    bbp.Depth_m=-gsw_z_from_p(bbp.Pressure_dbar,bbp.Latitude);
    bbp.BBP470_m1=bbp470; bbp.Cphyto_mgC_m3=carbon;
    % Match CHLA and BBP700 using the same original row, without a fuzzy join.
    bbpSource=bbp.SourceRow;
    bbp.Chl_to_C_mg_mg=NaN(height(bbp),1);
    chlAdjusted=double(raw.CHLA_ADJUSTED);
    good=isfinite(chlAdjusted(bbpSource)) & chlAdjusted(bbpSource)>=0;
    bbp.Chl_to_C_mg_mg(good)=chlAdjusted(bbpSource(good))./carbon(good);
    writetable(bbp,fullfile('output','bgc_profile_carbon_rows.csv'));
end
if ~isempty(oxygen)
    fprintf('Calculating GSW oxygen saturation and annual AOU...\n');
    [aouRows,aouInfo]=npsg_aou_gsw(oxygen); disp(aouInfo);
    if ~isempty(aouRows)
        writetable(aouRows,fullfile('output','bgc_adjusted_doxy_aou_rows.csv'));
        annualAOU=npsg_bgc_annual_aou(aouRows);
        if ~isempty(annualAOU)
            writetable(annualAOU,fullfile('output','bgc_annual_aou_profile.csv'));
        end
    end
end
fprintf('BGC products saved in output/.\n');
