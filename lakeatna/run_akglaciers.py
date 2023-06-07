#!/usr/bin/env python
# Copyright (C) 2016-22 Andy Aschwanden

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
import itertools
from collections import OrderedDict
import numpy as np
import os
import shlex
from os.path import join, abspath, realpath, dirname

import pandas as pd

try:
    import subprocess32 as sub
except:
    import subprocess as sub
import sys

# from pism_utilities import batch_script


def current_script_directory():
    import inspect

    filename = inspect.stack(0)[0][1]
    return realpath(dirname(filename))


script_directory = current_script_directory()

sys.path.append(join(script_directory, "../resources"))
from resources import *


def map_dict(val, mdict):
    try:
        return mdict[val]
    except:
        return val


grid_choices = (250, 500, 1000, 2000, 5000, 10000, 20000, 40000)
# set up the option parser
parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.description = "Generating scripts for model initialization."
parser.add_argument(
    "-i",
    "--initial_state_file",
    dest="initialstatefile",
    help="Input file to restart from, default=None, set to combination to read in from combination .csv", #modified by maria
    default=None,
)
parser.add_argument(
    "-n",
    "--n_procs",
    dest="n",
    type=int,
    help="""number of cores/processors. default=140.""",
    default=140,
)
parser.add_argument(
    "-w",
    "--wall_time",
    dest="walltime",
    help="""walltime. default: 100:00:00.""",
    default="100:00:00",
)
parser.add_argument(
    "-q",
    "--queue",
    dest="queue",
    choices=list_queues(),
    help="""queue. default=long.""",
    default="long",
)
parser.add_argument(
    "--calving",
    dest="calving",
    choices=["float_kill", "vonmises_calving", "eigen_calving"],
    help="calving",
    default="vonmises_calving",
)
parser.add_argument(
    "-d",
    "--domain",
    dest="domain",
    choices=["akglaciers", "arctic", "atna", "malaspina"],
    help="sets the modeling domain",
    default="malaspina",
)
parser.add_argument(
    "--exstep",
    dest="exstep",
    help="Writing interval for spatial time series",
    default=1,
)
parser.add_argument(
    "-f",
    "--o_format",
    dest="oformat",
    choices=["netcdf3", "netcdf4_parallel", "netcdf4_serial", "pnetcdf"],
    help="output format",
    default="netcdf4_serial",
)
parser.add_argument(
    "-g",
    "--grid",
    dest="grid",
    type=int,
    choices=grid_choices,
    help="horizontal grid resolution",
    default=10000,
)
parser.add_argument(
    "--i_dir",
    dest="input_dir",
    help="input directory, default the script_directory/..",
    default=abspath(join(script_directory, "..")),
)
parser.add_argument(
    "--o_dir", dest="output_dir", help="output directory", default="test_dir"
)
parser.add_argument(
    "--o_size",
    dest="osize",
    choices=["small", "medium", "big", "big_2d", "custom"],
    help="output size type",
    default="custom",
)
parser.add_argument(
    "-s",
    "--system",
    dest="system",
    choices=list_systems(),
    help="computer system to use.",
    default="pleiades_broadwell",
)
parser.add_argument(
    "--spatial_ts",
    dest="spatial_ts",
    choices=["basic", "medium", "pdd", "climate_testing"],
    help="output size type",
    default="basic",
)
parser.add_argument(
    "--hydrology",
    dest="hydrology",
    choices=["null", "diffuse", "routing"],
    help="Basal hydrology model.",
    default="diffuse",
)
parser.add_argument(
    "--stable_gl",
    dest="float_kill_calve_near_grounding_line",
    action="store_false",
    help="Stable grounding line",
    default=True,
)
parser.add_argument(
    "--stress_balance",
    dest="stress_balance",
    choices=["sia", "ssa+sia", "ssa", "blatter"],
    help="stress balance solver",
    default="ssa+sia",
)
parser.add_argument(
    "--vertical_velocity_approximation",
    dest="vertical_velocity_approximation",
    choices=["centered", "upstream"],
    help="How to approximate vertical velocities",
    default="upstream",
)
parser.add_argument(
    "--start_year", dest="start_year", type=int, help="Simulation start year", default=0
)
parser.add_argument( #added by Maria
    "--end_year", dest="end_year", type=int, help="Simulation end year", default=1000
)
parser.add_argument(
    "--duration", dest="duration", type=int, help="Years to simulate", default=1000 # 
)
parser.add_argument(
    "--step", dest="step", type=int, help="Step in years for restarting", default=1000
)
parser.add_argument(
    "--test_climate_models",
    dest="test_climate_models",
    action="store_true",
    help="Turn off ice dynamics and mass transport to test climate models",
    default=False,
)
parser.add_argument(
    "-e",
    "--ensemble_file",
    dest="ensemble_file",
    help="File that has all combinations for ensemble study",
    default="initialization.csv",
)
parser.add_argument(
    "-L",
    "--comp_level",
    dest="compression_level",
    help="Compression level for output file. Only works with netcdf4_serial.",
    default=2,
)
parser.add_argument(
    "--dataset_version",
    dest="version",
    choices=["2023_mi", "2023_mibr"],
    help="input data set version",
    default="2023_mibr",
)

