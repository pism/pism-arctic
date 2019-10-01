#!/env/bin python

from glob import glob
import numpy as np
from os.path import abspath, basename, join
import re
from dateutil import rrule
from dateutil.parser import parse

from netCDF4 import Dataset as NC
from cftime import utime, datetime


def adjust_timeline(
    filename,
    start_date="2015-1-1",
    interval=1,
    interval_type="mid",
    bounds=True,
    periodicity="yearly",
    ref_date="2008-1-1",
    ref_unit="days",
    calendar="standard",
):
    nc = NC(filename, "a")
    nt = len(nc.variables["time"])

    time_units = "%s since %s" % (ref_unit, ref_date)
    time_calendar = calendar

    cdftime = utime(time_units, time_calendar)

    # create a dictionary so that we can supply the periodicity as a
    # command-line argument.
    pdict = {}
    pdict["SECONDLY"] = rrule.SECONDLY
    pdict["MINUTELY"] = rrule.MINUTELY
    pdict["HOURLY"] = rrule.HOURLY
    pdict["DAILY"] = rrule.DAILY
    pdict["WEEKLY"] = rrule.WEEKLY
    pdict["MONTHLY"] = rrule.MONTHLY
    pdict["YEARLY"] = rrule.YEARLY
    prule = pdict[periodicity.upper()]

    # reference date from command-line argument
    r = time_units.split(" ")[2].split("-")
    refdate = datetime(int(r[0]), int(r[1]), int(r[2]))

    # create list with dates from start_date for nt counts
    # periodicity prule.
    bnds_datelist = list(rrule.rrule(freq=prule, dtstart=parse(start_date), count=nt + 1, interval=interval))

    # calculate the days since refdate, including refdate, with time being the
    bnds_interval_since_refdate = cdftime.date2num(bnds_datelist)
    if interval_type == "mid":
        # mid-point value:
        # time[n] = (bnds[n] + bnds[n+1]) / 2
        time_interval_since_refdate = bnds_interval_since_refdate[0:-1] + np.diff(bnds_interval_since_refdate) / 2
    elif interval_type == "start":
        time_interval_since_refdate = bnds_interval_since_refdate[:-1]
    else:
        time_interval_since_refdate = bnds_interval_since_refdate[1:]

    # create a new dimension for bounds only if it does not yet exist
    time_dim = "time"
    if time_dim not in list(nc.dimensions.keys()):
        nc.createDimension(time_dim)

    # variable names consistent with PISM
    time_var_name = "time"
    bnds_var_name = "time_bnds"

    # create time variable
    if time_var_name not in nc.variables:
        time_var = nc.createVariable(time_var_name, "d", dimensions=(time_dim))
    else:
        time_var = nc.variables[time_var_name]
    time_var[:] = time_interval_since_refdate
    time_var.units = time_units
    time_var.calendar = time_calendar
    time_var.standard_name = time_var_name
    time_var.axis = "T"

    if bounds:
        # create a new dimension for bounds only if it does not yet exist
        bnds_dim = "nb2"
        if bnds_dim not in list(nc.dimensions.keys()):
            nc.createDimension(bnds_dim, 2)

        # create time bounds variable
        if bnds_var_name not in nc.variables:
            time_bnds_var = nc.createVariable(bnds_var_name, "d", dimensions=(time_dim, bnds_dim))
        else:
            time_bnds_var = nc.variables[bnds_var_name]
        time_bnds_var[:, 0] = bnds_interval_since_refdate[0:-1]
        time_bnds_var[:, 1] = bnds_interval_since_refdate[1::]
        time_var.bounds = bnds_var_name
    else:
        delattr(time_var, "bounds")

    nc.close()


ifiles = glob("MERRA2_*.tavgM_2d_slv_Nx.*.nc4")

for ifile in ifiles:
    mon = ifile[-6:-4]
    year = ifile[-10:-6]
    print(mon, year)
    adjust_timeline(
        ifile, start_date="{}-{}-1".format(year, mon), periodicity="monthly", ref_date="1980-1-1", ref_unit="days"
    )
