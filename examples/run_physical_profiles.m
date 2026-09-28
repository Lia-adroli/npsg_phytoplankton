% Full TEOS-10 annual physical profiles, MLD, isopycnals, and heat products.
file=fullfile('data','ArgoFloats_filtered_qc12_pres1000.csv');
assert(isfile(file),'Missing %s',file);
assert(exist('gsw_SA_from_SP','file')==2,'Run setup_gsw first.');
if ~isfolder('output'), mkdir('output'); end
fprintf('Reading physical Argo CSV (large file)...\n');
raw=readtable(file,'VariableNamingRule','preserve');
[physical,info]=npsg_physical_filter(raw,'argo',10); disp(info);
optics=fullfile('data','monthly_Kd490_Zeu_ZSD.csv');
assert(isfile(optics),'Monthly optical Zeu CSV required for physical MLD.');
O=npsg_surface_products(optics);
zeu=table(O.Year,O.Month,double(O.Zeu_from_Kd490), ...
    'VariableNames',{'Year','Month','Zeu_m'});
% Change these targets if the manuscript figures use different isopycnals.
isopycnalTargets=[24 25 26];
P=npsg_physical_products(physical,zeu,isopycnalTargets);
fields={'annual','monthlyMLD','isopycnals','monthlyLayers','annualLayers'};
names={'physical_annual_1m.csv','Monthly_MLD.csv', ...
    'physical_profile_isopycnals.csv','physical_monthly_heat_layers.csv', ...
    'physical_annual_heat_layers.csv'};
for k=1:numel(fields)
    T=P.(fields{k});
    if strcmp(fields{k},'monthlyMLD') && ~isempty(T)
        T=table(datetime(T.Year,T.Month,1),T.Year,T.Month,T.MLD_m, ...
            'VariableNames',{'TIME','YEAR','MONTH','MLD_M'});
    end
    if ~isempty(T), writetable(T,fullfile('output',names{k})); end
    fprintf('%s: %d rows\n',names{k},height(T));
end
if ~isempty(P.monthlyMLD)
    cacheVersion=3; %#ok<NASGU>
    save(fullfile('output','Monthly_MLD_cache.mat'),'cacheVersion');
end
% The display field is separate from all statistical outputs.
if ~isempty(P.annual)
    A=P.annual; yy=unique(A.Year); zz=unique(A.Depth_m);
    F=NaN(numel(yy),numel(zz));
    [~,i]=ismember(A.Year,yy); [~,j]=ismember(A.Depth_m,zz);
    F(sub2ind(size(F),i,j))=A.OHC_Anomaly_J_m3;
    [displayYear,displayDepth,displayOHC]=npsg_display_field(yy,zz,F);
    save(fullfile('output','physical_ohc_display_only.mat'), ...
        'displayYear','displayDepth','displayOHC');
end
