function keep = npsg_qc_is_one(qc)
%NPSG_QC_IS_ONE Compare Argo QC flags without string-to-number loops.
if isnumeric(qc) || islogical(qc)
    keep=qc==1;
else
    keep=strtrim(string(qc))=="1";
end
keep=keep(:);
end
