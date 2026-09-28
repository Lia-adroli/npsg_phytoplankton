function slope = npsg_grid_trend(years,chl)
%NPSG_GRID_TREND Chlorophyll slope per grid cell, time on third dimension.
% Invalid/out of [0,20] removed, then values >3 temporal SD removed.
years=double(years(:));
if ndims(chl)~=3 || size(chl,3)~=numel(years)
    error('Chlorophyll must be latitude x longitude x time.');
end
slope=NaN(size(chl,1),size(chl,2));
for i=1:size(chl,1)
    for j=1:size(chl,2)
        y=double(squeeze(chl(i,j,:)));
        ok=isfinite(y)&y>=0&y<=20&isfinite(years);
        if nnz(ok)<10, continue; end
        mu=mean(y(ok)); sd=std(y(ok));
        if sd>0, ok=ok & abs(y-mu)<=3*sd; end
        r=npsg_linear_trend(years(ok),y(ok),10);
        slope(i,j)=r.slope;
    end
end
end
