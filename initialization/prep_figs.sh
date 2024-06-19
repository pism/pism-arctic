#!/bin/bash

grid=5000
ncks -O -v velsurf_mag,usurf,mask,thk -d time,0 2019_10_shelf_tmp/ex_arctic_g${grid}m_v3a_id_E3_0_1000.nc /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_0.nc
ncap2 -O -s "where(thk<10) {thk=0; usurf=0;};" /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_0.nc /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_0.nc
gdal_translate  -a_nodata 0 NETCDF:/Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_0.nc:usurf  /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_0.tif
gdaldem hillshade -z 16 /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_0.tif  /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_0_hs.tif

ncks -O -v velsurf_mag,usurf,mask,thk -d time,9 2019_10_shelf_tmp/ex_arctic_g${grid}m_v3a_id_E3_0_1000.nc /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_1.nc
ncap2 -O -s "where(thk<10) {thk=0; usurf=0;};" /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_1.nc /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_1.nc
gdal_translate  -a_nodata 0 NETCDF:/Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_1.nc:usurf  /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_1.tif
gdaldem hillshade -z 16 /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_1.tif  /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_1_hs.tif
extract_interface.py -t calving_front -o /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/io_e3_1.shp /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_1.nc

ncks -O -v velsurf_mag,usurf,mask,thk -d time,19 2019_10_shelf_tmp/ex_arctic_g${grid}m_v3a_id_E3_0_1000.nc /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_2.nc
ncap2 -O -s "where(thk<10) {thk=0; usurf=0;};" /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_2.nc /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_2.nc
gdal_translate  -a_nodata 0 NETCDF:/Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_2.nc:usurf  /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_2.tif
gdaldem hillshade -z 16 /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_2.tif  /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_2_hs.tif
extract_interface.py -t calving_front -o /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/io_e3_2.shp /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_2.nc

ncks -O -v velsurf_mag,usurf,mask,thk -d time,70 2019_10_shelf_tmp/ex_arctic_g${grid}m_v3a_id_E3_0_1000.nc /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_3.nc
ncap2 -O -s "where(thk<10) {usurf=0;};" /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_3.nc /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_3.nc
gdal_translate  -a_nodata 0 NETCDF:/Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_3.nc:usurf  /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_3.tif
gdaldem hillshade -z 16 /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_3.tif  /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_3_hs.tif
extract_interface.py -t calving_front -o /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/io_e3_3.shp /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_3.nc

ncks -O -v velsurf_mag,usurf,mask,thk -d time,9 2019_10_shelf_tmp/ex_arctic_g${grid}m_v3a_id_E3-MBP_0_1000.nc /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_1.nc
ncap2 -O -s "where(thk<10) {thk=0; usurf=0;};" /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_1.nc /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_1.nc
gdal_translate  -a_nodata 0 NETCDF:/Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_1.nc:usurf  /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_1.tif
gdaldem hillshade -z 16 /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_1.tif  /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_1_hs.tif
extract_interface.py -t calving_front -o /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/io_e3_mbp_1.shp /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_1.nc

ncks -O -v velsurf_mag,usurf,mask,thk -d time,19 2019_10_shelf_tmp/ex_arctic_g${grid}m_v3a_id_E3-MBP_0_1000.nc /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_2.nc
ncap2 -O -s "where(thk<10) {thk=0; usurf=0;};" /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_2.nc /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_2.nc
gdal_translate  -a_nodata 0 NETCDF:/Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_2.nc:usurf  /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_2.tif
gdaldem hillshade -z 16 /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_2.tif  /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_2_hs.tif
extract_interface.py -t calving_front -o /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/io_e3_mbp_2.shp /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_2.nc

ncks -O -v velsurf_mag,usurf,mask,thk -d time,70 2019_10_shelf_tmp/ex_arctic_g${grid}m_v3a_id_E3-MBP_0_1000.nc /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_3.nc
ncap2 -O -s "where(thk<10) {thk=0; usurf=0;};"  /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_3.nc  /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_3.nc
gdal_translate  -a_nodata 0 NETCDF:/Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_3.nc:usurf  /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_3.tif
gdaldem hillshade -z 16 /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_3.tif  /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_3_hs.tif
extract_interface.py -t calving_front -o /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/io_e3_mbp_3.shp /Volumes/GoogleDrive/My\ Drive/Proposals/NSF\ P2C2\ Arctic\ Ocean\ Glaciation/qgis/e3_mbp_3.nc

