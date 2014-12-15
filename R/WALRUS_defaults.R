
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

# make environment for package
.WALRUSenv <- new.env()

# soil characteristics
soil_char = list(
  st      = c("sand","loamy_sand","sandy_loam","silt_loam","loam","sandy_clay_loam",
                 "silt_clay_loam","clay_loam","sandy_clay","silty_clay","clay","cal_H","cal_C"),
  b       = c(4.05,4.38,4.90,5.30,5.39,7.12,7.75,8.52,10.40,10.40,11.40,2.63,16.77),
  psi_ae  = c(121,90,218,786,478,299,356,630,153,490,405,90,9),
  theta_s = c(0.395,0.410,0.435,0.485,0.451,0.420,0.477,0.476,0.426,0.492,0.482,0.418,0.639))

# default values parameters of default parameterisations
p_default      = data.frame(
  zeta1        = 0.02,
  zeta2        = 400,
  expS         = 1.5)

# default values numeric parameters  
p_num          = data.frame(
  min_h        = 0.001, 
  max_P_step   = 10,
  max_dQ_step  = 0.1,
  max_h_change = 10,
  min_timestep = 60)



#########################
# default function W(dV)
#########################

func_W_dV_default = function(x,pars){(cos(max(min(x,pars$cW),0)*pi/pars$cW)/2+.5)}

assign("func_W_dV", cmpfun(func_W_dV_default), envir = .WALRUSenv)

#'Set the wetness index function
#' @description Changes the default wetness index function \code{func_W_dV}
#' @param newfunc a function which computes wetness index \code{W} [unitless]
#' from storage deficit \code{dV} [mm],
#' with arguments \code{x} (here storage deficit).
#' @return a function to be used as evapotranspiration reduction function.
#' @export set_func_W_dV
#' @examples
#' x=1
#' 
set_func_W_dV = function(newfunc){if(is.null(newfunc)){
                      assign("func_W_dV", cmpfun(func_W_dV_default), envir=.WALRUSenv)
                }else{assign("func_W_dV", cmpfun(newfunc)          , envir=.WALRUSenv)}}

#' Show current wetness index function
#' @description Shows which wetness index function \code{func_W_dV} is used.
#' @return the function to be used as wetness index function.
#' @export show_func_W_dV
#' @examples
#' x=1
#' 
show_func_W_dV = function(){print(get("func_W_dV", envir=.WALRUSenv))}

############################
# default function dVeq(dG)
############################

func_dVeq_dG_default  = function(x, pars){if(x>pars$psi_ae){
                         (x - pars$psi_ae/(1-pars$b) - x*(x/pars$psi_ae)^(-1/pars$b) + 
                         pars$psi_ae/(1-pars$b) *(x/pars$psi_ae)^(1-1/pars$b))*pars$theta_s
                         }else if(x<0){x
                         }else{0}}

assign("func_dVeq_dG", cmpfun(func_dVeq_dG_default), envir = .WALRUSenv)

#'Set the relation between equilibrium storage deficit and groundwater depth
#' @description Changes the default relation between equilibrium storage deficit and groundwater depth
#' \code{func_dVeq_dG}
#' @param newfunc a function which computes equilibrium storage deficit \code{dVeq} [mm]
#' from grounwdater depth \code{dG} [mm],
#' with arguments x (here storage deficit).
#' @return a function to be used as evapotranspiration reduction function.
#' @export set_func_dVeq_dG
#' @examples
#' x=1
#' 
set_func_dVeq_dG = function(newfunc){if(is.null(newfunc)){
                         assign("func_dVeq_dG", cmpfun(func_dVeq_dG_default), envir=.WALRUSenv)
                   }else{assign("func_dVeq_dG", cmpfun(newfunc)             , envir=.WALRUSenv)}}

#' Show current equilibrium storage deficit-groundwater depth relation
#' @description Shows which relation between equilibrium storage deficit and groundwater 
#' depth \code{func_dVeq_dG} is used.
#' @return the function to be used as relation between equilibrium storage deficit and groundwater depth.
#' @export show_func_dVeq_dG
#' @examples
#' x=1
#' 
show_func_dVeq_dG = function(){print(get("func_dVeq_dG", envir=.WALRUSenv))}


############################
# default function beta(dV)
############################

func_beta_dV_default  = function(x){((1-exp(-p_default$zeta1*(p_default$zeta2-x)))/
                                     (1+exp(-p_default$zeta1*(p_default$zeta2-x)))/2+0.5)}

assign("func_beta_dV", cmpfun(func_beta_dV_default), envir = .WALRUSenv)

#'Set the evapotranspiration reduction function
#' @description Changes the default evapotranspiration reduction function \code{func_beta_dV}
#' @param newfunc a function which computes evapotranspiration reduction \code{beta} 
#' (=ETact/ETpot) [unitless] from storage deficit \code{dV} [mm],
#' with arguments \code{x} (here storage deficit).
#' @return a function to be used as evapotranspiration reduction function.
#' @export set_func_beta_dV
#' @examples
#' x=1
#' 
set_func_beta_dV = function(newfunc){if(is.null(newfunc)){
                         assign("func_beta_dV", cmpfun(func_beta_dV_default), envir=.WALRUSenv)
                   }else{assign("func_beta_dV", cmpfun(newfunc)             , envir=.WALRUSenv)}}

#' Show current evapotranspiration reduction function
#' @description Shows which evapotranspiration reduction function \code{func_beta_dV} is used.
#' @return the function to be used as evapotranspiration reduction function.
#' @export show_func_beta_dV
#' @examples
#' x=1
#' 
show_func_beta_dV = function(){print(get("func_beta_dV", envir=.WALRUSenv))}


############################
# default function Q(hS)
############################

func_Q_hS_default = function(x, pars, hSmin){
  #if(is.null(hSmin)==TRUE){hSmin=0}
  if(x <= hSmin)
    {
    0
    }else{
    if(x <= pars$cD)
      {
      (pars$cS/(pars$cD-hSmin)^p_default$expS * (x-hSmin)^p_default$expS)
      }else{
      pars$cS + (pars$cS/(pars$cD-hSmin)^p_default$expS * (x-pars$cD)^p_default$expS)
      }
    }
  }

assign("func_Q_hS", cmpfun(func_Q_hS_default), envir = .WALRUSenv)

#' Set the stage-discharge relation
#' @description Changes the default stage-discharge relation \code{func_Q_hS}
#' @param newfunc a function which computes discharge \code{Q} [mm/h] from stage height \code{hS} [mm],
#' with arguments \code{x} (here stage height), \code{pars} (parameter set) and \code{hSmin} (weir height).
#' If ran without arguments, the function will be reset to the default. 
#' @return a function to be used as stage-discharge relation.
#' @export set_func_Q_hS
#' @examples
#' x=1
#' 
set_func_Q_hS = function(newfunc){if(is.null(newfunc)){
                      assign("func_Q_hS", cmpfun(func_Q_hS_default), envir=.WALRUSenv)
                }else{assign("func_Q_hS", cmpfun(newfunc)          , envir=.WALRUSenv)}}

#' Show current stage-discharge relation
#' @description Shows which stage-discharge relation \code{func_Q_hS} is used.
#' @return the function to be used as stage-discharge relation.
#' @export show_func_Q_hS
#' @examples
#' x=1
#' 
show_func_Q_hS    = function(){print(get("func_Q_hS", envir=.WALRUSenv))}







