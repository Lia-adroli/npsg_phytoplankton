function [daily,keep] = npsg_screen_daily(time,value)
%NPSG_SCREEN_DAILY Median by calendar day, then 61-observation MAD screen.
% NaN values omitted. A window needs >=15 finite daily observations.
time=time(:); value=double(value(:));
if numel(time)~=numel(value), error('Time and values lengths differ.'); end
if ~isdatetime(time), error('Time must be datetime.'); end
ok=~isnat(time) & isfinite(value);
day=dateshift(time(ok),'start','day'); v=value(ok);
[days,~,g]=unique(day);
med=splitapply(@median,v,g);
center=movmedian(med,61,'omitnan','Endpoints','shrink');
deviation=abs(med-center);
sigma=1.4826*movmedian(deviation,61,'omitnan','Endpoints','shrink');
localCount=movsum(isfinite(med),61,'Endpoints','shrink');
keep=~(localCount>=15 & isfinite(sigma) & ...
    deviation>3*sigma);
daily=table(days,med,'VariableNames',{'Date','Median'});
daily.Median(~keep)=NaN;
end
