#!/usr/bin/env python

from argparse import ArgumentParser
import numpy as np
import pandas as pd
from collections import OrderedDict
from itertools import product

parser = ArgumentParser()
parser.description = "Draw samples using the Saltelli methods"
parser.add_argument("OUTFILE", nargs=1, help="Ouput file (CSV)", default="alaska_lgm_gcms.csv")

options = parser.parse_args()
outfile = options.OUTFILE[-1]

gcms = ["CESM2-WACCM-FV2", "CNRM-CM5", "GISS-E2-R", "INM-CM4", "IPSL-CM5A-LR",
        "MIROC-E2SL", "MIROC-ESM", "MPI-ESM1-2-LR", "MPI-ESM-P", "MRI-CGCM3"]

dfs = []
for gcm in gcms:
    dist = OrderedDict()
    dist["ppq"] = [0.6]
    dist["sia_e"] = [1.5]
    dist["temperature_lapse_rate"] = [0]
    dist["refreeze_factor"] = [0.5]
    dist["pdd_factor_ice"] = [10.5]
    dist["pdd_factor_snow"] = [4]
    dist["pdd_std_dev"] = [5]
    dist["climate"] = ["paleo"]
    dist["climate_file"] = ["akglaciers_climate_cru_TS40_historical_1980_2005_YMM.nc"]
    dist["climate_modifier_file"] = ["climate_modifier_0C_dSL_-130m.nc"]
    dist["anomaly_file"] = [f"akglaciers_{gcm}_lgm_historical.nc"]
    dist["sealevel_modifier_file"] = ["climate_modifier_0C_dSL_-130m.nc"]

    p = list(product(*dist.values()))

    # Save to CSV file using Pandas DataFrame and to_csv method
    header = dist.keys()
    # Convert to Pandas dataframe, append column headers, output as csv
    df_index = ["{gcm}".format(gcm=gcm, id=id) for id in range(len(p))]
    df = pd.DataFrame(data=np.array(p), columns=header, index=df_index)
    dfs.append(df)

df = pd.concat(dfs)
df.to_csv(outfile, index=True, index_label="id")
