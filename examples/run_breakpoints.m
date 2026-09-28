% Run from repository root after addpath(fullfile(pwd,'src')).
cbpmFile=fullfile('data','CbPM_surface_only.csv');
if ~isfile(cbpmFile), error('Put full CbPM_surface_only.csv in data/.'); end
M=npsg_cbpm_surface(cbpmFile);
% Match the physical MLD seasonal coverage for every compared series.
M=M(M.Month>=1&M.Month<=11,:);
physicalFile=fullfile('data','ArgoFloats_filtered_qc12_pres1000.csv');
opticalFile=fullfile('data','monthly_Kd490_Zeu_ZSD.csv');
assert(isfile(physicalFile),'Physical Argo CSV required to calculate MLD.');
assert(isfile(opticalFile),'Monthly optical Zeu CSV required to calculate MLD.');
cacheFile=fullfile('output','Monthly_MLD.csv');
cacheMetadata=fullfile('output','Monthly_MLD_cache.mat');
sourceChanged=true;
if isfile(cacheFile) && isfile(cacheMetadata)
    info=load(cacheMetadata,'cacheVersion');
    cacheInfo=dir(cacheFile); physicalInfo=dir(physicalFile);
    opticalInfo=dir(opticalFile);
    sourceChanged=~isfield(info,'cacheVersion') || info.cacheVersion~=3 || ...
        cacheInfo.datenum<physicalInfo.datenum || ...
        cacheInfo.datenum<opticalInfo.datenum;
end
if ~sourceChanged
    fprintf('Reusing Argo-derived %s.\n',cacheFile);
    L=readtable(cacheFile,'VariableNamingRule','preserve');
else
    fprintf('Filtering physical Argo for monthly MLD...\n');
    stageStart=tic;
    [P,~]=npsg_physical_filter(physicalFile,'argo',10);
    O=npsg_surface_products(opticalFile);
    zeu=table(O.Year,O.Month,double(O.Zeu_from_Kd490), ...
        'VariableNames',{'Year','Month','Zeu_m'});
    fprintf('Calculating MLD for %d physical rows...\n',height(P));
    L=npsg_monthly_mld(P,zeu);
    if ~isfolder('output'), mkdir('output'); end
    writetable(L,cacheFile);
    cacheVersion=3; %#ok<NASGU> adjusted T/S QC, author-style profile MLD
    save(cacheMetadata,'cacheVersion');
    fprintf('Saved %s in %.1f seconds.\n',cacheFile,toc(stageStart));
end
requiredMLD={'YEAR','MONTH','MLD_M'};
if ~all(ismember(requiredMLD,L.Properties.VariableNames))
    error('Monthly_MLD.csv requires YEAR, MONTH, MLD_M.');
end
L=L(L.YEAR>=2003&L.YEAR<=2024&L.MONTH>=1&L.MONTH<=11,:);
series={M.Cphyto,M.chlC_obs,L.MLD_M};
years={M.Year,M.Year,L.YEAR}; months={M.Month,M.Month,L.MONTH};
names={'Cphyto','chlC_obs','MLD_M'};
if ismember('growth_rate',M.Properties.VariableNames)
    names{end+1}='growth_rate';
    series{end+1}=M.growth_rate;
    years{end+1}=M.Year; months{end+1}=M.Month;
end
result=table();
annualRows=table();
for k=1:numel(names)
    fprintf('Analyzing %s with 1000 bootstrap replicates...\n',names{k});
    stageStart=tic;
    A=npsg_annual_monthly(years{k},months{k},series{k});
    if ~isempty(A)
        annualRows=[annualRows;table(repmat(string(names{k}),height(A),1), ...
            A.Year,A.Mean,A.NMonths,'VariableNames', ...
            {'Variable','Year','AnnualMean','NMonths'})]; %#ok<AGROW>
    end
    if height(A)<10
        warning('%s: only %d annual means; skipped.',names{k},height(A));
        continue;
    end
    R=npsg_breakpoint(A.Year,A.Mean,1000,1);
    fprintf('Completed %s in %.1f seconds.\n',names{k},toc(stageStart));
    result=[result;table(string(names{k}),R.splitYear,R.breakPosition, ...
        R.continuousBreakPosition,R.pSupF,R.pSlopeChange, ...
        R.deltaAIC,R.deltaAICc,R.deltaBIC, ...
        R.supported,R.supportedStrict, ...
        'VariableNames',{'Variable','SplitYear','BreakPosition', ...
        'ContinuousBreakPosition','pSupF','pSlopeChange', ...
        'DeltaAIC','DeltaAICc','DeltaBIC','Supported', ...
        'SupportedStrictDiagnostic'})]; %#ok<AGROW>
end
disp(result)
if ~isfolder('output'), mkdir('output'); end
writetable(result,fullfile('output','breakpoint_summary.csv'));
if ~isempty(annualRows)
    writetable(annualRows,fullfile('output','breakpoint_annual_means.csv'));
end
