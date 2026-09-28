# NOAA ERSSTv6 files

The SST analysis uses **NOAA ERSSTv6 monthly NetCDF files** from January 1998 through December 2024: 324 files in total. Download them from the [NOAA ERSSTv6 directory](https://www.ncei.noaa.gov/pub/data/cmb/ersst/v5/v6/). File names must begin with `ersst.v6.`, for example `ersst.v6.199801.nc`. 

## Download on Windows

This PowerShell example saves the files in `ersst_v6_data` under your Windows user folder. You may change `$destination` to any location on your computer.

```powershell
$destination = Join-Path $env:USERPROFILE 'ersst_v6_data'
$base = 'https://www.ncei.noaa.gov/pub/data/cmb/ersst/v5/v6'
New-Item -ItemType Directory -Force -Path $destination | Out-Null

1998..2024 | ForEach-Object {
    $year = $_
    1..12 | ForEach-Object {
        $name = 'ersst.v6.{0}{1:00}.nc' -f $year, $_
        $file = Join-Path $destination $name
        if (-not (Test-Path $file)) {
            Invoke-WebRequest -Uri "$base/$name" -OutFile $file -ErrorAction Stop
        }
    }
}

(Get-ChildItem $destination -Filter 'ersst.v6.*.nc').Count
```

The count should be **324**.

## Use the files in MATLAB

Edit the first line of `examples/run_sst_ersstv6.m` to point to the folder you chose. For the PowerShell example above, use:

```matlab
ersst_folder = fullfile(getenv('USERPROFILE'),'ersst_v6_data');
```

Then, from the repository root, run:

```matlab
assert(numel(dir(fullfile(ersst_folder,'ersst.v6.*.nc'))) == 324)
ncinfo(fullfile(ersst_folder,'ersst.v6.199801.nc'))

addpath(fullfile(pwd,'src'),fullfile(pwd,'examples'))
run_sst_ersstv6
```

The runner reads the monthly files and saves regional SST series and native-grid SST trends in `output/`. Keep the downloaded NetCDF files outside the GitHub repository.
