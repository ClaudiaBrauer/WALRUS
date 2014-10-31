### Getting started 

# Remove everything from R's memory.
rm(list=ls())

# Load the WALRUS package.
library(WALRUS)

# Change working directory to the folder where data-, figures- and output-subfolders 
# are located.
setwd("D:/Dropbox/WALRUS/examples/")

### Data

# Read daily or hourly precipitation, potential evapotranspiration and discharge data.
data = read.table("data/PEQ_Hupsel.dat", header=TRUE)

# Specify which period of the total data set you want to use as forcing data.
# Use the same date format as in data file (for example yyyymmddhh).
forc = WALRUS_selectdates("data", 2011120000, 2012020000)

# Preprocessing forcing and specifying for which moments output should be stored. 
# The argument dt is time step size used in the output data file (in hours).
WALRUS_preprocessing(f=forc, dt=1)

### Parameters and initial values

# Define the parameters (cW, cV, cG, cQ, cS), initial conditions (dG0) and 
# catchment characteristics (cD, aS, soil type).
pars = data.frame(cW=200, cV=4, cG=5e6, cQ=10, cS=4, 
                  dG0=1250, cD=1500, aS=0.01, st="loamy_sand")

### Call functions to run model

# Give the run a logical name. This will be used for the output data files and figures.
name = "basic_example"

# Run the model. 
mod = WALRUS_loop(pars=pars)

# Postprocessing: create datafiles and show figures.
WALRUS_postprocessing(o=mod, pars=pars, n=name)
