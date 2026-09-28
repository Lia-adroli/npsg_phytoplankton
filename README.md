# NPSG manuscript code

MATLAB methods for the North Pacific Subtropical Gyre study (ROI 14–28° N, 160–200° E). This repository supplies calculation code and small test fixtures, not the observational datasets, TEOS-10 GSW toolbox, or the manuscript figures. [COVERAGE.md](COVERAGE.md) maps all 15 rows of Supplementary Table S1 to executable outputs and outstanding source-data gaps. [MANUSCRIPT_TABLE_S1_UPDATE.md](MANUSCRIPT_TABLE_S1_UPDATE.md) gives revised wording for the MLD and breakpoint rows.

## Inputs

Create `data/` alongside `src/` and put these **complete** CSVs there. Inputs and `output/` are ignored by Git.

| Filename | Purpose |
| --- | --- |
| `daily_mean.csv` | Daily regional satellite averages and robust chlorophyll screening |
| `CbPM_surface_only.csv` | Monthly `bbp443` and `chl_monthly` for surface carbon and breakpoint series |
| `monthly_Kd490_Zeu_ZSD.csv` | Monthly Kd490, PAR, bbp443, and supplied `Zeu_from_Kd490` |
| `Final_BGC_Argo_All_Depth_Rows_With_Adjusted.csv` | Adjusted BGC profiles and shared chlorophyll QC flag |
| `ArgoFloats_filtered_qc12_pres1000.csv` | Adjusted physical Argo profiles |

