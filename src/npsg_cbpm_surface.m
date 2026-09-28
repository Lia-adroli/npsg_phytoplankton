function T = npsg_cbpm_surface(inputFile)
%NPSG_CBPM_SURFACE Read monthly CbPM inputs and calculate Cphyto/Chl:C.
% The existing growth_rate column, if present, is preserved, not inferred.
T=readtable(inputFile,'VariableNamingRule','preserve');
required={'Year','Month','chl_monthly','bbp443'};
if ~all(ismember(required,T.Properties.VariableNames))
    error('CbPM CSV needs: %s',strjoin(required,', '));
end
T.Year=double(T.Year); T.Month=double(T.Month);
if any(~isfinite(T.Year)|T.Year~=fix(T.Year)| ...
        ~isfinite(T.Month)|T.Month<1|T.Month>12|T.Month~=fix(T.Month))
    error('Invalid Year or Month in CbPM CSV.');
end
key=T.Year*100+T.Month;
if numel(unique(key))~=height(T), error('Duplicate CbPM year/month.'); end
T.Cphyto=npsg_surface_carbon(double(T.bbp443));
T.chlC_obs=double(T.chl_monthly)./T.Cphyto;
T.chlC_obs(~isfinite(T.chlC_obs))=NaN;
end
