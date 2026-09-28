function products = npsg_physical_products(rows,zeu,targetSigma)
%NPSG_PHYSICAL_PRODUCTS 1-m TEOS-10 physical Argo aggregation and heat.
% rows are npsg_physical_filter output. zeu has Year, Month, Zeu_m.
% No profile extrapolation. Heat layers average only supported depth cells;
% their output reports covered thickness in each dynamic layer.
if nargin<3, targetSigma=[24 25 26]; end
if nargin<2, zeu=table(); end
if ~isempty(zeu)
    assert(all(ismember({'Year','Month','Zeu_m'},zeu.Properties.VariableNames)), ...
        'zeu must contain Year, Month, Zeu_m.');
end
products=struct('annual',table(),'monthlyMLD',table(), ...
    'isopycnals',table(),'monthlyLayers',table(),'annualLayers',table());
if isempty(rows), return; end
assert(all(ismember({'Platform','Cycle','Time','SP','Temperature', ...
    'Pressure_dbar','Latitude','Longitude360'},rows.Properties.VariableNames)), ...
    'Pass npsg_physical_filter output.');
years=unique(year(rows.Time)); annualPieces=cell(numel(years),1);
mldParts=cell(numel(years),1); isoParts=cell(numel(years),1);
layerParts=cell(numel(years),1);
for iy=1:numel(years)
    fprintf('Physical annual profiles: %d (%d/%d)\n',years(iy),iy,numel(years));
    R=rows(year(rows.Time)==years(iy),:);
    key=R.Platform+"_"+R.Cycle+"_"+string(dateshift(R.Time,'start','day'));
    [group,~]=findgroups(key);
    [group,order]=sort(group); R=R(order,:);
    first=[1;find(diff(group)>0)+1]; last=[first(2:end)-1;numel(group)];
    ct=cell(max(group),1); sa=ct; density=ct;
    py=NaN(max(group),1); pm=py; pp=strings(max(group),1);
    ml=py; iso=NaN(max(group),numel(targetSigma)); used=0;
    for k=1:max(group)
        q=R(first(k):last(k),:);
        P=npsg_physical_profile_original(q.SP,q.Temperature,q.Pressure_dbar, ...
            median(q.Longitude360,'omitnan'),median(q.Latitude,'omitnan'));
        if ~any(isfinite(P.CT)), continue; end
        used=used+1; py(used)=years(iy); pm(used)=month(q.Time(1));
        pp(used)=q.Platform(1);
        [~,iso(used,:)]=npsg_mld_isopycnal(P.Depth_m,P.Sigma0,targetSigma);
        if ~isempty(zeu)
            iZ=find(zeu.Year==py(used)&zeu.Month==pm(used),1);
            if ~isempty(iZ)
                ml(used)=npsg_mld_grid_threshold(P,zeu.Zeu_m(iZ));
            end
        end
        ct{used}=oneProfile(py(used),pm(used),pp(used),P.Depth_m,P.CT);
        sa{used}=oneProfile(py(used),pm(used),pp(used),P.Depth_m,P.SA);
        density{used}=oneProfile(py(used),pm(used),pp(used),P.Depth_m,P.Sigma0);
    end
    if used==0, continue; end
    C=vertcat(ct{1:used}); S=vertcat(sa{1:used}); D=vertcat(density{1:used});
    aC=npsg_physical_annual(C,6);
    aS=npsg_physical_annual(S,6);
    aD=npsg_physical_annual(D,6);
    if ~isempty(aC)
        A=aC(:,{'Year','Depth_m','Value','NPlatforms'});
        A.Properties.VariableNames{'Value'}='CT_degC';
        A.SA_g_kg=matchDepth(A,aS);
        A.Sigma0_kg_m3=matchDepth(A,aD);
        annualPieces{iy}=A;
    end
    isoParts{iy}=table(py(1:used),pm(1:used),pp(1:used), ...
        ml(1:used),iso(1:used,:), ...
        'VariableNames',{'Year','Month','Platform','MLD_m','IsopycnalDepth_m'});
    valid=isfinite(ml(1:used));
    if any(valid)
        [g,y,m]=findgroups(py(valid),pm(valid));
        mldParts{iy}=table(y,m,splitapply(@mean,ml(valid),g), ...
            'VariableNames',{'Year','Month','MLD_m'});
    end
    % First median within each platform/month/depth, then equal platforms.
    if ~isempty(zeu) && ~isempty(mldParts{iy}) && ~isempty(C)
        [g,y,m,p,z]=findgroups(C.Year,C.Month,C.Platform,C.Depth_m);
        med=splitapply(@median,C.Value,g);
        [g,y,m,z]=findgroups(y,m,z);
        meanCT=splitapply(@mean,med,g);
        months=unique(m);
        L=table();
        for j=1:numel(months)
            mm=months(j); b=mldParts{iy};
            iMLD=find(b.Month==mm,1); iZ=find(zeu.Year==years(iy)&zeu.Month==mm,1);
            if isempty(iMLD)||isempty(iZ), continue; end
            select=m==mm;
            zFull=(0:300)'; ctFull=NaN(size(zFull));
            ctFull(z(select)+1)=meanCT(select);
            H=npsg_layer_mean_ohc(zFull,ctFull, ...
                b.MLD_m(iMLD),zeu.Zeu_m(iZ));
            L=[L;table(years(iy),mm,b.MLD_m(iMLD),zeu.Zeu_m(iZ), ...
                H.surfaceToMLD,H.MLDToZeu,H.ZeuTo300,H.covered_m(1), ...
                H.covered_m(2),H.covered_m(3), ...
                'VariableNames',{'Year','Month','MLD_m','Zeu_m', ...
                'SurfaceToMLD_GJ_m3','MLDToZeu_GJ_m3','ZeuTo300_GJ_m3', ...
                'SurfaceToMLD_Covered_m','MLDToZeu_Covered_m', ...
                'ZeuTo300_Covered_m'})]; %#ok<AGROW>
        end
        layerParts{iy}=L;
    end
