function annual = npsg_bgc_annual_aou(aouRows)
%NPSG_BGC_ANNUAL_AOU Interpolate each accepted oxygen profile, then aggregate.
% The input is the output of npsg_aou_gsw (adjusted oxygen, shared CHLA QC).
% Monthly platform medians receive equal weight; annual depths need 3 months.
required={'ProfileID','Platform','Year','Month','Pressure_dbar', ...
    'Latitude','AOU_umol_kg'};
assert(all(ismember(required,aouRows.Properties.VariableNames)), ...
    'Pass screened rows from npsg_aou_gsw.');
annual=table();
if isempty(aouRows), return; end
[group,~]=findgroups(aouRows.ProfileID);
[group,order]=sort(group); aouRows=aouRows(order,:);
first=[1;find(diff(group)>0)+1]; last=[first(2:end)-1;numel(group)];
parts=cell(max(group),1); used=0;
z=(0:300)';
for k=1:max(group)
    r=aouRows(first(k):last(k),:);
    valid=isfinite(r.Pressure_dbar)&isfinite(r.Latitude)& ...
        isfinite(r.AOU_umol_kg);
    if nnz(valid)<5, continue; end
    p=r.Pressure_dbar(valid); lat=r.Latitude(valid);
    depth=-gsw_z_from_p(p,lat);
    values=npsg_interp_profile(depth,r.AOU_umol_kg(valid),z);
    keep=isfinite(values);
    if ~any(keep), continue; end
    used=used+1; n=nnz(keep);
    parts{used}=table(repmat(r.Year(1),n,1),repmat(r.Month(1),n,1), ...
        repmat(string(r.Platform(1)),n,1),z(keep),values(keep), ...
        'VariableNames',{'Year','Month','Platform','Depth_m','Value'});
end
if used>0
    annual=npsg_bgc_annual(vertcat(parts{1:used}),3);
    if ~isempty(annual), annual.Properties.VariableNames{'Value'}='AOU_umol_kg'; end
end
end
