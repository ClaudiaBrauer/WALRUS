
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

#' Computes goodness of fit for WALRUS
#' @description Computes the Nash-Sutcliffe efficiency of the discharge, Nash-Sutcliffe efficiency of the logarithm of the discharge and the mean sum of squares of the discharge
#' @param o the output of a WALRUS run (result of \code{WALRUS_loop}).
#' @param pars the parameter set used for the run.
#' @param n the name of the run.
#' @return NS, logNS and meanSS
#' @export WALRUS_GoF
#' @examples
#' x=1
#' 
WALRUS_GoF = function(o, pars, n)
{
  
  # remove first line with initial conditions
  o = o[2:nrow(o),]
  
  # look up soil type parameters
  pars$b         = soil_char[["b"]]      [soil_char[["st"]]==pars$st]
  pars$psi_ae    = soil_char[["psi_ae"]] [soil_char[["st"]]==pars$st]
  pars$theta_s   = soil_char[["theta_s"]][soil_char[["st"]]==pars$st]
  pars$aG        = 1-pars$aS  
  
  # compute goodness of fit measures and put them in the same table
  pars$NS     = round(1- sum((    o$Qobs  -     o$Q )^2, na.rm=TRUE) / sum((    o$Qobs  - mean(    o$Qobs ))^2, na.rm=TRUE), 3)
  pars$NSlog  = round(1- sum((log(o$Qobs) - log(o$Q))^2, na.rm=TRUE) / sum((log(o$Qobs) - mean(log(o$Qobs)))^2, na.rm=TRUE), 3)
  pars$meanSS = round(mean((o$Q - o$Qobs)^2, na.rm=TRUE), 3)
  
  # write table
  write.table(pars, paste("output/pars_NS_", n, ".dat", sep=""), row.names=FALSE)
  return(pars)
  
}