options = parser.parse_args()
print(options.stress_balance)

nn = options.n
input_dir = abspath(options.input_dir)
output_dir = abspath(options.output_dir)
spatial_tmp_dir = abspath(options.output_dir + "_tmp")

oformat = options.oformat
compression_level = options.compression_level
osize = options.osize
queue = options.queue
walltime = options.walltime
system = options.system

spatial_ts = options.spatial_ts

calving = options.calving
exstep = options.exstep
float_kill_calve_near_grounding_line = options.float_kill_calve_near_grounding_line
initialstatefile = options.initialstatefile
grid = options.grid
hydrology = options.hydrology
stress_balance = options.stress_balance
test_climate_models = options.test_climate_models
vertical_velocity_approximation = options.vertical_velocity_approximation
version = options.version
ensemble_file = "../uncertainty_quantification/{}".format(options.ensemble_file)
domain = options.domain
pism_exec = generate_domain(domain)

pism_dataname = "$input_dir/data_sets/bed_dem/pism_akglaciers_v{}_g{}m.nc".format(
    version, grid
)

regridvars = "enthalpy,tillwat,ice_area_specific_volume,thk"
# regridvars = "litho_temp,enthalpy,age,bmelt,ice_area_specific_volume,thk"

dirs = {"output": "$output_dir", "spatial_tmp": "$spatial_tmp_dir"}
for d in ["performance", "state", "scalar", "spatial", "jobs", "basins"]:
    dirs[d] = "$output_dir/{dir}".format(dir=d)

if spatial_ts == "none":
    del dirs["spatial"]

# use the actual path of the run scripts directory (we need it now and
# not during the simulation)
scripts_dir = join(output_dir, "run_scripts")
if not os.path.isdir(scripts_dir):
    os.makedirs(scripts_dir)

# generate the config file *after* creating the output directory
pism_config = "pism"
pism_config_nc = join(output_dir, pism_config + ".nc")

cmd = "ncgen -o {output} {input_dir}/config/{config}.cdl".format(
    output=pism_config_nc, input_dir=input_dir, config=pism_config
)
sub.call(shlex.split(cmd))

# these Bash commands are added to the beginning of the run scrips
run_header = """# stop if a variable is not defined
set -u
# stop on errors
set -e

# path to the config file
config="{config}"
# path to the input directory (input data sets are contained in this directory)
input_dir="{input_dir}"
# output directory
output_dir="{output_dir}"
# temporary directory for spatial files
spatial_tmp_dir="{spatial_tmp_dir}"

# create required output directories
for each in {dirs};
do
  mkdir -p $each
done

""".format(
    input_dir=input_dir,
    output_dir=output_dir,
    spatial_tmp_dir=spatial_tmp_dir,
    config=pism_config_nc,
    dirs=" ".join(list(dirs.values())),
)

# ########################################################
# set up model initialization
# ########################################################

ssa_n = 3.25
ssa_e = 3.0
tefo = 0.020
phi_min = 5.0
phi_max = 40.0
topg_min = -700
topg_max = 700

lapse_rate = 6
ice_density = 910.0

uq_df = pd.read_csv(ensemble_file)
uq_df.fillna(False, inplace=True)

m_bd = 0.0
bd_dict = {-1.0: "off", 0.0: "i0", 1.0: "ip"}


tsstep = "yearly"

scripts = []
scripts_combinded = []
scripts_post = []

simulation_start_year = options.start_year

#if options.duration == None: #added by maria
#    simulation_end_year = options.end_year
#else: 
#    simulation_end_year = options.start_year + options.duration
simulation_end_year = options.start_year + options.duration
   
