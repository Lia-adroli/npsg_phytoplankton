function [rows,summary] = npsg_aou_gsw(oxygenRows)
%NPSG_AOU_GSW AOU from adjusted DOXY using the shared CHLA QC-1 row gate.
% Input is npsg_bgc_filter(...,'DOXY',...). Finite adjusted DOXY >1000
% has already been multiplied by 0.10 as in the supplied AOU script.
% The CHLA QC flag does not establish oxygen's own QC status.
needed={'gsw_SA_from_SP','gsw_CT_from_t','gsw_O2sol','gsw_rho'};
for k=1:numel(needed)
    if exist(needed{k},'file')~=2, error('Missing GSW function %s.',needed{k}); end
end
required={'SP','Temperature','Pressure_dbar','Longitude360','Latitude', ...
    'Value','Platform'};
if ~all(ismember(required,oxygenRows.Properties.VariableNames))
    error('Input must be filtered BGC DOXY rows with hydrography.');
end
rows=oxygenRows;
n=height(rows);
rows.O2sat_umol_kg=NaN(n,1);
rows.AOU_umol_kg=NaN(n,1);
rows.Density_kg_m3=NaN(n,1);
good=isfinite(rows.Pressure_dbar)&isfinite(rows.SP)& ...
    rows.SP>=30&rows.SP<=40&isfinite(rows.Temperature)& ...
    rows.Temperature>=-2&rows.Temperature<=40& ...
    isfinite(rows.Latitude)&isfinite(rows.Longitude360);
if any(good)
    p=rows.Pressure_dbar(good);
    lon=rows.Longitude360(good); lat=rows.Latitude(good);
    SA=gsw_SA_from_SP(rows.SP(good),p,lon,lat);
    CT=gsw_CT_from_t(SA,rows.Temperature(good),p);
    rows.O2sat_umol_kg(good)=gsw_O2sol(SA,CT,p,lon,lat);
    rows.Density_kg_m3(good)=gsw_rho(SA,CT,p);
    rows.AOU_umol_kg(good)=rows.O2sat_umol_kg(good)-rows.Value(good);
end
valid=good&isfinite(rows.Value)&rows.Value>=0&rows.Value<=600& ...
    isfinite(rows.Density_kg_m3)&isfinite(rows.AOU_umol_kg)& ...
    rows.AOU_umol_kg>=-50&rows.AOU_umol_kg<=250;
platforms=unique(rows.Platform);
accepted=false(numel(platforms),1);
for j=1:numel(platforms)
    in=rows.Platform==platforms(j);
    total=nnz(in&isfinite(rows.Value));
    v=in&valid;
    if total==0||~any(v), continue; end
    medO2=median(rows.Value(v)); medAOU=median(rows.AOU_umol_kg(v));
    accepted(j)=nnz(v)/total>=0.80 && medO2>=100 && medO2<=300 && ...
        medAOU>=-30 && medAOU<=150;
end
rows=rows(valid&ismember(rows.Platform,platforms(accepted)),:);
summary=struct('inputRows',n,'validRowsBeforePlatformQC',nnz(valid), ...
    'acceptedPlatforms',nnz(accepted),'retainedRows',height(rows), ...
    'oxygenSource',"DOXY_ADJUSTED", ...
    'qcGate',"CHLA_ADJUSTED_QC_EQ_1", ...
    'oxygenOwnQC',"NOT_CHECKED");
end
