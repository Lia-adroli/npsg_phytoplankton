# Code coverage for Supplementary Table S1

This page maps the numbered procedures in **Supplementary Table S1** of *“From Surface Warming to Vertical Phytoplankton Reorganization in the North Pacific Subtropical Gyre”* to the MATLAB code in this repository. Refer to the Supplementary Information for the full methods.

| Table S1 no. | MATLAB entry point | Main generated result |
| --- | --- | --- |
| 1 | `run_sst_ersstv6` | Regional monthly and annual SST |
| 2 | `run_surface_carbon`; `run_bgc_profiles` | Surface and depth-resolved phytoplankton carbon; chlorophyll:carbon ratios |
| 3 | `run_surface_light` | Irradiance-based depth levels |
| 4 | `run_bgc_profiles` | Selected BGC-Argo profiles used in the subsequent calculations |
| 5 | `run_bgc_profiles` | Monthly and annual DCM depths |
| 6 | `run_bgc_profiles` | AOU observations and annual AOU depth profiles |
| 7 | `run_physical_profiles` | Annual physical Argo depth profiles |
| 8 | `run_physical_profiles` | Absolute Salinity, Conservative Temperature, and potential density |
| 9 | `run_physical_profiles` | Argo-derived monthly MLD and selected isopycnal depths |
| 10 | `run_physical_profiles` | Annual OHC depth profiles and anomalies |
| 11 | `run_daily_screen`; relevant surface and SST runners | Screened daily observations and monthly series used for annual calculations |
| 12 | `run_sst_ersstv6`; `npsg_grid_trend` | SST grid trends; function for chlorophyll grid trends |
| 13 | `run_breakpoints` | Annual input series and breakpoint diagnostics |
| 14 | `run_physical_profiles` | Monthly and annual OHC within dynamic layers |
| 15 | `run_physical_profiles` | OHC field prepared separately for visualization |

The supplied satellite CSVs contain regional averages. Calculating a spatial chlorophyll trend map with `npsg_grid_trend` requires the original gridded satellite data. HOT analyses likewise require the HOT observations.

For data sources, archives, and input-file placement, see [DATA.md](DATA.md). For MATLAB setup, commands, and output filenames, see [README.md](README.md).
