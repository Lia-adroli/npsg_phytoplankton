function [fineYear,fineDepth,displayField] = npsg_display_field(years,depth,field)
%NPSG_DISPLAY_FIELD MAKIMA for DISPLAY ONLY, 0.25 year x 2 m grid.
% Input field is year x depth. Missing source samples divide segments:
% no extrapolation or interpolation across a missing year/depth cell.
years=double(years(:)); depth=double(depth(:)); field=double(field);
if ~isequal(size(field),[numel(years),numel(depth)])
    error('Field dimensions must be [numel(years),numel(depth)].');
end
if any(diff(years)<=0)||any(diff(depth)<=0)
    error('Year and depth axes must be strictly increasing.');
end
fineYear=(years(1):0.25:years(end))';
fineDepth=(depth(1):2:depth(end))';
stage=NaN(numel(years),numel(fineDepth));
for i=1:numel(years)
    stage(i,:)=segments(depth,field(i,:)',fineDepth)';
end
displayField=NaN(numel(fineYear),numel(fineDepth));
for j=1:numel(fineDepth)
    displayField(:,j)=segments(years,stage(:,j),fineYear);
end
end

function yi=segments(x,y,xi)
yi=NaN(size(xi));
good=find(isfinite(y));
if isempty(good), return; end
starts=[1;find(diff(good)>1)+1]; stops=[starts(2:end)-1;numel(good)];
for k=1:numel(starts)
    ids=good(starts(k):stops(k));
    if numel(ids)==1
        yi(xi==x(ids))=y(ids);
    else
        q=xi>=x(ids(1))&xi<=x(ids(end));
        yi(q)=interp1(x(ids),y(ids),xi(q),'makima');
    end
end
end
