function [ohc,anomaly,baseline] = npsg_annual_ohc_anomaly(annualCT)
%NPSG_ANNUAL_OHC_ANOMALY Annual years x depth CT relative to each-depth mean.
% Reference rho=1025 kg/m^3, cp=3985 J/(kg K); result is J/m^3.
validateattributes(annualCT,{'numeric'},{'real','2d'});
baseline=mean(double(annualCT),1,'omitnan');
ohc=1025*3985.*double(annualCT);
anomaly=1025*3985.*(double(annualCT)-baseline);
end
