% Run from the repository root after addpath(fullfile(pwd,'src')).
inputFile=fullfile('data','daily_mean.csv');
if ~isfile(inputFile), error('Place daily_mean.csv in data/ first.'); end
T=readtable(inputFile,'VariableNamingRule','preserve');
required={'date1','chl','zeu','kd490'};
if ~all(ismember(required,T.Properties.VariableNames))
    error('Missing daily column(s): %s',strjoin(setdiff(required,T.Properties.VariableNames),', '));
end
if isdatetime(T.date1)
    dates=T.date1;
else
    dates=datetime(string(T.date1),'InputFormat','d/M/yyyy');
end
[chl,chlKeep]=npsg_screen_daily(dates,T.chl);
[zeu,zeuKeep]=npsg_screen_daily(dates,T.zeu);
[kd,kdKeep]=npsg_screen_daily(dates,T.kd490);
fprintf('Retained daily dates: Chl %d/%d, Zeu %d/%d, Kd490 %d/%d\n', ...
    nnz(chlKeep),numel(chlKeep),nnz(zeuKeep),numel(zeuKeep),nnz(kdKeep),numel(kdKeep));
% Individual tables may have different date coverage; do not align by row.
% Monthly median-based factor-3 screening remains to be defined.
