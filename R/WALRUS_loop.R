
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

#' Runs over all time steps and calls \code{WALRUS_step}
#' @description One of the main WALRUS-functions. Computes initial values and provides the for-loop with flexible time step.
#' @param pars the parameter set used for the run.
#' @return a data frame with the model output for all output time steps.
#' @export WALRUS_loop
#' @examples
#' x=1
#' 
WALRUS_loop = function(pars)
  {
  # compute number of o_steps
  L            = length(output_date)  
  # make empty vectors for output states and fluxes
  o            = data.frame(matrix(nrow=L, ncol=11, dimnames=list(NULL, 
                 c("ETact","Q","fGS","fQS","dV","dVeq","dG","hQ","hS","W","dt_ok"))))
    
  # look up soil type parameters
  pars$b          = soil_char[["b"]]      [soil_char[["st"]]==pars$st]
  pars$psi_ae     = soil_char[["psi_ae"]] [soil_char[["st"]]==pars$st]
  pars$theta_s    = soil_char[["theta_s"]][soil_char[["st"]]==pars$st]
  pars$aG         = 1-pars$aS
  
  
  ######################
  ### INITIAL CONDITIONS 
  ######################
  
  # Q[1] is necessary for stepsize-check (if dQ too large)
  if(is.null(pars$Q0)==FALSE)
    {
      o$Q[1]  = pars$Q0
    }else{
      o$Q[1]  = func_Qobs(output_date[2]) / (output_date[2]-output_date[1]) *3600
    }

  # hS from first Q measurement and Qh-relation
  if(is.null(pars$hS0)==FALSE)
  {
    o$hS[1]  = pars$hS0
  }else{
    o$hS[1]  = uniroot(f=function(x){return(
      get("func_Q_hS", envir=.WALRUSenv)(x,pars,hSmin=func_hSmin(output_date[1]))-o$Q[1])},
      lower=0, upper=pars$cD)$root 
  }
  
  
# dG and hQ    
  if(is.null(pars$dG0)==FALSE)                            # if dG0 provided 
  {
    o$dG[1] = pars$dG0
    if(is.null(pars$hQ0)==FALSE)                          # if hQ0 also provided 
    {
      o$hQ[1] = pars$hQ0
    }else{                                                # if hQ0 not provided 
      if((pars$cD-o$dG[1])<o$hS[1])                       # if groundwater below surface water level
      {
        o$hQ [1] = o$Q[1]*pars$cQ                         # all Q from quickflow
      }else{                                              # if groundwater above surface water level
        o$hQ [1] = max(0,(o$Q[1]-(pars$cD-o$dG[1]-o$hS[1])*(pars$cD-o$dG[1])/pars$cG) *pars$cQ)
      }   
    }
    
  }else if(is.null(pars$dG0)==TRUE & is.null(pars$hQ0)==FALSE) # if hQ0 provided but dG0 not
  {
    o$hQ[1] = pars$hQ0
    o$dG[1] = max(0,uniroot(f=function(x){return((pars$cD-x-o$hS[1])*(pars$cD-x)/pars$cG - max((o$Q[1]-o$hQ[1]/pars$cQ),0))},
                         lower=0, upper=(pars$cD-o$hS[1]))$root)
  }else{                                                 # if dG0 not provided 
    if(is.null(pars$Gfrac)==TRUE){pars$Gfrac=1}          # if Gfrac also not provided, make Gfrac 1
    # if fGS not possible with current hS and cG, make Gfrac smaller
    while(((pars$cD-o$hS[1])*pars$cD/pars$cG) < (pars$Gfrac*o$Q[1])) {pars$Gfrac = pars$Gfrac/2}
    # compute dG leading to the right fGS
    o$dG  [1]  = uniroot(f=function(x){return((pars$cD-x-o$hS[1])*(pars$cD-x)/pars$cG - o$Q[1]*pars$Gfrac)},
                         lower=0, upper=(pars$cD-o$hS[1]))$root
    o$hQ  [1]  = o$Q[1] *(1-pars$Gfrac) *pars$cQ    
  }

  # dVeq
  o$dVeq [1]  = get("func_dVeq_dG", envir=.WALRUSenv)(o$dG[1], pars)   
  
  # dV
  if(is.null(pars$dV0)==FALSE)
  {
    o$dV[1]  = pars$dV0
  }else{
    o$dV[1]  = o$dVeq[1]
  }

  # W
  o$W    [1]  = get("func_W_dV", envir=.WALRUSenv)(o$dV[1], pars)

  # prepare for-loop
  o_step       = o[1,]
  i            = o[1,]


  ####################################
  ### RUN FOR-LOOP OVER ALL TIME STEPS
  ####################################

  for (t in 2:L)
  {  
    start_step     = output_date[t-1]                  # start at begin of output step
    end_step       = output_date[t]                    # first try whole output step
    sums_step      = rep(0,4)                          # to sum fluxes of substeps
    # as long as you're not at the end of the original time_step yet
    while(start_step < (output_date[t] - p_num$min_timestep))
    {
      o_step[1,]   = WALRUS_step(pars=pars, i=i, t1=start_step, t2=end_step)
      # if time step too large (and not very small)
      if((o_step$dt_ok == FALSE) & ((end_step-start_step) > p_num$min_timestep))         
      {
        end_step   = (start_step + end_step)/2         # decrease step and run model
      }else{                                           # if one step completed (dt small enough)
        start_step = end_step                          # start of next step
        end_step   = output_date[t]                    # try to the end of the step
        sums_step  = sums_step + o_step[1:4]           # remember sums of fluxes
        i          = o_step                            # initial conditions for next step
      }
    }
    # final output of the step
    o[t,   ] = o_step                                  # keep states of last step
    o[t,1:4] = sums_step                               # replace fluxes with sums of steps
  }  
        
  # remove dt_ok column
  o = o[,1:10]
  
  return(o)
  } # end function

# compile to decrease runtime
WALRUS_loop  = cmpfun(WALRUS_loop)
