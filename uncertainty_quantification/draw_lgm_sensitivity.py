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

gcms = ["CCSM4", "CNRM-CM5", "GISS-E2-R", "IPSL-CM5A-LR", "MIROC-ESM", "MPI-ESM-P", "MRI-CGCM3"]

dfs = []
for gcm in gcms:
    dist = OrderedDict()
    dist["ppq"] = [0.5, 0.6]
    dist["siae"] = [1.5]
    dist["temperature_lapse_rate"] = [6]
    dist["refreeze_factor"] = [0.5]
    dist["pdd_factor_ice"] = [9.5, 10.5, 11.5]
    dist["pdd_factor_snow"] = [3, 4, 5]
    dist["pdd_std_dev"] = [5]
    dist["climate"] = ["paleo"]
    dist["climate_file"] = ["akglaciers_climate_cru_TS40_historical_1980_2005_YMM.nc"]
    dist["climate_modifier_file"] = ["climate_modifier_0C_-110m.nc"]
    dist["anomaly_file"] = ["akglaciers_{gcm}_lgm_historical.nc".format(gcm=gcm)]

    p = list(product(*dist.values()))

    # Save to CSV file using Pandas DataFrame and to_csv method
    header = dist.keys()
    # Convert to Pandas dataframe, append column headers, output as csv
    df_index = ["{gcm}-{id}".format(gcm=gcm, id=id) for id in range(len(p))]
    df = pd.DataFrame(data=np.array(p), columns=header, index=df_index)
    dfs.append(df)

df = pd.concat(dfs)
df.to_csv(outfile, index=True, index_label="id")