end
annualPieces=annualPieces(~cellfun(@isempty,annualPieces));
if ~isempty(annualPieces)
    A=vertcat(annualPieces{:});
    A.OHC_J_m3=1025*3985*A.CT_degC;
    [g,~]=findgroups(A.Depth_m);
    base=splitapply(@(x)mean(x,'omitnan'),A.CT_degC,g);
    A.OHC_Anomaly_J_m3=1025*3985*(A.CT_degC-base(g));
    products.annual=sortrows(A,{'Year','Depth_m'});
end
mldParts=mldParts(~cellfun(@isempty,mldParts));
if ~isempty(mldParts), products.monthlyMLD=vertcat(mldParts{:}); end
isoParts=isoParts(~cellfun(@isempty,isoParts));
if ~isempty(isoParts), products.isopycnals=vertcat(isoParts{:}); end
layerParts=layerParts(~cellfun(@isempty,layerParts));
if ~isempty(layerParts)
    products.monthlyLayers=vertcat(layerParts{:});
    T=products.monthlyLayers;
    [g,y]=findgroups(T.Year);
    layerNames={'SurfaceToMLD_GJ_m3','MLDToZeu_GJ_m3','ZeuTo300_GJ_m3'};
    annual=table(y,'VariableNames',{'Year'});
    for j=1:numel(layerNames)
        v=T.(layerNames{j});
        annual.(layerNames{j})=splitapply(@(x)mean(x,'omitnan'),v,g);
        n=splitapply(@(x)nnz(isfinite(x)),v,g);
        annual.(layerNames{j})(n<6)=NaN;
        annual.(['NMonths_' layerNames{j}])=n;
    end
    products.annualLayers=annual;
end
end

function T=oneProfile(y,m,p,z,v)
ok=isfinite(v);
T=table(repmat(y,nnz(ok),1),repmat(m,nnz(ok),1), ...
    repmat(p,nnz(ok),1),z(ok),v(ok), ...
    'VariableNames',{'Year','Month','Platform','Depth_m','Value'});
end

function v=matchDepth(A,B)
v=NaN(height(A),1);
if isempty(B), return; end
[hit,idx]=ismember(A.Year*1000+A.Depth_m,B.Year*1000+B.Depth_m);
v(hit)=B.Value(idx(hit));
end
