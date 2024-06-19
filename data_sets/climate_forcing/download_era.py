import cdsapi

c = cdsapi.Client()

c.retrieve(
    "sis-european-energy-sector",
    {
        "format": "tgz",
        "variable": "air_temperature",
        "time_aggregation": "1_month_average",
        "bias_correction": "normal_distribution_adjustment",
        "vertical_level": "2_m",
    },
    "tas.tar.gz",
)

c.retrieve(
    "sis-european-energy-sector",
    {
        "format": "tgz",
        "variable": "precipitation",
        "time_aggregation": "1_month_average",
        "vertical_level": "0_m",
        "bias_correction": "bias_adjustment_based_on_gamma_distribution",
    },
    "pr.tar.gz",
)
