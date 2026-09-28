function tests=test_methods
tests=functiontests(localfunctions);
end

function testCarbon(t)
verifyEqual(t,npsg_surface_carbon([0.0003;0.0005]),[0.13;1.95], ...
    'AbsTol',1e-10);
[C,b,ratio]=npsg_profile_carbon(0.001,0.2);
verifyEqual(t,b,0.001*(470/700)^(-0.78),'RelTol',1e-12);
verifyEqual(t,ratio,0.2/C,'RelTol',1e-12);
end

function testMonthlyOpticalFile(t)
inputFile=[tempname '.csv'];
O=table(["1/1/1998";"1/2/1998"],[0.028377;0.027666], ...
    [104.0026;105.6465],[38.59034;40.40741], ...
    [36.13477;42.07552],[0.000889;0.000979], ...
    'VariableNames',{'Date','Kd490','Zeu_from_Kd490', ...
    'ZSD','PAR_surf','bbp443'});
writetable(O,inputFile);
cleanup=onCleanup(@()delete(inputFile)); %#ok<NASGU>
T=npsg_surface_products(inputFile);
verifyEqual(t,height(T),2);
verifyEqual(t,T.Cphyto_mgC_m3(1),7.007,'AbsTol',1e-12);
verifyTrue(t,isnan(T.Chl_to_C_mg_mg(1)));
verifyEqual(t,T.Zeu_from_Kd490(1),104.0026,'AbsTol',1e-12);
verifyEqual(t,T.Year(end),1998);
verifyEqual(t,T.Month(end),2);
verifyEqual(t,T.Month(2),2);
end

function testCbpmMonthlyCarbon(t)
inputFile=[tempname '.csv'];
C=table([1998;1998],[1;2],[0.071883;0.067386], ...
    [0.000889;0.000979], ...
    'VariableNames',{'Year','Month','chl_monthly','bbp443'});
writetable(C,inputFile);
cleanup=onCleanup(@()delete(inputFile)); %#ok<NASGU>
T=npsg_cbpm_surface(inputFile);
verifyEqual(t,T.Cphyto(1),7.007,'AbsTol',1e-12);
verifyEqual(t,T.chlC_obs(1),0.071883/7.007,'RelTol',1e-12);
verifyEqual(t,height(T),2);
end

function testDailyScreen61(t)
dates=datetime(2000,1,1)+days(0:60);
v=ones(61,1); v(31)=10;
[daily,keep]=npsg_screen_daily(dates,v);
verifyFalse(t,keep(31));
verifyTrue(t,isnan(daily.Median(31)));
end

function testLightAndOxygen(t)
[I,z]=npsg_isolumes(40,0.05,0);
verifyEqual(t,I,40);
verifyEqual(t,40*exp(-0.05*z.z1),0.4,'AbsTol',1e-12);
verifyEqual(t,npsg_aou(180,210),30);
end

function testMLDAndHeat(t)
[mld,iso]=npsg_mld_isopycnal([0;10;20;30],[24;24;24.06;24.12],24.09);
verifyEqual(t,mld,15,'AbsTol',1e-10);
verifyEqual(t,iso,25,'AbsTol',1e-10);
[~,a]=npsg_ohc_anomaly(21,20);
verifyEqual(t,a,1025*3985);
[~,a,b]=npsg_annual_ohc_anomaly([20 10;22 14]);
verifyEqual(t,b,[21 12]);
verifyEqual(t,a(1,:),[-1 -2]*1025*3985);
end

function testSourceGridMLDThreshold(t)
P=table((0:300)',24+0.004*(0:300)', ...
    'VariableNames',{'Depth_m','Sigma0'});
verifyEqual(t,npsg_mld_grid_threshold(P,105),18);
verifyTrue(t,isnan(npsg_mld_grid_threshold(P,NaN)));
end

function testBreakpoint(t)
x=(1998:2024)'; y=[(1:14)';14+3*(1:13)'];
r=npsg_breakpoint(x,y,40,3);
verifyTrue(t,any(r.splitYear==x(5:end-5)));
verifyGreaterThan(t,r.deltaBIC,0);
verifyEqual(t,r.supported,r.pSupF<0.05 || r.deltaBIC>=2);
verifyEqual(t,r.supportedStrict,r.pSupF<0.05 && r.pSlopeChange<0.05 && r.deltaBIC>=2);
verifyEqual(t,r.replicates,40);
end

function testAdjustedQCInventory(t)
T=table([1;2],[1;3],[0.001;NaN],[200;NaN], ...
    'VariableNames',{'CHLA_ADJUSTED','CHLA_ADJUSTED_QC', ...
    'BBP700_ADJUSTED','DOXY_ADJUSTED'});
R=npsg_argo_qc_report(T,'bgc');
verifyEqual(t,R.FiniteAdjustedQC1(R.Variable=="CHLA"),1);
verifyEqual(t,R.Status(R.Variable=="BBP700"),"OWN_ADJUSTED_QC_NOT_CHECKED");
verifyEqual(t,R.Status(R.Variable=="DOXY"),"OWN_ADJUSTED_QC_NOT_CHECKED");
verifyEqual(t,R.FiniteValues(R.Variable=="DOXY"),1);
verifyEqual(t,R.FinitePassingSharedGate(R.Variable=="DOXY"),1);
end

