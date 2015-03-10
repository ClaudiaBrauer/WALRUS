
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

#' Computes variables for the next time step.
#' @description One of the main WALRUS-functions. Computes states and fluxes for one time step.
#' @param pars the parameter set used for the run.
#' @param i the initital states for this time step
#' @param t1 the start of the time step (in seconds since 1970-01-01)
#' @param t2 the end of the time step (in seconds since 1970-01-01)
#' @return a vector with the model output for one time step.
#' @export WALRUS_step
#' @examples
#' x=1
#' 
WALRUS_step = function(pars, i, t1, t2)
{
  ### FORCING
  # convert input to current stepsize [mm/timestep]
  P_t     = func_P    (t2)  - func_P    (t1)
  ETpot_t = func_ETpot(t2)  - func_ETpot(t1)
  fXG_t   = func_fXG  (t2)  - func_fXG  (t1)
  fXS_t   = func_fXS  (t2)  - func_fXS  (t1)
  hSmin_t = (func_hSmin(t2) + func_hSmin(t1))/2
    
  ### STEPSIZE
  dt      = (t2 - t1)/3600             # compute dt (in hours because parameters are in hours)
  dt_ok   = TRUE                       # stepsize small enough as default

  ### FLUXES (based on states from the start of this timestep [mm/timestep])
  PQ      = P_t * i$W                                             *pars$aG
  PV      = P_t * (1-i$W)                                         *pars$aG  
  PS      = P_t                                                   *pars$aS 
  ETV     = ETpot_t * get("func_beta_dV", envir=.WALRUSenv)(i$dV) *pars$aG
  ETS     = ETpot_t                                               *pars$aS
  if(i$hS < p_num$min_h*1000){ETS = 0}        # no ET from empty channel
  ETact   = ETV + ETS  
  fQS     = i$hQ / pars$cQ *dt
  fGS     = (pars$cD - i$dG - i$hS) * max((pars$cD - i$dG),i$hS) /pars$cG *dt
  Q       = get("func_Q_hS", envir=.WALRUSenv)(i$hS, pars=pars, hSmin=hSmin_t) *dt
  
  ### STATES (at the end of this time step / start of next time step) [mm])
  # note that fluxes are already for the whole time step (multiplied with dt)
  dV      = i$dV  - (fXG_t + PV - ETV - fGS          )            /pars$aG
  hQ      = i$hQ  + (PQ - fQS                        )            /pars$aG
  hS      = i$hS  + (fXS_t + PS - ETS + fGS + fQS - Q)            /pars$aS 
  dG      = i$dG  + (i$dV - i$dVeq) /pars$cV *dt       
  
  
  ### SPECIAL CASE: LARGE-SCALE PONDING AND FLOODING
  if((dV < 0) | (hS > pars$cD))
  {
    if((dV < 0) & (hS <= pars$cD))                  # if ponding and no flooding
    {
      hS  = hS + (-dV) *pars$aG /pars$aS            # all ponds to surface water
      dV = 0                                        # soil moisture deficit to surface
    }
    if((dV >= 0) & (hS > pars$cD))                  # if no ponding and flooding
    {
      dV  = dV - (hS-pars$cD) *pars$aS /pars$aG     # all floods into soil
      hS  = pars$cD                                 # channel bankfull
    }
    if((dV <= 0) & (hS >= pars$cD))                 # if ponding and flooding
    {
    dV  = dV*pars$aG - (hS-pars$cD)*pars$aS         # compute total excess water
    hS  = pars$cD - dV
    }  
    if(dV < 0){dG = dV}                             # if ponding, groundwater to pond level
  }  

  ### TEST IF STEP SIZE IS SMALL ENOUGH
  if(hS < -p_num$min_h)                             # if hS below channel bottom
  { 
    dt_ok = FALSE
    hS = p_num$min_h*100
  }else if(hQ < -p_num$min_h)                       # if hQ below bottom Q-res.
  { 
    dt_ok = FALSE
    hQ = p_num$min_h
  }else if(P_t > p_num$max_P_step)                  # if too much rainfall added
  {
    dt_ok = FALSE 
  }else if(abs(i$Q-Q) > p_num$max_dQ_step)          # if change in Q too big
  {
    dt_ok = FALSE
  }else if(abs(i$hS-hS) > p_num$max_h_change)   # if change in hS too big
  {
    dt_ok = FALSE
  }else if(abs(i$dG-dG) > p_num$max_h_change)   # if change in dG too big
  {
    dt_ok = FALSE
  } 

  ### OUTPUT
  # compute dependent variables (at end of time step)
  W      = get("func_W_dV", envir=.WALRUSenv)(dV,pars)
  dVeq   = get("func_dVeq_dG", envir=.WALRUSenv)(dG,pars)
    
  # bind output together in a vector
  return(c(ETact, Q, fGS, fQS, dV, dVeq, dG, hQ, hS, W, dt_ok))
  
} # end function

# compile to decrease runtime
WALRUS_step  = cmpfun(WALRUS_step)
