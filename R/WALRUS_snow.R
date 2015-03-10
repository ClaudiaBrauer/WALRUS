
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


#' Snow preprocessor
#' @description Computes snow accumulation and melt using temperature data (column T in the forcing data frame) and, 
#' if the method "SRF" is used, also shortwave radiation (column GloRad). 
#' @param f the forcing data frame.
#' @param method the method for snowmelt. Options: "DHF" - degree hour factor 
#' or "SRF" - shortwave radiation factor. 
#' @return a forcing data frame with an adapted column for precipitation
#' @export WALRUS_snow
#' @examples
#' x=1
#' @details In this version of WALRUS, the parameters values for the snow module are fixed at 
#' DHF=0.32, alb=0.7, SRF=0.0014, TF=0.05, Tref=0.5, min.rain.temp=-0.5 and max.snow.temp=1.5.
#' These values are based on Dutch conditions.
#' For more information on the snow parameters, see Wendt, D. E., 2015: Snow hydrology in 
#' the Netherlands: Developing snowmelt algortihms for Dutch regional water management modules,
#' Wageningen University, internship report (at HKV). 

WALRUS_snow = function (f, method)
{  

  #########################
  # DEFAULT SNOW PARAMETERS
  #########################
  
  snowpar = c(DHF=0.32, alb=0.7, SRF=0.0014, TF=0.05, Tref=0.5, 
              min.rain.temp=-0.5, max.snow.temp=1.5)
  
  
  ####################
  # DIVISION RAIN/SNOW
  ####################

  # first guess: all precipitation is rain (frac = rain fraction)
  frac   = rep(1, nrow(f))  
  
  # if very cold: all snow
  frac[f$T < snowpar[6]] = 0

  # if cold: partly snow
  idx = which(f$T < snowpar[7] & f$T >= snowpar[6])
  frac[idx] = (f$T[idx] - snowpar[6]) / (snowpar[7] - snowpar[6])
  
  # compute rain and snow
  rain = f$P * frac
  snow = f$P * (1 - frac)
  
  
  ################
  # POTENTIAL MELT
  ################
  
  # degree hour factor method
  if(method=="DHF") {melt = pmax(0, snowpar[1] * (f$T - snowpar[5]))} 
  
  # shortwave radiation factor method
  if(method=="SRF") {melt = pmax(0, (snowpar[4] + snowpar[3] * (1-snowpar[2]) * f$GloRad) * (f$T - snowpar[5]))}
  

  ############################
  # ACCUMULATION + ACTUAL MELT
  ############################
    
  # compute snow pack and actual melt
  pack    = c()        
  pack[1] = snow[1]
  
  # loop over time steps
  for(s in 2:nrow(f))
  {
    # reduce melt if not enough water in snow pack
    if(melt[s] > pack[s-1]) {melt[s] = pack[s-1]}
    
    # compute new snow pack
    pack[s] = pack[s-1] + snow[s] - melt[s]
  }
  
  
  #############
  # RAIN + MELT
  #############
  
  # sum rain and melt
  f$P = rain + melt
  
  # return data frame with new P-column
  return(f)
}