restart_step = options.step

if restart_step > (simulation_end_year - simulation_start_year):
    print("Error:")
    print(
        (
            "restart_step > (simulation_end_year - simulation_start_year): {} > {}".format(
                restart_step, simulation_end_year - simulation_start_year
            )
        )
    )
    print("Try again")
    import sys

    sys.exit(0)

batch_header, batch_system = make_batch_header(system, nn, walltime, queue)
post_header = make_batch_post_header(system)

m_sb = None
mbp = 0

for n, row in enumerate(uq_df.iterrows()):
    combination = row[1]
    print(combination)

    bed_deformation = bd_dict[m_bd]

    ttphi = "{},{},{},{}".format(phi_min, phi_max, topg_min, topg_max)

    name_options = {}
    try:
        name_options["id"] = int(combination["id"])
    except:
        name_options["id"] = combination["id"]

    full_exp_name = "_".join(
        ["_".join([k, str(v)]) for k, v in list(name_options.items())]
    )
    full_outfile = "{domain}_g{grid}m_v{version}_{experiment}.nc".format(
        domain=domain.lower, version=version, grid=grid, experiment=full_exp_name
    )

    # All runs in one script file for coarse grids that fit into max walltime
    script_combined = join(scripts_dir, "run_g{}m_{}_j.sh".format(grid, full_exp_name))
    with open(script_combined, "w") as f_combined:

        outfiles = []
        job_no = 0
        for start in range(simulation_start_year, simulation_end_year, restart_step):
            job_no += 1

            end = start + restart_step

            experiment = "_".join(
                [
                    "_".join(
                        ["_".join([k, str(v)]) for k, v in list(name_options.items())]
                    ),
                    "{}".format(start),
                    "{}".format(end),
                ]
            )

            script = join(scripts_dir, "run_g{}m_{}.sh".format(grid, experiment))
            scripts.append(script)

            for filename in script:
                try:
                    os.remove(filename)
                except OSError:
                    pass

            if start == simulation_start_year:
                f_combined.write(batch_header)
                f_combined.write(run_header)

            with open(script, "w") as f:

                f.write(batch_header)
                f.write(run_header)

                outfile = "{domain}_g{grid}m_{experiment}.nc".format(
                    domain=domain.lower(), grid=grid, experiment=experiment
                )

                pism = generate_prefix_str(pism_exec)

                general_params_dict = {
                    "ys": start,
                    "ye": end,
                    "calendar": "365_day",
                    "input.forcing.buffer_size": 13,
                    "o": join(dirs["state"], outfile),
                    "o_format": oformat,
                    "output.compression_level": compression_level,
                    "config_override": "$config",
                    "stress_balance.sia.bed_smoother.range": grid,
                    "stress_balance.ice_free_thickness_standard": 5,
                    "output.extra.stop_missing": "no",
                }
                if test_climate_models:
                    general_params_dict["test_climate_models"] = ""
                if start == simulation_start_year:
                    if initialstatefile is None:
                        general_params_dict["bootstrap"] = ""
                        general_params_dict["i"] = pism_dataname
                    elif initialstatefile == "var_ini":
                        general_params_dict["bootstrap"] = ""
                        general_params_dict["i"] = pism_dataname
                        general_params_dict["regrid_file"] = combination["input_file"]
                        general_params_dict["regrid_vars"] = regridvars
                    else:
                        general_params_dict["bootstrap"] = ""
                        general_params_dict["i"] = pism_dataname
                        general_params_dict["regrid_file"] = initialstatefile
                        general_params_dict["regrid_vars"] = regridvars
                else:
                    general_params_dict["i"] = regridfile

                if osize != "custom":
                    general_params_dict["o_size"] = osize
                else:
                    general_params_dict[
                        "output.sizes.medium"
                    ] = "sftgif,velsurf_mag,usurf,mask,uvelsurf,vvelsurf"

                if bed_deformation != "off":
                    general_params_dict["bed_def"] = "lc"

                if (bed_deformation == "ip") and (start == simulation_start_year):
                    general_params_dict[
                        "bed_deformation.bed_uplift_file"
                    ] = "$input_dir/data_sets/uplift/uplift_g{}m.nc".format(grid)

                if start == simulation_start_year:
                    grid_params_dict = generate_grid_description(grid, domain)
                else:
                    grid_params_dict = generate_grid_description(
                        grid, domain, restart=True
                    )

                sb_params_dict = {
                    "sia_e": combination["sia_e"],
                    "stress_balance.blatter.enhancement_factor": combination["sia_e"],
                    "ssa_e": ssa_e,
                    "ssa_n": ssa_n,
                    "pseudo_plastic_q": combination["ppq"],
                    "till_effective_fraction_overburden": tefo,
                    "vertical_velocity_approximation": vertical_velocity_approximation,
                    "stress_balance.ssa.strength_extension.constant_nu": 1.0e16,
                }

                if start == simulation_start_year:
                    sb_params_dict["topg_to_phi"] = ttphi

                # If stress balance choice is made in file, overwrite command line option
                if m_sb:
                    stress_balance = sb_dict[m_sb]
                stress_balance_params_dict = generate_stress_balance(
                    stress_balance, sb_params_dict
                )

                density_ice = 910.0
                flux_adjustment_file = (
                    f"$input_dir/data_sets/bed_dem/{domain}_v{version}_g{grid}m_mask.nc"
                )
                
                if combination["climate"] == "paleo":
                    climate_parameters = {
			"atmosphere.given.file": "$input_dir/data_sets/climate_forcing/{}".format(
				combination["climate_file"] #akglaciers_climate_cru_TS40_19980_2004_YMM.nc (spatial, YMM)
			),
			"atmosphere.anomaly.file": "$input_dir/data_sets/climate_forcing/{}".format(
				combination["anomaly_file"] #akglaciers_GISS-E2-R_lgm_historical.nc (spatial, YMM from GCMs)
			),
			"atmosphere.elevation_change.temperature_lapse_rate": 
				combination["temperature_lapse_rate"],
			"force_to_thickness_file": flux_adjustment_file,
			"surface.pdd.factor_ice": combination["pdd_factor_ice"]
			/ ice_density,
			"surface.pdd.factor_snow": combination["pdd_factor_snow"]
			/ ice_density,
			"surface.pdd.refreeze": combination["refreeze_factor"],
                    }
                elif combination["climate"] == "lgmdeglaciation":
                    climate_parameters = {
			"atmosphere.given.file": "$input_dir/data_sets/climate_forcing/{}".format(
				combination["climate_file"] #akglaciers_climate_cru_TS40_19980_2004_YMM.nc (spatial, YMM)
			),
			"atmosphere.anomaly.file": "$input_dir/data_sets/climate_forcing/{}".format(
				combination["anomaly_file"] #akglaciers_GISS-E2-R_lgm_historical.nc (spatial, YMM from GCMs)
			),
			"atmosphere.elevation_change.temperature_lapse_rate": 
				combination["temperature_lapse_rate"],
			"atmosphere.delta_T.file": "$input_dir/data_sets/climate_forcing/{}".format(
				combination["climate_modifier_file"] #scales the temperature by the ice core temperature change or not (constant dT for paleo runs)
			),
			"atmosphere.precip_scaling.file": "$input_dir/data_sets/climate_forcing/{}".format(
				combination["climate_modifier_file"] #scales the precipitation by the ice core temperature change or not (constant dT for paleo runs)
			),
#			"force_to_thickness_file": flux_adjustment_file,
			"surface.pdd.factor_ice": combination["pdd_factor_ice"]
			/ ice_density,
			"surface.pdd.factor_snow": combination["pdd_factor_snow"]
			/ ice_density,
			"surface.pdd.refreeze": combination["refreeze_factor"],
                    }
