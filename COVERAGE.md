# Supplementary Table S1: executable coverage

The status describes what the provided commands **calculate and save**, not whether full-data results have been validated. Run the MATLAB tests and compare against manuscript values before publishing numerical claims.

| No. | Method | Runner and scope |
| --- | --- | --- |
| 1 | Regional averaging | `run_sst_ersstv6` reads native NOAA grids and applies cos(latitude) weighting. Satellite regionally averaged CSVs start after the original spatial averaging; the original 4 km averaging cannot be rebuilt from them. |
| 2 | Carbon, Chl:C | `run_surface_carbon` saves monthly surface products; `run_bgc_profiles` saves adjusted BBP700 carbon and row-matched Chl:C. |
| 3 | Irradiance, isolumes | `run_surface_light` calculates Beer–Lambert irradiance and 10%, 1%, 0.1% depths from KPAR=Kd490; source Zeu remains separate. |
| 4 | BGC selection | `run_bgc_profiles` filters CHLA, BBP700 and DOXY independently using shared CHLA adjusted QC-1 row gate, ≥5 levels/profile and ≥10 months/platform-year. |
| 5 | DCM | `run_bgc_profiles` saves monthly and annual maxima from 10 m bins over 20–250 m. The supplied method does not specify whether to weight platforms equally for DCM; this runner pools selected rows within bins. |
| 6 | AOU | `run_bgc_profiles` saves screened adjusted-oxygen AOU rows and observed-range 1 m annual depth profiles with equal-platform monthly and ≥3-month annual aggregation. |
| 7 | Physical aggregation | `run_physical_profiles` saves annual 1 m profiles using platform monthly medians, ≥6 represented months/platform/year/depth and equal-platform year means. |
| 8 | TEOS-10 | `run_physical_profiles` converts adjusted physical T/S to SA, CT and sigma0, interpolating only within profile support. Requires external GSW. |
| 9 | MLD, isopycnals | `run_physical_profiles` saves source-style profile-mean monthly MLD after adjusted T/S QC, coverage/spike screens, smoothing and first 1 m density crossing. Exact plotted isopycnal targets must be set by the author. |
| 10 | OHC, anomalies | `run_physical_profiles` saves annual CT-based volumetric OHC and each-depth available-year anomaly. |
| 11 | Temporal screening | `run_daily_screen` uses 61 observations, ≥15 local observations and robust 3σ; surface and SST annual means use median threshold factor 3 where specified. Other profile plausibility screens are implemented in the corresponding runners. |
| 12 | OLS trends | `run_sst_ersstv6` saves native-grid SST and ROI slopes; `npsg_grid_trend` implements 4 km chlorophyll grid screening, but its **gridded satellite inputs are not supplied**, so there is no chlorophyll trend map runner. |
| 13 | Breakpoint comparison | `run_breakpoints` derives MLD from physical Argo and saves annual input means and diagnostics for Cphyto, Chl:C and MLD (optional supplied growth rate), using 1000 null bootstraps. `Supported` follows Table S6's sup-F OR ΔBIC rule. Full breakpoint confidence-interval graphics are not recreated. |
| 14 | Dynamic heat layers | `run_physical_profiles` saves monthly and annual mean volumetric OHC with exact depth-cell overlap; supported thickness is reported and annual means need ≥6 months. |
| 15 | Display | `run_physical_profiles` saves 2 m × 0.25-year MAKIMA OHC display field without bridging missing samples. The full set of manuscript figures is not generated. |

HOT community observations are not included among the provided inputs. The full-data MATLAB run and figure-by-figure numerical comparison remain necessary.
