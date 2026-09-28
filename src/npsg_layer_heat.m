function H = npsg_layer_heat(depth,CT,MLD,Zeu)
%NPSG_LAYER_HEAT Integrate rho0*cp*CT over exact layer overlaps (J/m^2).
% Requires complete support from 0-300 m; no extrapolation over gaps.
H=struct('surfaceToMLD',NaN,'MLDToZeu',NaN,'ZeuTo300',NaN);
if ~isscalar(MLD)||~isscalar(Zeu)||~isfinite(MLD)||~isfinite(Zeu) ...
        ||MLD<0||Zeu<MLD||Zeu>300, return; end
z=double(depth(:)); ct=double(CT(:));
if numel(z)~=numel(ct), error('Depth and CT lengths differ.'); end
if any(isfinite(z)&z>=0&z<=300&~isfinite(ct)), return; end
ok=isfinite(z)&isfinite(ct);
z=z(ok); ct=ct(ok);
if numel(z)<2, return; end
[z,ix]=unique(z); ct=ct(ix);
if z(1)>0||z(end)<300, return; end
bounds=[0 MLD Zeu 300]; names={'surfaceToMLD','MLDToZeu','ZeuTo300'};
for k=1:3
    if bounds(k)==bounds(k+1), H.(names{k})=0; continue; end
    zz=unique([bounds(k);z(z>bounds(k)&z<bounds(k+1));bounds(k+1)]);
    yy=interp1(z,ct,zz,'linear');
    H.(names{k})=1025*3985*trapz(zz,yy);
end
end
