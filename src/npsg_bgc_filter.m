function [S,summary] = npsg_bgc_filter(inputFile,variable,yearsRequested,minLevels,minMonths)
%NPSG_BGC_FILTER Independent BGC profile and platform-year selection.
% Every variable uses adjusted values and the SAME CHLA_ADJUSTED_QC==1
% row gate. This does not certify BBP700 or DOXY's own QC flags.
% Pressure in the CSV is dbar. For exact metre depths use GSW conversion.
if nargin<3||isempty(yearsRequested)
    yearsRequested=[2016 2017 2020 2021 2022 2023 2024];
end
if nargin<4||isempty(minLevels), minLevels=5; end
if nargin<5||isempty(minMonths), minMonths=10; end
variable=upper(char(variable));
switch variable
    case 'CHLA', vName='CHLA_ADJUSTED';
    case 'BBP700', vName='BBP700_ADJUSTED';
    case 'DOXY', vName='DOXY_ADJUSTED';
    otherwise, error('Variable must be CHLA, BBP700, or DOXY.');
end
if istable(inputFile)
    T=inputFile;
else
    T=readtable(inputFile,'VariableNamingRule','preserve');
end
required={'PROFILE_ID','PLATFORM_NUMBER','YEAR','MONTH','LATITUDE', ...
    'LONGITUDE','PRES_ADJUSTED','CHLA_ADJUSTED_QC',vName};
if ~all(ismember(required,T.Properties.VariableNames))
    error('Missing BGC columns: %s',strjoin(setdiff(required,T.Properties.VariableNames),', '));
end
p=double(T.PRES_ADJUSTED); val=double(T.(vName));
if strcmp(variable,'DOXY')
    % Same magnitude correction as the supplied AOU script, now applied
    % only to finite adjusted oxygen values.
    large=isfinite(val)&val>1000;
    val(large)=0.10*val(large);
end
lon=mod(double(T.LONGITUDE),360); lat=double(T.LATITUDE);
ok=ismember(double(T.YEAR),yearsRequested)&double(T.MONTH)>=1& ...
    double(T.MONTH)<=12&isfinite(p)&p>=0&p<=300&isfinite(val);
ok=ok & npsg_qc_is_one(T.CHLA_ADJUSTED_QC);
if strcmp(variable,'DOXY')
    ok=ok & val>=0 & val<=600;
elseif strcmp(variable,'CHLA')||strcmp(variable,'BBP700')
    ok=ok & val>=0;
end
S=table(string(T.PROFILE_ID(ok)),string(T.PLATFORM_NUMBER(ok)), ...
    double(T.YEAR(ok)),double(T.MONTH(ok)),p(ok),val(ok),lat(ok),lon(ok), ...
    'VariableNames',{'ProfileID','Platform','Year','Month','Pressure_dbar', ...
    'Value','Latitude','Longitude360'});
S.SourceRow=find(ok); % exact input-row match across independent filters
if strcmp(variable,'DOXY')
    for name={'PSAL_ADJUSTED','TEMP_ADJUSTED'}
        if ~ismember(name{1},T.Properties.VariableNames)
            error('Adjusted DOXY AOU requires %s.',name{1});
        end
    end
    S.SP=double(T.PSAL_ADJUSTED(ok));
    S.Temperature=double(T.TEMP_ADJUSTED(ok));
end
summary=struct('rowsBefore',height(T),'rowsAfterQC',height(S),'profiles',0, ...
    'platformYears',0,'rowsRetained',0,'variable',variable, ...
    'adjustedValue',string(vName),'qcGate',"CHLA_ADJUSTED_QC_EQ_1", ...
    'ownAdjustedQC',"NOT_CHECKED");
if strcmp(variable,'CHLA'), summary.ownAdjustedQC="QC1_VERIFIED"; end
if strcmp(variable,'DOXY')
    summary.largeValueCorrections=nnz(large);
end
if isempty(S), return; end
[g,~]=findgroups(S.ProfileID);
levels=splitapply(@(x)numel(unique(round(x,3))),S.Pressure_dbar,g);
S=S(ismember(g,find(levels>=minLevels)),:);
if isempty(S), return; end
key=S.Platform+"_"+string(S.Year);
[g,~]=findgroups(key);
months=splitapply(@(x)numel(unique(x)),S.Month,g);
S=S(ismember(g,find(months>=minMonths)),:);
% Coverage is assessed along the platform-year trajectory; analysis rows
% are subsequently restricted to the ROI it entered.
S=S(S.Latitude>=14&S.Latitude<=28&S.Longitude360>=160& ...
    S.Longitude360<=200,:);
summary.rowsRetained=height(S);
summary.profiles=numel(unique(S.ProfileID));
summary.platformYears=numel(unique(S.Platform+"_"+string(S.Year)));
end
