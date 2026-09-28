function value = npsg_coslat_mean(field,latitude)
%NPSG_COSLAT_MEAN Area-weighted mean of a lat x lon SST field.
% No extrapolation; NaNs are omitted and weights renormalized per slice.
latitude=double(latitude(:));
if size(field,1)~=numel(latitude), error('First field dimension must be latitude.'); end
w=cosd(latitude);
if any(~isfinite(w)|w<0), error('Invalid latitude weights.'); end
weights=reshape(w,[],1,1);
weights=repmat(weights,1,size(field,2),size(field,3));
v=double(field); weights(~isfinite(v))=0; v(~isfinite(v))=0;
den=sum(sum(weights,1),2);
value=squeeze(sum(sum(v.*weights,1),2)./den);
value(den==0)=NaN;
end
