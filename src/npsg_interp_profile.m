function yi = npsg_interp_profile(z,y,zi)
%NPSG_INTERP_PROFILE Linear interpolation, no extrapolation across endpoints.
z=double(z(:)); y=double(y(:)); zi=double(zi(:));
if numel(z)~=numel(y), error('Depth and value lengths differ.'); end
ok=isfinite(z)&isfinite(y)&z>=0;
z=z(ok); y=y(ok);
if numel(z)<2, yi=NaN(size(zi)); return; end
[z,~,g]=unique(z); y=splitapply(@median,y,g);
if numel(z)<2, yi=NaN(size(zi)); return; end
yi=interp1(z,y,zi,'linear',NaN);
end
