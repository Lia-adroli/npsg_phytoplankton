function S=npsg_ersst_v6(folder)
%NPSG_ERSST_V6 Native 2-degree SST ROI, 1998-2024, monthly files.
% Input filenames are strictly ersst.v6.YYYYMM.nc (324 files).
assert(isfolder(folder),'ERSSTv6 folder does not exist: %s',folder);
years=repelem((1998:2024)',12); months=repmat((1:12)',27,1);
n=numel(years);
first=fullfile(folder,'ersst.v6.199801.nc');
assert(isfile(first),'Missing ERSSTv6 file: %s',first);
lon=mod(double(ncread(first,'lon')),360);
lat=double(ncread(first,'lat'));
ilat=find(lat>=14 & lat<=28); ilon=find(lon>=160 & lon<=200);
assert(~isempty(ilat)&&~isempty(ilon),'ROI absent from ERSST grid.');
cube=NaN(numel(ilat),numel(ilon),n);
for k=1:n
    file=fullfile(folder,sprintf('ersst.v6.%04d%02d.nc',years(k),months(k)));
    assert(isfile(file),'Missing ERSSTv6 month: %s',file);
    raw=double(ncread(file,'sst')); raw=squeeze(raw);
    if isequal(size(raw),[numel(lon),numel(lat)])
        field=raw';
    elseif isequal(size(raw),[numel(lat),numel(lon)])
        field=raw;
    else
        error('Unexpected SST grid dimensions in %s',file);
    end
    field(~isfinite(field)|field<-3|field>45)=NaN;
    cube(:,:,k)=field(ilat,ilon);
    if mod(k,36)==0, fprintf('ERSSTv6: read %d/%d months\n',k,n); end
end
roi=NaN(n,1);
for k=1:n, roi(k)=npsg_coslat_mean(cube(:,:,k),lat(ilat)); end
clean=roi;
% For each calendar month, screen anomalous years before annual ROI means.
for m=1:12
    idx=find(months==m & isfinite(clean));
    if numel(idx)>=4
        flagged=isoutlier(clean(idx),'median','ThresholdFactor',3);
        clean(idx(flagged))=NaN;
    end
end
S=struct(); S.monthly=table(years,months,roi,clean, ...
    'VariableNames',{'Year','Month','SST_C','SST_Screened_C'});
y=(1998:2024)'; meanSST=NaN(numel(y),1); nMonths=zeros(numel(y),1);
for j=1:numel(y)
    v=clean(years==y(j)); nMonths(j)=nnz(isfinite(v));
    if nMonths(j)>=6, meanSST(j)=mean(v,'omitnan'); end
end
S.annual=table(y,meanSST,nMonths, ...
    'VariableNames',{'Year','SST_C','NMonths'});
S.roiTrend=npsg_linear_trend(y,meanSST,10);
% Native grid trends use all valid monthly values, ≥24 months/cell.
x=years+(months-0.5)/12; slope=NaN(numel(ilat),numel(ilon));
for i=1:numel(ilat)
    for j=1:numel(ilon)
        v=squeeze(cube(i,j,:));
        fit=npsg_linear_trend(x,v,24);
        slope(i,j)=fit.slope;
    end
end
[latGrid,lonGrid]=ndgrid(lat(ilat),lon(ilon));
S.gridTrend=table(latGrid(:),lonGrid(:),slope(:), ...
    'VariableNames',{'Latitude','Longitude360','Slope_C_per_year'});
end
