function T = npsg_surface_products(opticalFile,dailyFile)
%NPSG_SURFACE_PRODUCTS Monthly bbp443 -> Cphyto; matched monthly Chl:C.
% opticalFile schema: Date (d/M/yyyy), Kd490, Zeu_from_Kd490, ZSD,
% PAR_surf, bbp443. dailyFile is optional; when absent Chl:C is NaN.
% When supplied, chl is the mean of QC-screened daily regional chl values
% in the SAME calendar month. Require >=10 valid days; screen each calendar
% month's series across years via isoutlier(...,'median','ThresholdFactor',3).
opts=detectImportOptions(opticalFile,'VariableNamingRule','preserve');
if ~ismember('Date',opts.VariableNames), error('Optical CSV needs Date.'); end
opts=setvartype(opts,'Date','string');
T=readtable(opticalFile,opts);
required={'Kd490','Zeu_from_Kd490','ZSD','PAR_surf','bbp443'};
if ~all(ismember(required,T.Properties.VariableNames))
    error('Missing optical column(s): %s',strjoin(setdiff(required,T.Properties.VariableNames),', '));
end
T.Date=datetime(T.Date,'InputFormat','d/M/yyyy');
if any(isnat(T.Date)), error('Invalid optical Date (expected d/M/yyyy).'); end
T.Year=year(T.Date); T.Month=month(T.Date);
key=100*T.Year+T.Month;
if numel(unique(key))~=height(T), error('Duplicate optical calendar month.'); end
bbp=double(T.bbp443);
used=bbp;
used(isfinite(used)&used<0.00035)=0.00036;
T.bbp443_used_m1=used;
T.Cphyto_mgC_m3=npsg_surface_carbon(bbp);
T.chl_monthly=NaN(height(T),1);
T.NDailyChl=NaN(height(T),1);
if nargin>=2 && ~isempty(dailyFile)
    opts=detectImportOptions(dailyFile,'VariableNamingRule','preserve');
    if ~all(ismember({'date1','chl'},opts.VariableNames))
        error('Daily CSV needs date1 and chl.');
    end
    opts=setvartype(opts,'date1','string');
    D=readtable(dailyFile,opts);
    dates=datetime(D.date1,'InputFormat','d/M/yyyy');
    [clean,~]=npsg_screen_daily(dates,D.chl);
    groupKey=100*year(clean.Date)+month(clean.Date);
    [g,months]=findgroups(groupKey);
    monthlyChl=splitapply(@(x)mean(x,'omitnan'),clean.Median,g);
    nDays=splitapply(@(x)sum(isfinite(x)),clean.Median,g);
    [found,loc]=ismember(key,months);
    T.chl_monthly(found)=monthlyChl(loc(found));
    T.NDailyChl(found)=nDays(loc(found));
    T.chl_monthly(T.NDailyChl<10)=NaN;
    for calendarMonth=1:12
        ix=find(T.Month==calendarMonth & isfinite(T.chl_monthly));
        if numel(ix)>=4
            out=isoutlier(T.chl_monthly(ix),'median','ThresholdFactor',3);
            T.chl_monthly(ix(out))=NaN;
        end
    end
end
T.Chl_to_C_mg_mg=T.chl_monthly./T.Cphyto_mgC_m3;
T.Chl_to_C_mg_mg(~isfinite(T.Chl_to_C_mg_mg))=NaN;
end
