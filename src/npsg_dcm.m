function [depth,peak] = npsg_dcm(binDepth,binChl)
%NPSG_DCM Maximum binned chlorophyll in the 20-250 m search interval.
% binDepth is the centre of 10-m bins; ties take the shallowest maximum.
z=binDepth(:); c=binChl(:);
if numel(z)~=numel(c), error('Depth and chlorophyll lengths differ.'); end
valid=isfinite(z)&isfinite(c)&z>=20&z<=250;
depth=NaN; peak=NaN;
if ~any(valid), return; end
z=z(valid); c=c(valid);
[z,ix]=sort(z); c=c(ix);
[peak,ix]=max(c); depth=z(ix);
end
