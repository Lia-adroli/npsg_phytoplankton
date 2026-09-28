function annual = npsg_annual_monthly(year,month,value)
%NPSG_ANNUAL_MONTHLY Within-year median outliers (factor 3), then mean.
year=double(year(:)); month=double(month(:)); value=double(value(:));
ok=isfinite(year)&isfinite(month)&month>=1&month<=12&isfinite(value);
year=year(ok); month=month(ok); value=value(ok);
if isempty(year), annual=table(); return; end
if numel(unique(year*100+month))~=numel(year)
    error('Expected one observation per calendar month.');
end
[g,y]=findgroups(year);
meanValue=NaN(numel(y),1); nMonths=zeros(numel(y),1);
for k=1:numel(y)
    v=value(g==k);
    out=false(size(v));
    if numel(v)>=4
        out=isoutlier(v,'median','ThresholdFactor',3);
        if all(out), out=false(size(v)); end
    end
    v=v(~out); meanValue(k)=mean(v); nMonths(k)=numel(v);
end
annual=table(y,meanValue,nMonths, ...
    'VariableNames',{'Year','Mean','NMonths'});
end
