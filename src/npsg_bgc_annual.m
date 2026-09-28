function annual = npsg_bgc_annual(rows,minMonths)
%NPSG_BGC_ANNUAL Monthly platform medians, equal platforms, annual mean.
% rows: Year, Month, Platform, Depth_m, Value. Annual depth needs at least
% minMonths valid monthly regional values (default 3). No extrapolation.
if nargin<2, minMonths=3; end
required={'Year','Month','Platform','Depth_m','Value'};
if ~all(ismember(required,rows.Properties.VariableNames)), error('Missing aggregation columns.'); end
rows=rows(isfinite(rows.Value)&isfinite(rows.Depth_m),:);
if isempty(rows), annual=table(); return; end
[g,yr,mo,plat,z]=findgroups(rows.Year,rows.Month,string(rows.Platform),rows.Depth_m);
med=splitapply(@median,rows.Value,g);
platform=table(yr,mo,plat,z,med,'VariableNames',required);
[g,yr,mo,z]=findgroups(platform.Year,platform.Month,platform.Depth_m);
v=splitapply(@mean,platform.Value,g);
monthly=table(yr,mo,z,v,'VariableNames',{'Year','Month','Depth_m','Value'});
[g,yr,z]=findgroups(monthly.Year,monthly.Depth_m);
n=splitapply(@numel,monthly.Value,g);
v=splitapply(@mean,monthly.Value,g);
valid=n>=minMonths;
annual=table(yr(valid),z(valid),v(valid),n(valid), ...
    'VariableNames',{'Year','Depth_m','Value','NMonths'});
end
