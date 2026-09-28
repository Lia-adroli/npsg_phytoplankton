function report = npsg_argo_qc_report(inputFile,kind)
%NPSG_ARGO_QC_REPORT Inventory adjusted values and shared QC-gate counts.
% A shared gate is NOT a variable-specific QC flag.
if istable(inputFile)
    T=inputFile;
else
    T=readtable(inputFile,'VariableNamingRule','preserve');
end
switch lower(char(kind))
    case 'bgc'
        names={'PRES','PSAL','TEMP','CHLA','BBP700','DOXY'};
    case 'physical'
        names={'PRES','PSAL','TEMP'};
    otherwise
        error('kind must be bgc or physical.');
end
n=numel(names); variable=strings(n,1); adjustedCount=zeros(n,1);
qc1Count=zeros(n,1); sharedCount=zeros(n,1); status=strings(n,1);
if strcmpi(kind,'bgc')
    gate=false(height(T),1);
    if ismember('CHLA_ADJUSTED_QC',T.Properties.VariableNames)
        gate=npsg_qc_is_one(T.CHLA_ADJUSTED_QC);
    end
    gateName="CHLA_ADJUSTED_QC_EQ_1";
else
    gate=false(height(T),1);
    if all(ismember({'PSAL_ADJUSTED_QC','TEMP_ADJUSTED_QC'}, ...
            T.Properties.VariableNames))
        gate=npsg_qc_is_one(T.PSAL_ADJUSTED_QC) & ...
            npsg_qc_is_one(T.TEMP_ADJUSTED_QC);
    end
    gateName="PSAL_AND_TEMP_ADJUSTED_QC_EQ_1";
end
for k=1:n
    variable(k)=names{k}; valueName=[names{k} '_ADJUSTED'];
    qcName=[valueName '_QC'];
    if ~ismember(valueName,T.Properties.VariableNames)
        status(k)="ADJUSTED_COLUMN_MISSING";
        continue;
    end
    v=npsg_numeric_column(T.(valueName));
    adjustedCount(k)=nnz(isfinite(v));
    sharedCount(k)=nnz(isfinite(v)&gate);
    if ~ismember(qcName,T.Properties.VariableNames)
        status(k)="OWN_ADJUSTED_QC_NOT_CHECKED"; continue;
    end
    q1=npsg_qc_is_one(T.(qcName));
    qc1Count(k)=nnz(isfinite(v)&q1);
    if qc1Count(k)==0
        status(k)="NO_FINITE_ADJUSTED_QC1";
    else
        status(k)="ADJUSTED_QC1_AVAILABLE";
    end
end
report=table(variable,adjustedCount,sharedCount,qc1Count,status, ...
    repmat(gateName,n,1), ...
    'VariableNames',{'Variable','FiniteValues','FinitePassingSharedGate', ...
    'FiniteAdjustedQC1','Status','SharedGate'});
end
