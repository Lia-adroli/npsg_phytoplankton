function [Iz,depths] = npsg_isolumes(PARsurf,KPAR,z)
%NPSG_ISOLUMES Beer-Lambert irradiance and 10/1/0.1%% isolumes.
% PARsurf and KPAR may be scalars or size-matched arrays; KPAR in m^-1.
% If z is omitted, Iz=[]; depths is a struct with fields z10,z1,z01.
validateattributes(PARsurf,{'numeric'},{'real'});
validateattributes(KPAR,{'numeric'},{'real'});
if any(isfinite(PARsurf(:)) & PARsurf(:)<0)
    error('Finite surface PAR must be nonnegative.');
end
if any(isfinite(KPAR(:)) & KPAR(:)<=0)
    error('Finite KPAR must be positive.');
end
if ~(isscalar(PARsurf) || isscalar(KPAR) || isequal(size(PARsurf),size(KPAR)))
    error('PARsurf and KPAR must be scalars or size-matched.');
end
depths.z10 = -log(0.1)./KPAR;
depths.z1  = -log(0.01)./KPAR;
depths.z01 = -log(0.001)./KPAR;
Iz = [];
if nargin >= 3 && ~isempty(z)
    validateattributes(z,{'numeric'},{'real','nonnegative'});
    Iz = PARsurf .* exp(-KPAR .* z);
end
end
