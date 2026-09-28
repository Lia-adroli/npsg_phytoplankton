% Run from the repository root after addpath(fullfile(pwd,'src')).
bgc=fullfile('data','Final_BGC_Argo_All_Depth_Rows_With_Adjusted.csv');
physical=fullfile('data','ArgoFloats_filtered_qc12_pres1000.csv');
if isfile(bgc)
    rawBGC=readtable(bgc,'VariableNamingRule','preserve');
    disp(npsg_argo_qc_report(rawBGC,'bgc'))
    years=[2016 2017 2020 2021 2022 2023 2024];
    [chl,infoChl]=npsg_bgc_filter(rawBGC,'CHLA',years,5,10);
    disp(infoChl)
    [bbp,infoBBP]=npsg_bgc_filter(rawBGC,'BBP700',years,5,10);
    disp(infoBBP)
    [oxygen,infoOxygen]=npsg_bgc_filter(rawBGC,'DOXY',years,5,10);
    disp(infoOxygen)
    if isempty(oxygen)
        fprintf('No adjusted oxygen rows passed the shared CHLA QC-1 gate and profile coverage; AOU skipped.\n');
    elseif exist('gsw_O2sol','file')==2
        [aouRows,aouInfo]=npsg_aou_gsw(oxygen);
        disp(aouInfo)
        if ~isfolder('output'), mkdir('output'); end
        writetable(aouRows,fullfile('output','bgc_adjusted_doxy_aou_rows.csv'));
    elseif ~isempty(oxygen)
        warning('Install GSW to calculate AOU from DOXY_ADJUSTED.');
    end
    if ~isempty(chl) && exist('gsw_z_from_p','file')==2
        depthMetres=-gsw_z_from_p(chl.Pressure_dbar,chl.Latitude);
        [monthlyDCM,annualDCM]=npsg_dcm_series(table(chl.Year,chl.Month, ...
            depthMetres,chl.Value,'VariableNames', ...
            {'Year','Month','Depth_m','Value'}));
        disp(annualDCM)
    elseif ~isempty(chl)
        warning('Install GSW to convert pressure to metres for DCM.');
    end
else
    fprintf('BGC file absent: %s\n',bgc);
end
if isfile(physical)
    fprintf('Reading physical Argo CSV (may take several minutes)...\n');
    stageStart=tic;
    rawPhysical=readtable(physical,'VariableNamingRule','preserve');
    fprintf('Read %d rows in %.1f seconds.\n',height(rawPhysical),toc(stageStart));
    disp(npsg_argo_qc_report(rawPhysical,'physical'))
    % 'argo' follows the numeric/date conventions in the attached script.
    % Change to the explicit CSV InputFormat if dates are interpreted wrongly.
    physicalTimeFormat='argo';
    [phys,infoPhysical]=npsg_physical_filter(rawPhysical,physicalTimeFormat,10);
    disp(infoPhysical)
else
    fprintf('Physical file absent: %s\n',physical);
end
