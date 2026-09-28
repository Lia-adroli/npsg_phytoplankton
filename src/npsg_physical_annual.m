function annual = npsg_physical_annual(rows,minMonths)
%NPSG_PHYSICAL_ANNUAL Equal-month, equal-platform yearly mean at each depth.
% rows: Year, Month, Platform, Depth_m, Value; profile values are first
% combined into a monthly platform median. Each platform-depth-year needs
% at least minMonths distinct represented months (default 6).
if nargin<2, minMonths=6; end
required={'Year','Month','Platform','Depth_m','Value'};
if ~all(ismember(required,rows.Properties.VariableNames)), error('Missing aggregation columns.'); end
rows=rows(isfinite(rows.Value)&isfinite(rows.Depth_m),:);
if isempty(rows), annual=table(); return; end
[g,year0,month0,plat0,z0]=findgroups(rows.Year,rows.Month,string(rows.Platform),rows.Depth_m);
v=splitapply(@median,rows.Value,g);
monthly=table(year0,month0,plat0,z0,v,'VariableNames',required);
[g,yr,plat,z]=findgroups(monthly.Year,monthly.Platform,monthly.Depth_m);
count=splitapply(@numel,monthly.Month,g);
means=splitapply(@mean,monthly.Value,g);
valid=count>=minMonths;
platform=table(yr(valid),plat(valid),z(valid),means(valid), ...
    'VariableNames',{'Year','Platform','Depth_m','Value'});
if isempty(platform), annual=table(); return; end
[g,yr,z]=findgroups(platform.Year,platform.Depth_m);
v=splitapply(@mean,platform.Value,g);
n=splitapply(@numel,platform.Value,g);
annual=table(yr,z,v,n,'VariableNames',{'Year','Depth_m','Value','NPlatforms'});
end