#                climate_parameters = {
#                    "atmosphere.given.file": "$input_dir/data_sets/climate_forcing/{}".format(
#                        combination["climate_file"] #akglaciers_climate_cru_TS40_19980_2004_YMM.nc (spatial, YMM)
#                    ),
#                    "atmosphere.anomaly.file": "$input_dir/data_sets/climate_forcing/{}".format(
#                        combination["anomaly_file"] #akglaciers_GISS-E2-R_lgm_historical.nc (spatial, YMM from GCMs)
#                    ),
#		    "atmosphere.elevation_change.temperature_lapse_rate": 
#			combination["temperature_lapse_rate"],
#                    "atmosphere.delta_T.file": "$input_dir/data_sets/climate_forcing/{}".format(
#                        combination["climate_modifier_file"] #scales the temperature by the ice core temperature change or not (constant dT for paleo runs)
#                    ),
#                    "atmosphere.precip_scaling.file": "$input_dir/data_sets/climate_forcing/{}".format(
#                        combination["climate_modifier_file"] #scales the precipitation by the ice core temperature change or not (constant dT for paleo runs)
#                    ),
#                    "force_to_thickness_file": flux_adjustment_file,
#                    "surface.pdd.factor_ice": combination["pdd_factor_ice"]
#                    / ice_density,
#                    "surface.pdd.factor_snow": combination["pdd_factor_snow"]
#                   / ice_density,
#                    "surface.pdd.refreeze": combination["refreeze_factor"],
#                }
                climate_parameters["surface.pdd.std_dev.value"] = combination["pdd_std_dev"]
                
                    
                climate_params_dict = generate_climate(
                    combination["climate"], **climate_parameters
                )                    
                    
                hydro_params_dict = generate_hydrology(hydrology)

                calving_parameters = {"thickness_calving_threshold": 100}

                calving_params_dict = generate_calving(calving, **calving_parameters)

                ocean_params_dict = {
                    "ocean.constant.melt_rate": 0.2,
		    "ocean.delta_sl.file": "$input_dir/data_sets/climate_forcing/{}".format(
                        combination["sealevel_modifier_file"]
                    ),
#                    "ocean.frac_MBP.file": "$input_dir/data_sets/climate_forcing/{}".format(
#                        combination["sealevel_modifier_file"]
#                    ),
                }

                if mbp == 1:
                    ocean_params_dict["ocean"] = "constant,frac_MBP"
                else:
                    ocean_params_dict["ocean"] = "constant, delta_sl"

                scalar_ts_dict = generate_scalar_ts(
                    outfile,
                    tsstep,
                    start=simulation_start_year,
                    end=simulation_end_year,
                    odir=dirs["scalar"],
                )

                all_params_dict = merge_dicts(
                    general_params_dict,
                    grid_params_dict,
                    stress_balance_params_dict,
                    climate_params_dict,
                    hydro_params_dict,
                    ocean_params_dict,
                    calving_params_dict,
                    scalar_ts_dict,
                )

                if not spatial_ts == "none":
                    exvars = spatial_ts_vars[spatial_ts]
                    spatial_ts_dict = generate_spatial_ts(
                        outfile,
                        exvars,
                        str(exstep),
                        odir=dirs["spatial_tmp"],
                        split=False,
                    )
                    all_params_dict = merge_dicts(all_params_dict, spatial_ts_dict)

                if stress_balance == "blatter":
                    del all_params_dict["skip"]
                    all_params_dict["time_stepping.adaptive_ratio"] = 100

                all_params = " \\\n  ".join(
                    ["-{} {}".format(k, v) for k, v in list(all_params_dict.items())]
                )

                if system == "debug":
                    redirect = " 2>&1 | tee {jobs}/job_{job_no}"
                else:
                    redirect = " > {jobs}/job_{job_no}.${job_id} 2>&1"

                template = "{mpido} {pism} {params}" + redirect

                context = merge_dicts(
                    batch_system,
                    dirs,
                    {"job_no": job_no, "pism": pism, "params": all_params},
                )
                cmd = template.format(**context)

                f.write(cmd)
                f.write("\n")
                f.write("\n")
                f.write("\n")
                if not spatial_ts == "none":
                    f.write(
                        "mv {tmpfile} {ofile}\n".format(
                            tmpfile=spatial_ts_dict["extra_file"],
                            ofile=join(dirs["spatial"], "ex_" + outfile),
                        )
                    )
                    f.write("\n")
                f.write(batch_system.get("footer", ""))

                f_combined.write(cmd)
                f_combined.write("\n\n")
                f_combined.write("\n")
                f_combined.write("\n")
                if not spatial_ts == "none":
                    f_combined.write(
                        "mv {tmpfile} {ofile}\n".format(
                            tmpfile=spatial_ts_dict["extra_file"],
                            ofile=join(dirs["spatial"], "ex_" + outfile),
                        )
                    )
                    f_combined.write("\n")

                regridfile = join(dirs["state"], outfile)
                outfiles.append(outfile)

        f_combined.write(batch_system.get("footer", ""))

    scripts_combinded.append(script_combined)


scripts = uniquify_list(scripts)
scripts_combinded = uniquify_list(scripts_combinded)
print("\n".join([script for script in scripts]))
print("\nwritten\n")
print("\n".join([script for script in scripts_combinded]))
print("\nwritten\n")
