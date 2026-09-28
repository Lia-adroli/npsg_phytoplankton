function mld=npsg_mld_grid_threshold(P,zeu)
%NPSG_MLD_GRID_THRESHOLD First supported 1-m grid crossing above sigma0(10).
% Author's physical script also required density at monthly satellite Zeu.
mld=NaN;
if ~isfinite(zeu)||zeu<=10||zeu>300, return; end
z=P.Depth_m; s=P.Sigma0;
if ~isfinite(s(11))||~isfinite(interp1(z,s,zeu,'linear',NaN)), return; end
cross=find(z>=10 & isfinite(s) & s>=s(11)+0.03,1);
if ~isempty(cross), mld=z(cross); end
end
