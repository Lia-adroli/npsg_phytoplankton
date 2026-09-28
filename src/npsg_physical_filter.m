function [S,summary] = npsg_physical_filter(inputFile,timeFormat,minLevels)
%NPSG_PHYSICAL_FILTER Shared adjusted T/S QC-1 gate, Jan-Nov 2003-2024.
% Pressure is adjusted and range screened; pressure's own QC is not
% asserted from temperature/salinity flags.
% timeFormat='argo' follows source-script numeric convention: MATLAB
% datenum if median>5e5, otherwise days since 1950-01-01. String dates
% require an explicit InputFormat, or ISO auto-detection.
if nargin<2, timeFormat='argo'; end
if nargin<3||isempty(minLevels), minLevels=10; end
if istable(inputFile)
    T=inputFile;
else
    T=readtable(inputFile,'VariableNamingRule','preserve');
end
required={'PLATFORM_NUMBER','CYCLE_NUMBER','TIME','LATITUDE','LONGITUDE', ...
    'PRES_ADJUSTED','PSAL_ADJUSTED','TEMP_ADJUSTED', ...
    'PSAL_ADJUSTED_QC','TEMP_ADJUSTED_QC'};
if ~all(ismember(required,T.Properties.VariableNames))
    error('Missing physical Argo columns: %s',strjoin(setdiff(required,T.Properties.VariableNames),', '));
end
raw=T.TIME;
if isdatetime(raw)
    tm=raw;
elseif isnumeric(raw)
    if ~strcmpi(timeFormat,'argo')
        error('Numeric TIME requires timeFormat="argo" or upstream conversion.');
    end
    numericTime=double(raw);
    if median(numericTime,'omitnan')>5e5
        tm=datetime(numericTime,'ConvertFrom','datenum');
    else
        tm=datetime(1950,1,1)+days(numericTime);
    end
else
    if strcmpi(timeFormat,'argo')
        formats={'d/M/yyyy','d/M/yyyy HH:mm:ss','dd-MMM-yyyy', ...
            'yyyy-MM-dd','yyyy-MM-dd HH:mm:ss'};
        parsed=false;
        for f=1:numel(formats)
            try
                tm=datetime(string(raw),'InputFormat',formats{f});
                if all(~isnat(tm)), parsed=true; break; end
            catch
            end
        end
        if ~parsed, error('Unparseable TIME: supply its exact InputFormat.'); end
    elseif isempty(timeFormat)
        txt=string(raw);
        if all(~ismissing(txt) & startsWith(txt,"20") & contains(txt,"-"))
            try, tm=datetime(txt);
            catch, error('Supply the explicit InputFormat for TIME.'); end
        else
            error('Supply an explicit timeFormat for non-ISO TIME strings (e.g. ''dd/MM/yyyy'').');
        end
    else
        tm=datetime(string(raw),'InputFormat',timeFormat);
    end
end
if all(isnat(tm))
    error('All TIME values are missing/unparseable. Spreadsheet ####### is not a date.');
end
if ~any(year(tm)>=2003&year(tm)<=2024)
    error('No TIME values in 2003-2024; verify numeric epoch/date format.');
end
lat=double(T.LATITUDE); lon=mod(double(T.LONGITUDE),360);
p=double(T.PRES_ADJUSTED); sp=double(T.PSAL_ADJUSTED); temp=double(T.TEMP_ADJUSTED);
qS=npsg_qc_is_one(T.PSAL_ADJUSTED_QC);
qT=npsg_qc_is_one(T.TEMP_ADJUSTED_QC);
ok=year(tm)>=2003&year(tm)<=2024&month(tm)<=11 & ...
    lat>=14&lat<=28&lon>=160&lon<=200& ...
    isfinite(p)&p>=0&p<=300&isfinite(sp)&isfinite(temp)& ...
    qS&qT;
S=table(string(T.PLATFORM_NUMBER(ok)),string(T.CYCLE_NUMBER(ok)),tm(ok), ...
    lat(ok),lon(ok),p(ok),sp(ok),temp(ok), ...
    'VariableNames',{'Platform','Cycle','Time','Latitude','Longitude360', ...
    'Pressure_dbar','SP','Temperature'});
summary=struct('rowsBefore',height(T),'rowsAfterQC',height(S), ...
    'profiles',0,'rowsRetained',0, ...
    'qcGate',"PSAL_ADJUSTED_QC_EQ_1_AND_TEMP_ADJUSTED_QC_EQ_1", ...
    'pressureOwnQC',"NOT_CHECKED");
if isempty(S), return; end
key=S.Platform+"_"+S.Cycle+"_"+string(dateshift(S.Time,'start','day'));
[g,~]=findgroups(key);
levels=splitapply(@(x)numel(unique(round(x,3))),S.Pressure_dbar,g);
S=S(ismember(g,find(levels>=minLevels)),:);
summary.rowsRetained=height(S);
summary.profiles=numel(unique(key(ismember(g,find(levels>=minLevels)))));
end
