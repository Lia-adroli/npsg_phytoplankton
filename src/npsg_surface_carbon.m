function C = npsg_surface_carbon(bbp443)
%NPSG_SURFACE_CARBON Satellite bbp443 (m^-1) to mg C m^-3.
% Valid values below 0.00035 are replaced by 0.00036; NaN remains NaN.
validateattributes(bbp443,{'numeric'},{'real'});
if any(isfinite(bbp443(:)) & bbp443(:)<0)
    error('Finite bbp443 values must be nonnegative.');
end
b = double(bbp443);
b(isfinite(b) & b < 0.00035) = 0.00036;
C = 13000 .* (b - 0.00035);
end
