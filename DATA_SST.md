# ERSSTv6 input files (download separately)

The manuscript specifies **NOAA ERSSTv6**, January 1998–December 2024. Files named `ersst.v5.YYYYMM.nc` are ERSSTv5 and should not be renamed or used for the v6 analysis. NOAA hosts the monthly v6 NetCDF files in its [official ERSSTv6 directory](https://www.ncei.noaa.gov/pub/data/cmb/ersst/v5/v6/). The `v5/v6` part of the NOAA server path is its actual directory layout; verify each file starts with `ersst.v6.`. See also the [NOAA ERSST product page](https://www.ncei.noaa.gov/products/extended-reconstructed-sst).

On Windows, put the **324 monthly NetCDF files** outside this repository, for example:

```text
G:\New folder\ersst_v6_data\ersst.v6.199801.nc
G:\New folder\ersst_v6_data\ersst.v6.199802.nc
...
G:\New folder\ersst_v6_data\ersst.v6.202412.nc
```

You can download them from NOAA's directory individually. For the whole 1998–2024 period, open **PowerShell** and run:

```powershell
$destination = 'G:\New folder\ersst_v6_data'
$base = 'https://www.ncei.noaa.gov/pub/data/cmb/ersst/v5/v6'
New-Item -ItemType Directory -Force $destination | Out-Null
1998..2024 | ForEach-Object {
    $year = $_
    1..12 | ForEach-Object {
        $name = 'ersst.v6.{0}{1:00}.nc' -f $year, $_
        $file = Join-Path $destination $name
        if (-not (Test-Path $file)) {
            Invoke-WebRequest -Uri "$base/$name" -OutFile $file
        }
    }
}
(Get-ChildItem $destination -Filter 'ersst.v6.*.nc').Count
```

The final count should be **324**. Check one file in MATLAB:

```matlab
ersst_folder = 'G:\New folder\ersst_v6_data';
assert(numel(dir(fullfile(ersst_folder,'ersst.v6.*.nc'))) == 324)
ncinfo(fullfile(ersst_folder,'ersst.v6.199801.nc'))
```

Set `ersst_folder = 'G:\New folder\ersst_v6_data'` in `examples/run_sst_ersstv6.m` (or edit the path for your computer), then run that example. It reads all 324 monthly files, calculates cosine-weighted ROI monthly/annual means, and saves an OLS native-grid SST slope CSV. The author's map limits (0–40° N, 130–230° E), 0.5° display resolution and 15° padding are figure-only settings; the runner does not recreate the SST map image. The source NetCDF files are **not** included in this package.

The GSW toolbox is a separate dependency. Download the MATLAB toolbox from [TEOS-10](https://teos-10.org/software.htm), extract it, and point `setup_gsw` to its actual folder (for example `G:\New folder\gsw_matlab_v3_06_16`). Do not upload the downloaded toolbox or NetCDF data to this GitHub repository.
