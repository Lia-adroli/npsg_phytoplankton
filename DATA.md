# Data

Download the analysis data from [Zenodo: 10.5281/zenodo.23004516](https://doi.org/10.5281/zenodo.23004516). Put these files in the repository’s `data/` folder:

| File | Used for |
| --- | --- |
| `daily_mean.csv` | Daily satellite chlorophyll and optical series |
| `monthly_Kd490_Zeu_ZSD.csv` | Monthly light, euphotic depth, and backscattering |
| `CbPM_surface_only.csv` | Monthly surface carbon and chlorophyll:carbon breakpoint series |
| `Final_BGC_Argo_All_Depth_Rows_With_Adjusted.csv` | BGC-Argo chlorophyll, backscattering, DCM, and AOU |
| `ArgoFloats_filtered_qc12_pres1000.csv` | Physical Argo density, MLD, and OHC |

The two Argo CSV files can be generated using the Argopy Python library in expert mode ([Maze & Balem, 2020](https://doi.org/10.21105/joss.02425)).

BGC-Argo analyses use adjusted values and select rows with `CHLA_ADJUSTED_QC == 1`. Physical Argo analyses require both `PSAL_ADJUSTED_QC == 1` and `TEMP_ADJUSTED_QC == 1`. AOU uses `DOXY_ADJUSTED`. Monthly MLD is calculated from physical Argo. 

Download NOAA **ERSSTv6** NetCDF files separately; see [DATA_SST.md](DATA_SST.md). See [README.md](README.md) for MATLAB setup and commands.
