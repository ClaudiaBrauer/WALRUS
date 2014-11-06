
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


#####################
### WATER BALANCE ###
#####################

#' Computes the water budget.
#' @description Computes the water budget over the WALRUS-run.
#' @param o the output of a WALRUS run (result of \code{WALRUS_loop}).
#' @param pars the parameter set used for the run.
#' @param n the name of the run.
#' @return a data frame with the water budget, both printed to screen and written to file (in the output-folder).
#' @export WALRUS_balance
#' @examples
#' x=1

WALRUS_balance  = function(o, pars, n)
{
  # read model output data
  o         = o[,c(3:7,10:14,16:18)]
  L         = nrow(o)
     
  # sums of fluxes
  WB        = data.frame(t(colSums(o[2:L,])))
    
  # storage changes per reservoir
  WB$dV     = (o$dV [1] - o$dV [L]) *pars$aG
  WB$dG     = (o$dG [1] - o$dG [L]) *pars$aG
  WB$hQ     = (o$hQ [L] - o$hQ [1]) *pars$aG
  WB$hS     = (o$hS [L] - o$hS [1]) *pars$aS
  
  # add start and end date
  WB$start  = o$date[1]
  WB$end    = o$date[L]
  WB$ndays  = round((output_date[L] - output_date[1]) /(3600*24))
  
  # compute water balance
  WB$check  = WB$P - WB$ETact - WB$Q + WB$fXG + WB$fXS - WB$dV - WB$hS - WB$hQ
  
  # round to 1 decimal
  WB        = round(WB,1)
    
  # write tables
  write.table(WB, paste("output/balance_", n, ".dat", sep=""), row.names=FALSE)
  
  print(WB)
  
}









 