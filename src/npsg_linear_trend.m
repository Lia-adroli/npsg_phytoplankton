function result = npsg_linear_trend(x,y,minN)
%NPSG_LINEAR_TREND Ordinary least squares slope, intercept and R^2.
if nargin<3, minN=10; end
x=double(x(:)); y=double(y(:));
if numel(x)~=numel(y), error('Predictor and response lengths differ.'); end
ok=isfinite(x)&isfinite(y); x=x(ok); y=y(ok);
result=struct('n',numel(x),'slope',NaN,'intercept',NaN,'r2',NaN,'sse',NaN);
if numel(x)<minN || numel(unique(x))<2, return; end
p=polyfit(x,y,1); residual=y-polyval(p,x);
result.slope=p(1); result.intercept=p(2);
result.sse=sum(residual.^2);
sst=sum((y-mean(y)).^2);
if sst>0, result.r2=1-result.sse/sst; end
end
