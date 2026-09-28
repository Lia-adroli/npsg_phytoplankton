function y = npsg_numeric_column(x)
%NPSG_NUMERIC_COLUMN Convert a CSV table column without stringifying numbers.
% readtable commonly imports Argo values and QC flags as numeric arrays.
% Converting millions of those values through string/str2double is slow.
if isnumeric(x) || islogical(x)
    y=double(x);
else
    y=str2double(string(x));
end
y=y(:);
end
