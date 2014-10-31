### Getting started 

# Remove everything from R's memory.
rm(list=ls())

# Load the WALRUS package and the HydroPSO package for the particle swarm 
# optimisation technique by Zambrano-Bigarini and Rojas (2013). 
library(WALRUS)
library(hydroPSO)

# Change working directory to the folder where the subfolders "data", "figures" and 
# "output" are located.
setwd("D:/Dropbox/WALRUS/examples/")


### Forcing

# Read daily or hourly precipitation, potential evapotranspiration and discharge data.
data = read.table("data/PEQ_Hupsel.dat", header=TRUE)

# Specify which period of the total data set you want to use as forcing data.
# Use the same date format as in data file (for example yyyymmddhh).
forc = WALRUS_selectdates("data", 2011120000, 2012020000)

# Preprocessing forcing and output data file. The argument dt is time step size used 
# in output data file (in hours).
WALRUS_preprocessing(f=forc, dt=1)
WALRUS_preprocessing_calibration()


### Prepare calibration

# Give the run a logical name.
name = "calibration_example"

# Define initial and boundary values for the parameters (and/or initial conditions) 
# you want to calibrate.
par_start = c(200, 4  , 5e6  , 10 ) 
par_LB    = c(100, 0.1, 0.1e6, 1  )
par_UB    = c(400, 50 , 100e6, 100)

# Rewrite the model such that the output is the goodness of fit (evaluation of the 
# calibration criterion).
WALRUS_for_optim = function(par)
{
  fit_pars = data.frame(cW=par[1], cV=par[2], cG=par[3], cQ=par[4], cS=4, 
                        dG0=1200, cD=1500, aS=0.01, st="loamy_sand")
  mod = WALRUS_loop(pars=fit_pars)
  return(mean((Qobs_forNS-mod$Q)^2, na.rm=TRUE))
}

# Test if the starting model parameters yield reasonable results. 
fit_pars = data.frame(cW=par_start[1], cV=par_start[2], cG=par_start[3], 
           cQ=par_start[4], cS=4, 
           dG0=1200, cD=1500, aS=0.01, st="loamy_sand")
mod      = WALRUS_loop(pars=fit_pars)
WALRUS_postprocessing(o=mod, pars=fit_pars, n=name)


### Calibration

# The particle swarm optimization.
# REPORT determines the amount of information shown on the screen during calibration.
# Increasing REPORT will give more information.
# npart is the number of particles. 
# Increasing npart will lead to better results, but longer runtimes.
cal = hydroPSO(par=par_start, lower=par_LB, upper=par_UB, fn=WALRUS_for_optim, 
               control=list(verbose=TRUE, REPORT=1, npart=2))

# Make figures of the calibration results (standard output from the hydroPSO-package).
plot_results(MinMax="min", do.png=TRUE) 

# Load the optimal parameter values found in the calibration procedure
PSO_pars  = read.table("PSO.out/BestParameterSet.txt", header=TRUE)
opt_pars  = data.frame(cW=PSO_pars$Param1, cV=PSO_pars$Param2, cG=PSO_pars$Param3, 
            cQ=PSO_pars$Param4, cS=4, 
            dG0=1200, cD=1500, aS=0.01, st="loamy_sand")

# Run once more with best parameters to create data files and plot figures.
mod = WALRUS_loop(pars=opt_pars)
WALRUS_postprocessing(o=mod, pars=opt_pars, n=name)


### Monte Carlo calibration

# Make many (in this example 10000) random parameter sets within certain limits.
cW = runif(10000, min=100, max=400 )
cV = runif(10000, min=0.1, max=50  )
cG = runif(10000, min=1e5, max=1e8 )
cQ = runif(10000, min=1  , max=100 )

# Make an empty vector to store mean sums of squares during for-loop.
SS = c()

# Run a for-loop over all parameter sets and run WALRUS in every iteration.
for(i in 1:10000)
    {
    # look up the parameter set for this iteration
    parameters = data.frame(cW=cW[i], cV=cV[i], cG=cG[i], cQ=cQ[i], cS=5, 
                            dG0=1000, cD=1500, aS=0.01, st="loamy_sand")
    
    # run WALRUS
    modeled    = WALRUS_loop(pars=parameters)
    
    # Compute and store the mean sum of squares.
    SS[i]      = mean((Qobs_forNS-modeled$Q)^2)    
    }

# Write the results to file: parameter values and belonging sum of squares.
write.table(data.frame(cbind(cW, cV, cG, cQ, SS)), "par_SS_MC.dat")



