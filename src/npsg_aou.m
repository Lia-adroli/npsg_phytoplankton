function aou = npsg_aou(O2obs,O2sat)
%NPSG_AOU Apparent oxygen utilization, saturation minus observation.
% Inputs must be matched arrays in the SAME units (for example umol/kg).
if ~isequal(size(O2obs),size(O2sat)), error('Oxygen arrays must match in size.'); end
validateattributes(O2obs,{'numeric'},{'real'});
validateattributes(O2sat,{'numeric'},{'real'});
aou = double(O2sat) - double(O2obs);
end
