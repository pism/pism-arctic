#!/usr/bin/env python
# Copyright (C) 2017 Andy Aschwanden

import numpy as np
import time
from netCDF4 import Dataset as NC
from argparse import ArgumentParser


# Set up the option parser
parser = ArgumentParser()
parser.description = "Create climate forcing for a warming climate"
parser.add_argument("FILE", nargs="*")
parser.add_argument("-T_max", dest="T_max", type=float, help="Maximum temperature", default=-10)
parser.add_argument("-t_max", dest="t_max", type=float, help="lower time bound for maximum temperature", default=100)
parser.add_argument("-b", dest="backpressure_max", type=float, help="Maximum backpressure fraction", default=0.3)
parser.add_argument("-n", dest="n", type=float, help="power-law exponent", default=1)
parser.add_argument("-s", dest="s", type=float, help="sea level offset", default=0)


options = parser.parse_args()
args = options.FILE
backpressure_max = options.backpressure_max
n = options.n
dSL = options.s
start = 0
end = 500000
step = 10
t_max = options.t_max
T_max = options.T_max
bnds_interval_since_refdate = np.array(list(range(start, end + step, step)))
time_interval_since_refdate = bnds_interval_since_refdate[0:-1] + np.diff(bnds_interval_since_refdate) / 2

infile = args[0]

nc = NC(infile, "w")


def def_var(nc, name, units):
    var = nc.createVariable(name, "f", dimensions=("time"))
    var.units = units
    return var


# create a new dimension for bounds only if it does not yet exist
time_dim = "time"
if time_dim not in list(nc.dimensions.keys()):
    nc.createDimension(time_dim)

# create a new dimension for bounds only if it does not yet exist
bnds_dim = "nb2"
if bnds_dim not in list(nc.dimensions.keys()):
    nc.createDimension(bnds_dim, 2)

# variable names consistent with PISM
time_var_name = "time"
bnds_var_name = "time_bnds"

# create time variable
time_var = nc.createVariable(time_var_name, "d", dimensions=(time_dim))
time_var[:] = time_interval_since_refdate
time_var.bounds = bnds_var_name
time_var.units = "years since 1-1-1"
time_var.calendar = "365_day"
time_var.standard_name = time_var_name
time_var.axis = "T"

# create time bounds variable
time_bnds_var = nc.createVariable(bnds_var_name, "d", dimensions=(time_dim, bnds_dim))
time_bnds_var[:, 0] = bnds_interval_since_refdate[0:-1]
time_bnds_var[:, 1] = bnds_interval_since_refdate[1::]

var = "delta_T"
dT_var = def_var(nc, var, "K")
T_0 = 0.0

temp = np.zeros_like(time_interval_since_refdate) + T_max
# temp[0 : int((t_max / step))] = np.linspace(T_0, T_max, t_max / step)
dT_var[:] = temp

var = "delta_SL"
dSL_var = def_var(nc, var, "m")
SL_0 = dSL

SL = np.zeros_like(time_interval_since_refdate) + SL_0
dSL_var[:] = SL

psi = np.zeros_like(temp) + 0.75


var = "frac_MBP"
if var not in list(nc.variables.keys()):
    frac_var = def_var(nc, var, "1")
else:
    frac_var = nc.variables[var]

frac_var[:] = psi

# writing global attributes
script_command = " ".join([time.ctime(), ":", __file__.split("/")[-1], " ".join([str(x) for x in args])])
nc.history = script_command
nc.Conventions = "CF 1.6"
nc.close()
