% Run from the repository root after addpath(fullfile(pwd,'src')).
% Original physical analysis script set KPAR_from_Kd490_factor=1.0.
inputFile=fullfile('data','monthly_Kd490_Zeu_ZSD.csv');
assert(isfile(inputFile),'Place monthly_Kd490_Zeu_ZSD.csv in data/.');
T=npsg_surface_products(inputFile);
KPAR=T.Kd490; % explicit 1.0 approximation from earlier source script
[~,isolume]=npsg_isolumes(T.PAR_surf,KPAR);
light=table(T.Date,KPAR,isolume.z10,isolume.z1,isolume.z01, ...
    T.Zeu_from_Kd490,'VariableNames', ...
    {'Date','KPAR_m1','Z10_m','Z1_m','Z01_m','Zeu_from_Kd490'});
disp(light(1:min(12,height(light)),:));
if ~isfolder('output'), mkdir('output'); end
writetable(light,fullfile('output','monthly_surface_light.csv'));
% Do not substitute Z1_m for the independently supplied Zeu column.
