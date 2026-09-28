function [monthly,annual] = npsg_dcm_series(rows)
%NPSG_DCM_SERIES 10-m binned regional chlorophyll, 20-250 m DCM.
% Input Year, Month, Depth_m, Value (QC-screened CHLA). Each bin uses
% median of input rows. This choice must be checked against source plots.
required={'Year','Month','Depth_m','Value'};
if ~all(ismember(required,rows.Properties.VariableNames)), error('Missing DCM columns.'); end
rows=rows(isfinite(rows.Depth_m)&isfinite(rows.Value)&rows.Depth_m>=0&rows.Depth_m<=300,:);
if isempty(rows), monthly=table(); annual=table(); return; end
bin=10*floor(rows.Depth_m/10)+5;
[g,yr,mo,z]=findgroups(rows.Year,rows.Month,bin);
v=splitapply(@median,rows.Value,g);
b=table(yr,mo,z,v,'VariableNames',{'Year','Month','BinDepth_m','Chl'});
[groups,y,m]=findgroups(b.Year,b.Month);
depth=NaN(numel(y),1); peak=depth;
for k=1:numel(y)
    ix=groups==k; [depth(k),peak(k)]=npsg_dcm(b.BinDepth_m(ix),b.Chl(ix));
end
monthly=table(y,m,depth,peak,'VariableNames', ...
    {'Year','Month','DCMDepth_m','PeakChl'});
[g,yr,z]=findgroups(rows.Year,bin);
v=splitapply(@median,rows.Value,g);
[groups,y]=findgroups(yr);
depth=NaN(numel(y),1); peak=depth;
for k=1:numel(y)
    ix=groups==k; [depth(k),peak(k)]=npsg_dcm(z(ix),v(ix));
end
annual=table(y,depth,peak,'VariableNames',{'Year','DCMDepth_m','PeakChl'});
end
