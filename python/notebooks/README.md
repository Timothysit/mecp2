# Python notebooks and dashboards

This folder contains jupyter notebooks and python scripts for exploratory analysis of microelectrode-array (MEA) data.


## Dependencies 

All dependencies can be installed with `pip install [package]`, the main ones you will need are:

 - panel (for making dashbaords, use the latest version available, some feature such as progress bar is incompatable with older versions)
 - xarray (better numpy array managemenet)
 - sciplotlib (for better style defaults for matplotilb plots)


## Spike Detection Dashboard

In particular, the main feature in the notebook is (currently) the spike detection dashbaord, which can be run by changing to this directory, and running:

`panel serve 3-panel-test-param-and-pipeline.ipynb` 

(the name of the notebook is likely going to be changed to something more clear in the future)



