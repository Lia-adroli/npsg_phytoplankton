function [mld,zIso] = npsg_mld_isopycnal(z,sigma0,targetSigma)
%NPSG_MLD_ISOPYCNAL First 0.03 kg/m^3 crossing above sigma0 at 10 m.
% Linear interpolation. Returns NaN if reference or crossing is missing.
z = z(:); sigma0 = sigma0(:);
if numel(z) ~= numel(sigma0), error('Depth and density lengths differ.'); end
valid = isfinite(z) & isfinite(sigma0) & z >= 0;
z = z(valid); sigma0 = sigma0(valid);
[z,ii] = unique(z,'sorted'); sigma0 = sigma0(ii);
mld = NaN; zIso = NaN(size(targetSigma));
if numel(z)<2, return; end
if z(1)<=10 && z(end)>=10
    ref = interp1(z,sigma0,10);
    mld = firstCrossing(z,sigma0,ref+0.03,10);
end
for k=1:numel(targetSigma)
    zIso(k) = firstCrossing(z,sigma0,targetSigma(k),z(1));
end
end

function depth = firstCrossing(z,s,target,startDepth)
depth = NaN;
if ~isfinite(target), return; end
for j=2:numel(z)
    if z(j)<startDepth, continue; end
    lo = max(z(j-1),startDepth);
    if lo>z(j) || s(j)==s(j-1), continue; end
    slo = interp1(z(j-1:j),s(j-1:j),lo);
    if (slo-target)*(s(j)-target)<=0
        depth = lo + (target-slo)*(z(j)-lo)/(s(j)-slo);
        return
    end
end
end
