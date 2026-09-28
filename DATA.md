# Data and QC contract

| Local file in `data/` | Required fields / use |
| --- | --- |
| `daily_mean.csv` | `date1` (day/month/year), `chl` for monthly matched Chl:C; `zeu` and `kd490` retained for other analyses |
| `monthly_Kd490_Zeu_ZSD.csv` | `Date` (day/month/year), `Kd490`, `Zeu_from_Kd490`, `ZSD`, `PAR_surf`, `bbp443`; 25 supplied sample rows in `examples/fixtures/` |
| `CbPM_surface_only.csv` | `Year`, `Month`, `chl_monthly`, `bbp443`; optional existing `growth_rate` for its breakpoint; sample in `examples/fixtures/` |
| `Final_BGC_Argo_All_Depth_Rows_With_Adjusted.csv` | `PROFILE_ID`, `PLATFORM_NUMBER`, `YEAR`, `MONTH`, `LATITUDE`, `LONGITUDE`, `PRES_ADJUSTED`, `PSAL_ADJUSTED`, `TEMP_ADJUSTED`, `CHLA_ADJUSTED`, `CHLA_ADJUSTED_QC`, `BBP700_ADJUSTED`, `DOXY_ADJUSTED` |
| `ArgoFloats_filtered_qc12_pres1000.csv` | `PLATFORM_NUMBER`, `CYCLE_NUMBER`, `TIME`, `LATITUDE`, `LONGITUDE`, adjusted `PRES`, `PSAL`, `TEMP`, `PSAL_ADJUSTED_QC`, `TEMP_ADJUSTED_QC` |

`npsg_argo_qc_report` counts finite adjusted values and finite values passing the shared gate separately. In the BGC schema, `CHLA_ADJUSTED_QC == 1` is applied to all three variables' rows. This is a **selection proxy**, not an assertion that `BBP700_ADJUSTED` or `DOXY_ADJUSTED` has its own QC-1 flag. Raw `CHLA_QC=3` does not override adjusted `CHLA_ADJUSTED_QC=1`.

The physical filename contains `qc12`; the filter requires both adjusted T/S flags equal to 1 and applies that row gate to physical variables. Pressure is finite and range screened, with no pressure QC claim. BGC AOU uses only `DOXY_ADJUSTED` after the shared CHLA gate, correction and range/platform screens in the attached oxygen script. The shown BGC sample has missing adjusted oxygen, so that sample alone cannot produce AOU. Confirm the adjusted oxygen scale/units in the complete file before interpreting AOU.

Physical Argo is restricted to 2003–2024 and January–November; breakpoint series from the CbPM file are also restricted to January–November. MLD is calculated from physical Argo and monthly optical Zeu; the generated `output/Monthly_MLD.csv` is a reproducible cache, never an external input.

The optical file has **Zeu_from_Kd490 about 104–111 m**, distinct from the 1% Beer–Lambert depth calculated from KPAR=Kd490. Keep it distinct from CbPM's `Zeu` column. CbPM's monthly `chl_monthly` is used directly to calculate the breakpoint Chl:C series.

Original products: [ESA OC-CCI](https://www.oceancolour.org), [Copernicus Marine](https://data.marine.copernicus.eu), [NOAA ERSSTv6](https://www.ncei.noaa.gov/products/extended-reconstructed-sst), [Argo](https://argo.ucsd.edu), and [BGC-Argo](https://biogeochemical-argo.org). Source SST grids and HOT observations are not in these supplied CSVs. See [DATA_SST.md](DATA_SST.md) for v6 NetCDF download instructions; the v5 files listed by the author are a different product version.
