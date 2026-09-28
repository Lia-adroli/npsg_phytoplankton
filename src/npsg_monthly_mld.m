function T = npsg_monthly_mld(physicalRows,zeu)
%NPSG_MONTHLY_MLD Author-style monthly profile-mean MLD from physical Argo.
% physicalRows comes from npsg_physical_filter: adjusted T/S with both
% their QC flags equal to 1; adjusted pressure is finite/range screened,
% 2003-2024, January-November, >=10 unique pressure levels/profile.
% zeu contains Year, Month, Zeu_m from monthly_Kd490_Zeu_ZSD.csv.
if nargin<2, error('Supply monthly satellite Zeu for MLD profile matching.'); end
assert(all(ismember({'Year','Month','Zeu_m'},zeu.Properties.VariableNames)), ...
    'zeu requires Year, Month and Zeu_m.');
required={'Platform','Cycle','Time','SP','Temperature','Pressure_dbar', ...
    'Latitude','Longitude360'};
if ~all(ismember(required,physicalRows.Properties.VariableNames))
    error('Pass the table returned by npsg_physical_filter.');
end
R=physicalRows;
if isempty(R)
    T=table(datetime.empty(0,1),[],[],[], ...
        'VariableNames',{'TIME','YEAR','MONTH','MLD_M'});
    return;
end
profileKey=R.Platform+"_"+R.Cycle+"_"+string(dateshift(R.Time,'start','day'));
[g,~]=findgroups(profileKey);
[g,order]=sort(g); R=R(order,:);
first=[1;find(diff(g)>0)+1]; last=[first(2:end)-1;numel(g)];
profileMLD=NaN(max(g),1); yr=NaN(max(g),1); mo=yr;
for k=1:max(g)
    if mod(k,1000)==0
        fprintf('MLD profiles: %d/%d\n',k,max(g));
    end
    q=R(first(k):last(k),:);
    yr(k)=year(q.Time(1)); mo(k)=month(q.Time(1));
    opticalRow=find(zeu.Year==yr(k)&zeu.Month==mo(k),1);
    if isempty(opticalRow), continue; end
    P=npsg_physical_profile_original(q.SP,q.Temperature,q.Pressure_dbar, ...
        median(q.Longitude360,'omitnan'),median(q.Latitude,'omitnan'));
    profileMLD(k)=npsg_mld_grid_threshold(P,zeu.Zeu_m(opticalRow));
end
valid=isfinite(profileMLD);
fprintf('MLD: %d/%d profiles passed depth, hydrography and Zeu checks.\n', ...
    nnz(valid),numel(profileMLD));
if ~any(valid)
    T=table(datetime.empty(0,1),[],[],[], ...
        'VariableNames',{'TIME','YEAR','MONTH','MLD_M'});
    return;
end
[group,y,m]=findgroups(yr(valid),mo(valid));
mld=splitapply(@mean,profileMLD(valid),group);
T=table(datetime(y,m,1),y,m,mld, ...
    'VariableNames',{'TIME','YEAR','MONTH','MLD_M'});
T=sortrows(T,{'YEAR','MONTH'});
end
