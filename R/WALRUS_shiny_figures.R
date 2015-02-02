
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


###############
### FIGURES ###
###############

#' Plot WALRUS-output for shiny
#' @description Makes several figures of the output variables from WALRUS.
#' @param o the output of a WALRUS run (result of \code{WALRUS_loop}).
#' @param pars the parameter set used for the run.
#' @return a figure in R.
#' @export WALRUS_shiny_figures
#' @examples
#' x=1
#' 
WALRUS_shiny_figures = function(o, pars)
  {
    
  # expand output data frame
  L    = nrow(o)
    
  # forcing
  step_start = output_date[1:(L-1)]
  step_end   = output_date[2:L    ]
  o$P          = c(NA,func_P    (step_end) - func_P    (step_start))
  o$ETpot      = c(NA,func_ETpot(step_end) - func_ETpot(step_start))
  o$Qobs       = c(NA,func_Qobs (step_end) - func_Qobs (step_start))
  o$fXG        = c(NA,func_fXG  (step_end) - func_fXG  (step_start))
  o$fXS        = c(NA,func_fXS  (step_end) - func_fXS  (step_start))
  o$hSmin      = func_hSmin(output_date)
  o$d          = output_date
    
  # cut off the warming-up
  o  = o[(warming_up_idx):L,] # keep initial values for balance computation, so if no warming up period, it will keep the whole vector
  L  = nrow(o)
  
  # compute timestepsize in hours
  dt = diff(o$d) /3600
  
  # remove first line with initial conditions
  o  = o[2:L,] # keep initial values for balance computation, so if no warming up period, it will keep the whole vector
  L  = nrow(o)
  NS = 1- sum((o$Qobs-o$Q)^2) / sum((o$Qobs-mean(o$Qobs))^2)
  
  

  # if time step daily (on average), convert sums of fluxes per timestep to mm/d
  if(mean(dt) < 24)
  { 
    res = " h"
    for(j in c(3,5:7,11:13)) {o[,j] = o[,j] /dt}
  }else{
    res=" d"
    for(j in c(3,5:7,11:13)) {o[,j] = o[,j] /dt*24}
  }
  for(j in c(4,10))        {o[,j] = o[,j] /dt*24} # Etpot and ETact always in days
   
  
  # convert date
  #date = as.POSIXct(o$d, origin="1970-01-01", tz="UTC")
  
  # format x-axis: for 7 date labels on the x-axis, equally distributed
  place_xlabel = c(o$d[1] +c(0:6) *(o$d[L] - o$d[1])/6)
  xlabel       = substr(as.character(as.POSIXct(place_xlabel, 
                  origin="1970-01-01", tz="UTC")),1,10)
    
  # graphical parameters
  size=1.2
  par(oma=c(2,0,0,0), mar=c(0.2,3.3,0.2,3), mfrow=c(4,1), mgp=c(2,0.3,0), 
      tcl=-0.2, xaxs="i", yaxs="i", cex=size, cex.axis=size, cex.lab=size)         
  
  
  ###########################
  # FIGURE 1: Qobs, Q, fGS, P
  ###########################
  
  # left y-axis: fGS, Qobs, Qmod
  plot(o$d, o$fGS, col="orange", type="l", ylim=c(0,1.1*max(c(o$Qobs, o$Q))),
       xlab="", ylab=substitute(paste("Q [mm ",res,""^{-1}, "]")), xaxt="n") 
  lines(o$d, o$Qobs, col="black")  
  lines(o$d, o$Q   , col="dodgerblue")  
  
  # right y-axis: P (as bars from the top)
  par(new = TRUE)                                                 
  plot(o$d, o$P, col = "purple", type="h", ylim=c(3*max(o$P),0),
       xlab="", ylab="", xaxt="n", yaxt="n") 
  axis(side=4, at=c(0,ceiling(max(o$P))/2,ceiling(max(o$P))), labels=c("0  ",ceiling(max(o$P))/2,ceiling(max(o$P))))   
  mtext(substitute(paste("P [mm ",res,""^{-1}, "]")), side=4, line=1.5, cex=0.7)
  
  # legends
  legend(c(expression(paste("Q"[obs])),expression(paste("Q"[mod])),expression(paste("f"[GS])), "P"),      
         col=c("black","dodgerblue", "orange", "purple"),
         x="topleft", lty=1,  bty="n")  
  
  
  ###########################
  # FIGURE 2: ETpot and ETact
  ###########################
  
  # left y-axis: 5-day moving averages of ETpot and ETact
  plot(o$d, rollmean(o$ETpot, round(120/mean(dt)), fill=NA), col="grey", 
       type="l", ylim=range(0,rollmean(o$ETpot, round(120/mean(dt)))*1.05),  
       xlab="", ylab=substitute(paste("ET [mm d"^{-1}, "]")), xaxt="n")
  lines(o$d, rollmean(o$ETact, round(120/mean(dt)), fill=NA), col="red")   
  
  
  # right y-axis: W
  par(new = TRUE)   
  plot(o$d, o$W, col="purple", type="l", ylim=c(0,1),
       xlab="", ylab="", xaxt="n", yaxt="n")
  axis(side=4, at=c(0,0.5,1), labels=c(" 0","0.5","1 "))                             
  mtext(substitute(paste("W [-]")), side=4, line=1.5, cex=0.7)
  
  # legend
  legend(c(expression(paste("ET"[pot])), expression(paste("ET"[act])), expression(paste("W"))), 
         col=c("grey","red","purple"), x="topleft", lty=1, bty="n")
  
  
  ######################
  # FIGURE 3: dV, dG, hS
  ######################
  
  # dV, dG, cD-hS (all in m below soil surface)
  plot(o$d, o$dV/1000, col="red", type="l", ylim=(range(o$dV,o$dG,pars$cD-o$hS,pars$cD,0)[2:1])/1000,
       xlab="", ylab=substitute(paste("d [m]")), yaxs="r", xaxt="n")
  lines(o$d, o$dG/1000, col="orange")
  lines(o$d, (pars$cD-o$hS)/1000, col="dodgerblue")
  abline(h=pars$cD/1000, col="dodgerblue", lty=2)
  abline(h=0, col="orange", lty=2)
  
  # legend
  legend(c(expression(paste("d"[V])), expression(paste("d"[G])), expression(paste("c"[D],"-h"[S]))),
         col=c("red","orange","dodgerblue"), 
         x="topleft", lty=1, bty="n")
  
  
  #########################
  # FIGURE 4: fGS, fXS, fXG
  #########################
  
  # Q, fGS, fXS, fXG
  plot(o$d, o$fGS, type="n", ylim=range(o$fGS, o$fXS, o$fXG),
       xlab="", ylab=substitute(paste("f [mm ",res,""^{-1}, "]")), yaxs="r", xaxt="n") 
  polygon(c(o$d,o$d[nrow(o):1]), c(o$Q,rep(0,nrow(o))), col="grey90", border=NA)
  lines(o$d, o$fGS, col="orange")   
  lines(o$d, o$fXS, col="dodgerblue" , lty="33") 
  lines(o$d, o$fXG, col="orange"     , lty="36")   
  
  
  # legends
  box()
  legend(c(expression(paste("Q")),expression(paste("f"[GS])),expression(paste("f"[XG])),expression(paste("f"[XS]))),
         col = c("grey90","orange","orange","dodgerblue"),
         x="topleft", lty=c(1,1,2,2), lwd=c(5,1,1,1), bty="n")
  if(is.null(pars$cS)==TRUE)
  {
    legend(sapply(c(bquote(paste("c"[W], " = ",.(round(pars$cW)), " mm")),
                    bquote(paste("c"[V], " = ",.(round(pars$cV)), " h")), 
                    bquote(paste("c"[G], " = ",.(round(pars$cG/1000000)), " x 10"^6,"mm h")),
                    bquote(paste("c"[Q], " = ",.(round(pars$cQ)), " h"))), as.expression),
           col = c("purple","red","orange","forestgreen"),
           x="topright", pch=16, bty="n")
  }else{
    legend(sapply(c(bquote(paste("c"[W], " = ",.(round(pars$cW)), " mm")),
                    bquote(paste("c"[V], " = ",.(round(pars$cV)), " h")), 
                    bquote(paste("c"[G], " = ",.(round(pars$cG/1000000)), " x 10"^6,"mm h")),
                    bquote(paste("c"[Q], " = ",.(round(pars$cQ)), " h")),
                    bquote(paste("c"[S], " = ",.(round(pars$cS)), " mm h"^{-1}))), as.expression),
           col = c("purple","red","orange","forestgreen","dodgerblue"),
           x="topright", pch=16, bty="n")
  }
  
  # add the x-axis
  axis(side=1, at=place_xlabel, labels=xlabel)
  
  }  # end of function
 