Download NOAA **ERSSTv6** monthly NetCDF files for January 1998–December 2024 to a separate directory. [DATA_SST.md](DATA_SST.md) gives the NOAA link, file pattern and download example. Edit `ersst_folder` in `examples/run_sst_ersstv6.m`; its initial value is `G:\New folder\ersst_v6_data`. Install the [TEOS-10 GSW MATLAB Toolbox](https://www.teos-10.org/software.htm) separately. Full input columns and QC conventions are in [DATA.md](DATA.md). Files in `examples/fixtures/` are tiny tests, not full observations.

## Run in MATLAB

Set MATLAB's Current Folder to the extracted repository root. Run commands individually to see progress and isolate missing inputs:

```matlab
addpath(fullfile(pwd,'src'),fullfile(pwd,'examples'))
setup_gsw('G:\New folder\gsw_matlab_v3_06_16')
results=runtests(fullfile(pwd,'tests'));
assert(all([results.Passed]),'Unit tests failed')

run_surface_carbon
run_surface_light
run_daily_screen
run_bgc_profiles
run_physical_profiles
run_sst_ersstv6
run_breakpoints
```

`run_argo_filters` is an optional QC inventory. The full Argo scripts can take considerable time and memory. `run_breakpoints` calculates MLD **from physical Argo**, with monthly satellite Zeu used for profile selection; it never reads a supplied MLD CSV. Its generated `output/Monthly_MLD.csv` is only a cache and is rebuilt when physical Argo, optical Zeu, or the MLD method version changes. Delete it and `output/Monthly_MLD_cache.mat` to force a fresh run. The bootstrap runs **1000 replicates per series**.

## Outputs and scientific choices

| Runner | Main output under `output/` |
| --- | --- |
| `run_surface_carbon` | `monthly_surface_carbon.csv`, `CbPM_surface_with_carbon.csv` |
| `run_surface_light` | `monthly_surface_light.csv` |
| `run_bgc_profiles` | `bgc_monthly_dcm.csv`, `bgc_annual_dcm.csv`, `bgc_profile_carbon_rows.csv`, `bgc_adjusted_doxy_aou_rows.csv`, `bgc_annual_aou_profile.csv` |
| `run_physical_profiles` | `physical_annual_1m.csv`, `Monthly_MLD.csv`, `physical_profile_isopycnals.csv`, `physical_monthly_heat_layers.csv`, `physical_annual_heat_layers.csv`, `physical_ohc_display_only.mat` |
| `run_sst_ersstv6` | `ersstv6_roi_monthly.csv`, `ersstv6_roi_annual.csv`, `ersstv6_native_grid_trend.csv` |
| `run_breakpoints` | `breakpoint_summary.csv`, `breakpoint_annual_means.csv` |

Surface Cphyto is `13000*(bbp443-0.00035)` with finite bbp443 below 0.00035 replaced by 0.00036. The CbPM monthly `chl_monthly` supplies the matched Chl:C series. BGC bbp700 is converted to bbp470 using `(470/700)^(-0.78)` and then `Cphyto=12128*bbp470+0.59`; chlorophyll and BBP are matched by their **original source row**. Light uses `KPAR=Kd490`; the supplied `Zeu_from_Kd490` is a separate euphotic product, not the calculated 1% isolume.

BGC variables are selected independently with ≥5 valid depth levels/profile and ≥10 distinct months/platform-year. All use **adjusted** CHLA, BBP700, and DOXY, with `CHLA_ADJUSTED_QC==1` as their **shared row gate**. This does not establish BBP or oxygen's own QC. The author's oxygen correction multiplies finite adjusted oxygen above 1000 by 0.1; GSW saturation, range screens and platform plausibility screens precede AOU. Annual 1 m AOU profiles interpolate only within each observed profile, use monthly platform medians, equal platform means, and ≥3 valid months per depth.

Physical Argo uses adjusted T/S with **both** adjusted T and S QC flags 1, finite adjusted pressure 0–300 dbar, ≥10 levels/profile, 2003–2024 January–November. Pressure's own QC is not independently asserted. Before MLD, profiles must reach ≤5 m and ≥290 m, have no vertical gap >50 m, pass a 7-point moving-median spike screen (factor 5), and have SA in 30–41 g kg⁻¹. CT and SA are interpolated within the supported range, smoothed over five 1 m cells, and used to recompute sigma0. MLD is the first integer-metre depth where sigma0 exceeds its 10 m value by 0.03 kg m⁻³, for profiles with density available at the matching monthly Zeu. Monthly MLD is the mean of accepted profile MLDs. Other annual physical depth fields use monthly platform medians, equal months (≥6 represented months/platform/year/depth), then equal platforms. Isopycnal targets `[24 25 26]` kg m⁻³ are editable in `run_physical_profiles` because exact figure targets were not specified. OHC is `1025*3985*CT` J m⁻³; anomalies subtract the available-year mean at each depth.

Dynamic layers use the supplied **monthly Zeu**, monthly MLD and 1 m physical CT. Following the author's physical script, each reported layer is **mean volumetric OHC (GJ m⁻³)** from exact cell overlap with 0–MLD, MLD–Zeu and Zeu–300 m. `*_Covered_m` exposes missing depth support; annual layer means require ≥6 finite months. `physical_ohc_display_only.mat` is separate MAKIMA interpolation at 2 m and 0.25-year spacing; statistics never use it.

Daily screening takes same-day medians and a 61-observation moving median/MAD (scale 1.4826, threshold 3, minimum 15 observations). Monthly annual screens use median threshold factor 3. ERSSTv6 uses cosine-latitude ROI weights, calendar-month-specific outlier screening, ≥6 months/year, and native-grid OLS slopes requiring ≥24 valid months/cell. MATLAB `ncread` applies standard NetCDF fill, scale, and offset attributes. Breakpoint splits require ≥5 annual values on each side. `Supported` follows Table S6 and the original physical script: **sup-F bootstrap p<0.05 OR ΔBIC≥2**. The Davies-type p-value, AIC, AICc, and continuous segmented break are supplementary diagnostics. `SupportedStrictDiagnostic` records the former all-three rule only for transparent comparison. Amend the Table S1 breakpoint row to state the Table S6 rule. The optional growth-rate series requires an already calculated `growth_rate` column; no growth model was supplied.

The source script and repository can still differ numerically because the original physical script did not apply the same adjusted T/S QC-1 row gate and ≥10-level minimum. These requested filters take precedence in this repository; a matching breakpoint year does not establish equal p-values or ΔBIC. Inspect `breakpoint_annual_means.csv` and the derived MLD cache when comparing to the manuscript.

The 4 km spatial chlorophyll trends require **gridded OC-CCI data**: regional average CSVs cannot reproduce a grid map. HOT community plots also require HOT data. The package does not recreate all submitted figures or their confidence interval graphics. See [COVERAGE.md](COVERAGE.md) and [METHODS.md](METHODS.md) for the row-by-row scope.

MATLAB is unavailable in this build environment, so full-data numerical reproduction remains to be checked in MATLAB. Compare row counts, units and results with the manuscript before release.

## Publish on GitHub

Create an empty GitHub repository, extract this archive and run inside `npsg-paper-code`:

```bash
git init
git add .
git commit -m "Add NPSG analysis code"
git branch -M main
git remote add origin https://github.com/YOUR-NAME/YOUR-REPOSITORY.git
git push -u origin main
```

Dataset DOI: [10.5281/zenodo.16659957](https://doi.org/10.5281/zenodo.16659957). Earlier code DOI: [10.5281/zenodo.18396550](https://doi.org/10.5281/zenodo.18396550). Confirm their version relationship before release. No author-selected license is included.