function testNumericColumn(t)
verifyEqual(t,npsg_numeric_column([1;NaN;3]),[1;NaN;3]);
verifyEqual(t,npsg_numeric_column(["1";"";"3"]),[1;NaN;3]);
verifyEqual(t,npsg_qc_is_one([1;3;NaN]),[true;false;false]);
verifyEqual(t,npsg_qc_is_one(["1";"3";" "]),[true;false;false]);
end

function testAdjustedOxygenSharedGate(t)
months=repelem((1:10)',11);
T=table(repelem(string(1:10)',11),repmat("f",110,1),repmat(2020,110,1), ...
    months,repmat((1:11)',10,1),repmat(3169.492,110,1), ...
    repmat(25,110,1),repmat(-160,110,1), ...
    repmat(35,110,1),repmat(24,110,1),ones(110,1), ...
    'VariableNames',{'PROFILE_ID','PLATFORM_NUMBER','YEAR','MONTH', ...
    'PRES_ADJUSTED','DOXY_ADJUSTED','LATITUDE','LONGITUDE', ...
    'PSAL_ADJUSTED','TEMP_ADJUSTED','CHLA_ADJUSTED_QC'});
T.DOXY_ADJUSTED(1)=NaN; T.CHLA_ADJUSTED_QC(1:2)=3;
T.BBP700_ADJUSTED=repmat(0.0005,110,1);
[rows,info]=npsg_bgc_filter(T,'DOXY',2020,5,10);
verifyEqual(t,info.largeValueCorrections,109);
verifyEqual(t,info.adjustedValue,"DOXY_ADJUSTED");
verifyEqual(t,info.qcGate,"CHLA_ADJUSTED_QC_EQ_1");
verifyEqual(t,height(rows),108);
verifyEqual(t,rows.Value(1),316.9492,'AbsTol',1e-10);
[bbp,infoBBP]=npsg_bgc_filter(T,'BBP700',2020,5,10);
verifyEqual(t,height(bbp),108);
verifyEqual(t,infoBBP.qcGate,"CHLA_ADJUSTED_QC_EQ_1");
verifyEqual(t,bbp.SourceRow(1),3);
end

function testCosineWeighting(t)
field=[10 10;20 20];
v=npsg_coslat_mean(field,[0;60]);
verifyEqual(t,v,(10*1+20*0.5)/1.5,'AbsTol',1e-12);
end

function testIndependentPlatformWeighting(t)
% Platform A has two observations/month, B one; annual should average
% platform means equally after monthly medians, not weight the extra row.
y=[repmat(2020,9,1)]; m=[1;1;2;2;3;3;1;2;3];
p=[repmat("A",6,1);repmat("B",3,1)];
z=ones(9,1)*50; v=[2;2;2;2;2;2;8;8;8];
rows=table(y,m,p,z,v,'VariableNames',{'Year','Month','Platform','Depth_m','Value'});
a=npsg_bgc_annual(rows,3);
verifyEqual(t,a.Value,5,'AbsTol',1e-12);
end

function testPhysicalSixMonthPlatformWeighting(t)
% Platform A has duplicate casts in each month; B has one. A and B have
% equal weight after within-month medians and the six-month threshold.
y=repmat(2020,18,1);
m=[repelem((1:6)',2);(1:6)'];
p=[repmat("A",12,1);repmat("B",6,1)];
z=ones(18,1)*100; v=[ones(12,1)*2;ones(6,1)*8];
rows=table(y,m,p,z,v,'VariableNames', ...
    {'Year','Month','Platform','Depth_m','Value'});
a=npsg_physical_annual(rows,6);
verifyEqual(t,a.Value,5,'AbsTol',1e-12);
verifyEqual(t,a.NPlatforms,2);
end

function testExactLayerPartition(t)
z=(0:300)'; ct=ones(size(z))*2;
h=npsg_layer_heat(z,ct,15.5,100.25);
factor=1025*3985*2;
verifyEqual(t,h.surfaceToMLD,15.5*factor,'RelTol',1e-12);
verifyEqual(t,h.MLDToZeu,(100.25-15.5)*factor,'RelTol',1e-12);
verifyEqual(t,h.ZeuTo300,(300-100.25)*factor,'RelTol',1e-12);
end

function testVolumetricHeatLayerWithMissingCells(t)
z=(0:300)'; ct=ones(size(z))*2; ct(51:60)=NaN;
h=npsg_layer_mean_ohc(z,ct,15.5,100.25);
verifyEqual(t,h.surfaceToMLD,1025*3985*2/1e9,'RelTol',1e-12);
verifyEqual(t,h.MLDToZeu,1025*3985*2/1e9,'RelTol',1e-12);
verifyLessThan(t,h.covered_m(2),100.25-15.5);
verifyEqual(t,sum(h.covered_m),290,'AbsTol',1e-10);
end

function testDCMSearch(t)
[depth,peak]=npsg_dcm([5;25;125;255],[9;1;3;10]);
verifyEqual(t,depth,125);
verifyEqual(t,peak,3);
end

function testDisplayDoesNotBridgeGap(t)
[yr,~,shown]=npsg_display_field((2000:2004)',[0;2], ...
    [1 1;2 2;NaN NaN;4 4;5 5]);
verifyTrue(t,all(isnan(shown(yr>2001 & yr<2003,:)),'all'));
verifyEqual(t,shown(yr==2000,1),1);
end
