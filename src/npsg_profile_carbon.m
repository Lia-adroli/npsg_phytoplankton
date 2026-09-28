function [C,bbp470,ratio] = npsg_profile_carbon(bbp700,chl)
%NPSG_PROFILE_CARBON BGC-Argo bbp700 (m^-1) to carbon (mg C m^-3).
% Optional matched chlorophyll (mg Chl m^-3) returns Chl:C (mg Chl/mg C).
validateattributes(bbp700,{'numeric'},{'real'});
if any(isfinite(bbp700(:)) & bbp700(:)<0)
    error('Finite bbp700 values must be nonnegative.');
end
bbp470 = double(bbp700) .* (470/700)^(-0.78);
C = 12128 .* bbp470 + 0.59;
ratio = [];
if nargin >= 2 && ~isempty(chl)
    if ~isequal(size(chl),size(C)), error('Chlorophyll and bbp must match in size.'); end
    validateattributes(chl,{'numeric'},{'real'});
    if any(isfinite(chl(:)) & chl(:)<0)
        error('Finite chlorophyll values must be nonnegative.');
    end
    ratio = double(chl) ./ C;
end
end
