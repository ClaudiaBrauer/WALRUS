
##   The Wageningen Lowland Runoff Simulator (WALRUS): 
##   a lumped rainfall-runoff model for catchments with shallow groundwater
##   
##   Copyright (C) 2014 Claudia Brauer
##   
##   This program is free software: you can redistribute it and/or modify
##   it under the terms of the GNU General Public License as published by
##   the Free Software Foundation, either version 3 of the License, or
##   (at your option) any later version.
##   
##   This program is distributed in the hope that it will be useful,
##   but WITHOUT ANY WARRANTY; without even the implied warranty of
##   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##   GNU General Public License for more details.
##   
##   You should have received a copy of the GNU General Public License
##   along with this program.  If not, see <http://www.gnu.org/licenses/>.

#' Postprocessing
#' @description Postprocesses the model output: writes output files and makes figures.
#' @param o the output of a WALRUS run (result of \code{WALRUS_loop}).
#' @param pars the parameter set used for the run.
#' @param n the name of the run.
#' @return a file with time series of all model variables, a file with model parameters 
#' and goodness of fit, the water balance table (both in file and in R), a figure with
#' time series of all model variables (both file and in R) and a figure with residual plots (file).
#' @export WALRUS_postprocessing
#' @examples
#' x=1
#' 
WALRUS_postprocessing = function(o, pars, n)
{
  
  # write output file
  o_new = WALRUS_output_file(o, n)
  
  # compute goodness of fit and update parameter list
  p_new = WALRUS_GoF(o_new, pars, n) 

  # compute water balance 
  WALRUS_balance(o_new, p_new, n)
  
  # make plots of residuals
  WALRUS_residuals(o_new, p_new, n)
  
  # make figures
  WALRUS_figures(o_new, p_new, n)  
  
}
