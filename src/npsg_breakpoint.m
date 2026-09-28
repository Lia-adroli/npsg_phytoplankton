function r = npsg_breakpoint(years,y,B,seed)
%NPSG_BREAKPOINT Global two-line split plus continuous hinge diagnostic.
% Implements the attached physical-analysis script's sup-F and t statistics.
% Formal support follows Table S6: sup-F p<0.05 OR deltaBIC>=2.
% The alternative strict all-three rule is also returned as a diagnostic.
if nargin<3||isempty(B), B=1000; end
if nargin<4, seed=1; end
validateattributes(B,{'numeric'},{'scalar','integer','positive'});
x=double(years(:)); y=double(y(:));
if numel(x)~=numel(y), error('Year and response lengths differ.'); end
ok=isfinite(x)&isfinite(y); x=x(ok); y=y(ok);
[x,ii]=sort(x); y=y(ii); n=numel(x);
if n<10||numel(unique(x))~=n
    error('At least 10 unique annual observations are required.');
end
xc=x-mean(x);
X=[ones(n,1),xc]; beta=X\y; fitted=X*beta;
residual=y-fitted; sse0=sum(residual.^2);
splits=5:(n-5);
[sse,F,hingeT,pre,post,hingeSSE]=scan(x,xc,y,splits,sse0);
[sseBest,j]=min(sse); bestSplit=splits(j);
fObs=max(F(isfinite(F)));
if isempty(fObs), fObs=NaN; end
tObs=max(hingeT(isfinite(hingeT)));
if isempty(tObs), tObs=NaN; end
[~,hidx]=min(hingeSSE);
e=residual-mean(residual);
state=rng; cleanup=onCleanup(@()rng(state)); rng(seed,'twister');
fBoot=NaN(B,1); tBoot=NaN(B,1);
for b=1:B
    sim=fitted+e(randi(n,n,1));
    nullResidual=sim-X*(X\sim);
    [~,fb,tb]=scan(x,xc,sim,splits,sum(nullResidual.^2));
    f=fb(isfinite(fb)); t=tb(isfinite(tb));
    if ~isempty(f), fBoot(b)=max(f); end
    if ~isempty(t), tBoot(b)=max(t); end
end
validF=isfinite(fBoot); validT=isfinite(tBoot);
pF=NaN; pT=NaN;
if isfinite(fObs), pF=(1+nnz(fBoot(validF)>=fObs))/(1+nnz(validF)); end
if isfinite(tObs), pT=(1+nnz(tBoot(validT)>=tObs))/(1+nnz(validT)); end
[a0,c0,b0]=ic(sse0,n,3);
[a1,c1,b1]=ic(sseBest,n,6);
r=struct('splitYear',x(bestSplit),'breakPosition', ...
    mean(x(bestSplit:bestSplit+1)),'pre',pre(j),'post',post(j), ...
    'continuousBreakPosition',mean(x(splits(hidx):splits(hidx)+1)), ...
    'supF',fObs,'pSupF',pF,'maxHingeSlopeT',tObs, ...
    'pSlopeChange',pT,'deltaAIC',a0-a1,'deltaAICc',c0-c1, ...
    'deltaBIC',b0-b1,'replicates',B, ...
    'supportedStrict',pF<0.05&&pT<0.05&&(b0-b1)>=2, ...
    'supported',pF<0.05||(b0-b1)>=2);
end

function [sse,F,T,pre,post,hSSE]=scan(x,xc,y,splits,nullSSE)
n=numel(y); m=numel(splits);
sse=NaN(1,m); F=NaN(1,m); T=NaN(1,m); hSSE=NaN(1,m);
blank=struct('n',0,'slope',NaN,'intercept',NaN,'r2',NaN,'sse',NaN);
pre=repmat(blank,1,m); post=pre;
for a=1:m
    k=splits(a);
    X1=[ones(k,1),xc(1:k)]; X2=[ones(n-k,1),xc(k+1:end)];
    b1=X1\y(1:k); b2=X2\y(k+1:end);
    err1=y(1:k)-X1*b1; err2=y(k+1:end)-X2*b2;
    sse(a)=sum(err1.^2)+sum(err2.^2);
    if sse(a)>0
        F(a)=((nullSSE-sse(a))/2)/(sse(a)/(n-4));
    end
    pre(a)=npsg_linear_trend(x(1:k),y(1:k),2);
    post(a)=npsg_linear_trend(x(k+1:end),y(k+1:end),2);
    hinge=max(0,x-mean(x(k:k+1)));
    H=[ones(n,1),xc,hinge]; bh=H\y;
    hSSE(a)=sum((y-H*bh).^2);
    covariance=(hSSE(a)/(n-3))*pinv(H'*H);
    se=sqrt(max(0,covariance(3,3)));
    if se>0&&isfinite(se), T(a)=abs(bh(3)/se); end
end
end

function [aic,aicc,bic]=ic(sse,n,k)
neg2logL=n*(log(2*pi)+1+log(max(sse,eps)/n));
aic=neg2logL+2*k;
aicc=NaN;
if n>k+1, aicc=aic+2*k*(k+1)/(n-k-1); end
bic=neg2logL+k*log(n);
end
