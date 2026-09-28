# NPSG manuscript code

MATLAB analysis code for **“From Surface Warming to Vertical Phytoplankton Reorganization in the North Pacific Subtropical Gyre.”** The study region is 14–28° N, 160–200° E.

The full methods are in Supplementary Table S1 of the manuscript. [COVERAGE.md](COVERAGE.md) maps its numbered methods to the code.

## Prepare the inputs

1. Put the five complete CSV files in `data/`. See [DATA.md](DATA.md) for the dataset link, filenames, and Argo preparation scripts.
2. Download NOAA ERSSTv6 monthly NetCDF files separately. Follow [DATA_SST.md](DATA_SST.md), then set `ersst_folder` in `examples/run_sst_ersstv6.m` to your download folder.
3. Install the [GSW MATLAB toolbox](https://www.teos-10.org/software.htm) separately.

The files in `examples/fixtures/` are small test examples, not the complete study data.

## Run in MATLAB

Set MATLAB’s **Current Folder** to the repository root. Replace `PATH_TO_GSW_TOOLBOX` with the location of the extracted GSW toolbox on your computer.

```matlab
addpath(fullfile(pwd,'src'),fullfile(pwd,'examples'))
setup_gsw('PATH_TO_GSW_TOOLBOX')

results = runtests(fullfile(pwd,'tests'));
assert(all([results.Passed]),'A unit test failed')

run_surface_carbon
run_surface_light
run_daily_screen
run_bgc_profiles
run_physical_profiles
run_sst_ersstv6
run_breakpoints
```

Run the commands individually so you can see which step is in progress. Physical Argo processing can take considerably longer than the other steps. `run_argo_filters` is available if you also want a QC summary.

## Results

Generated files are saved in `output/`.

| Runner | Main results |
| --- | --- |
| `run_surface_carbon` | Monthly phytoplankton carbon and chlorophyll:carbon |
| `run_surface_light` | Irradiance-based depth levels |
| `run_daily_screen` | Daily screening summary |
| `run_bgc_profiles` | DCM, profile carbon, and AOU |
| `run_physical_profiles` | Annual physical profiles, monthly MLD, isopycnals, and OHC |
| `run_sst_ersstv6` | Regional SST series and native-grid SST trends |
| `run_breakpoints` | Annual input series and breakpoint diagnostics |

`run_physical_profiles` calculates `output/Monthly_MLD.csv` from physical Argo. `run_breakpoints` can reuse this generated file, so you do not need to supply an MLD CSV. To force a new MLD calculation, delete `output/Monthly_MLD.csv` and `output/Monthly_MLD_cache.mat` before running `run_breakpoints`.

See [METHODS.md](METHODS.md) for a brief guide to the derived variables and [DATA.md](DATA.md) for the data sources and QC conventions.

## Put this code on GitHub

Create an empty GitHub repository. From this repository’s root folder, run:

```bash
git init
git add .
git commit -m "Add NPSG analysis code"
git branch -M main
git remote add origin https://github.com/YOUR-NAME/YOUR-REPOSITORY.git
git push -u origin main
```

The downloaded data, generated `output/` files, ERSSTv6 NetCDF files, and GSW toolbox should remain outside the GitHub repository.
