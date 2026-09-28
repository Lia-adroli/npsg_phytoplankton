function H=npsg_layer_mean_ohc(depth,CT,MLD,Zeu)
%NPSG_LAYER_MEAN_OHC Valid-cell, exact-overlap mean volumetric heat (GJ/m3).
% A grid cell extends halfway to adjacent depths, clipped to 0..300 m.
% Missing CT cells are excluded; Covered_m records support in each layer.
H=struct('surfaceToMLD',NaN,'MLDToZeu',NaN,'ZeuTo300',NaN, ...
    'covered_m',[0 0 0]);
if ~isfinite(MLD)||~isfinite(Zeu)||MLD<0||Zeu<MLD||Zeu>300, return; end
z=double(depth(:)); ct=double(CT(:));
assert(numel(z)==numel(ct),'Depth and CT lengths differ.');
if numel(z)<2||any(diff(z)<=0), return; end
top=[max(0,z(1)-(z(2)-z(1))/2);(z(1:end-1)+z(2:end))/2];
bottom=[top(2:end);min(300,z(end)+(z(end)-z(end-1))/2)];
bounds=[0 MLD Zeu 300]; names={'surfaceToMLD','MLDToZeu','ZeuTo300'};
for j=1:3
    overlap=max(0,min(bottom,bounds(j+1))-max(top,bounds(j)));
    valid=isfinite(ct)&isfinite(z)&overlap>0;
    coverage=sum(overlap(valid)); H.covered_m(j)=coverage;
    if coverage>0
        H.(names{j})=1025*3985/1e9*sum(ct(valid).*overlap(valid))/coverage;
    end
end
end
