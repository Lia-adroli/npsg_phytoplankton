function P=npsg_physical_profile_original(SP,t,p,lon,lat)
%NPSG_PHYSICAL_PROFILE_ORIGINAL Author-style physical profile preparation.
% Input has already passed the adjusted T/S QC-1 row gate and 2003-2024
% January-November/ROI screening in npsg_physical_filter. Reject shallow,
% deep, or sparse profiles; remove strong local T/S spikes; interpolate
% to the supported 1-m range and smooth CT/SA over five depth cells.
zgrid=(0:300)';
P=table(zgrid,NaN(301,1),NaN(301,1),NaN(301,1), ...
    'VariableNames',{'Depth_m','CT','SA','Sigma0'});
sp=double(SP(:)); temp=double(t(:)); pressure=double(p(:));
ok=isfinite(sp)&isfinite(temp)&isfinite(pressure)&pressure>=0&pressure<=300 ...
    &sp>=30&sp<=40&temp>=-2&temp<=40;
sp=sp(ok); temp=temp(ok); pressure=pressure(ok);
if numel(unique(pressure))<10, return; end
[pressure,idx]=unique(pressure,'stable');
sp=sp(idx); temp=temp(idx);
[pressure,idx]=sort(pressure); sp=sp(idx); temp=temp(idx);
if numel(pressure)>=7
    spikeT=isoutlier(temp,'movmedian',7,'ThresholdFactor',5);
    spikeS=isoutlier(sp,'movmedian',7,'ThresholdFactor',5);
    keep=~spikeT&~spikeS;
    pressure=pressure(keep); sp=sp(keep); temp=temp(keep);
end
if numel(pressure)<10, return; end
z=-gsw_z_from_p(pressure,lat);
if min(z)>5||max(z)<290||max(diff(z))>50, return; end
SA=gsw_SA_from_SP(sp,pressure,lon,lat);
keep=isfinite(SA)&SA>=30&SA<=41;
z=z(keep); pressure=pressure(keep); temp=temp(keep); SA=SA(keep);
if numel(z)<10, return; end
CT=gsw_CT_from_t(SA,temp,pressure);
supported=zgrid>=min(z)&zgrid<=max(z);
P.CT(supported)=interp1(z,CT,zgrid(supported),'linear',NaN);
P.SA(supported)=interp1(z,SA,zgrid(supported),'linear',NaN);
P.CT(P.CT<-2|P.CT>40)=NaN;
P.SA(P.SA<30|P.SA>41)=NaN;
P.CT(supported)=movmean(P.CT(supported),5,'omitnan');
P.SA(supported)=movmean(P.SA(supported),5,'omitnan');
valid=supported&isfinite(P.CT)&isfinite(P.SA);
P.Sigma0(valid)=gsw_sigma0(P.SA(valid),P.CT(valid));
end
