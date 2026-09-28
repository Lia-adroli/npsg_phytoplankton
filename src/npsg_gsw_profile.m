function P = npsg_gsw_profile(SP,t,p,lon,lat)
%NPSG_GSW_PROFILE TEOS-10 conversion and 1-m interpolation to 0-300 m.
% GSW Toolbox required. p is sea pressure in dbar, t in situ deg C.
needed={'gsw_SA_from_SP','gsw_CT_from_t','gsw_sigma0','gsw_z_from_p'};
for k=1:numel(needed)
    if exist(needed{k},'file')~=2, error('Install GSW toolbox: missing %s.',needed{k}); end
end
SP=double(SP(:)); t=double(t(:)); p=double(p(:));
if numel(SP)~=numel(t)||numel(t)~=numel(p), error('T/S/p lengths differ.'); end
ok=isfinite(SP)&isfinite(t)&isfinite(p)&p>=0&SP>=0;
SP=SP(ok); t=t(ok); p=p(ok);
P=table((0:300)','VariableNames',{'Depth_m'});
P.CT=NaN(301,1); P.Sigma0=NaN(301,1);
P.SA=NaN(301,1);
if numel(unique(p))<2, return; end
SA=gsw_SA_from_SP(SP,p,lon,lat);
CT=gsw_CT_from_t(SA,t,p);
sigma=gsw_sigma0(SA,CT);
z=-gsw_z_from_p(p,lat); % depth positive downward, metres
P.SA=npsg_interp_profile(z,SA,P.Depth_m);
P.CT=npsg_interp_profile(z,CT,P.Depth_m);
P.Sigma0=npsg_interp_profile(z,sigma,P.Depth_m);
end
