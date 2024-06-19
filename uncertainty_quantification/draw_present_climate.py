#!/usr/bin/env python

from argparse import ArgumentParser
import numpy as np
import pandas as pd
from collections import OrderedDict
from itertools import product

parser = ArgumentParser()
parser.description = "Draw samples using the Saltelli methods"
parser.add_argument("OUTFILE", nargs=1, help="Ouput file (CSV)", default="saltelli_samples.csv")
options = parser.parse_args()
outfile = options.OUTFILE[-1]


dist = OrderedDict()
dist["ppq"] = [0.6]
dist["siae"] = [1.5]
dist["temperature_lapse_rate"] = [5, 7]
dist["refreeze_factor"] = [0.4, 0.6]
dist["pdd_factor_ice"] = [6, 8, 10]
dist["pdd_factor_snow"] = [2, 3, 4]
dist["pdd_std_dev"] = [4, 6]
dist["climate"] = ["present"]
dist["climate_file"] = ["akglaciers_climate_cru_TS40_historical_1980_2005_YMM.nc"]
dist["climate_modifier_file"] = ["climate_modifier_0C.nc"]
dist["anomaly_file"] = [""]

p = list(product(*dist.values()))

# Save to CSV file using Pandas DataFrame and to_csv method
header = dist.keys()
# Convert to Pandas dataframe, append column headers, output as csv
df = pd.DataFrame(data=np.array(p), columns=header)
df.to_csv(outfile, index=True, index_label="id")
