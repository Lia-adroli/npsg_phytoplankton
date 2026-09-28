function [ohc,anomaly] = npsg_ohc_anomaly(CT,baselineCT)
%NPSG_OHC_ANOMALY Volumetric heat content (J/m^3), reference rho0=1025.
% CT: Conservative Temperature in deg C. baselineCT must be same size or scalar.
validateattributes(CT,{'numeric'},{'real'});
ohc = 1025 * 3985 .* double(CT);
anomaly = [];
if nargin>=2 && ~isempty(baselineCT)
    if ~(isscalar(baselineCT) || isequal(size(CT),size(baselineCT)))
        error('Baseline CT must be scalar or match CT.');
    end
    anomaly = 1025 * 3985 .* (double(CT)-double(baselineCT));
end
end
