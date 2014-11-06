
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

#' Plot residual plots
#' @description Plot figures with residuals from WALRUS.
#' @param o the output of a WALRUS run (result of \code{WALRUS_loop}).
#' @param pars the parameter set used for the run.
#' @param n the name of the run.
#' @return a figure with residual plots
#' @export WALRUS_residuals
#' @examples
#' x=1
#' 
WALRUS_residuals = function(o, pars, n)

{
  
  if(is.null(o)==TRUE){o = read.table(paste("output/output_" , n, ".dat", sep=""), header=TRUE)}
  if(is.null(pars)==TRUE){pars = read.table(paste("output/pars_NS_", n, ".dat", sep=""), header=TRUE)}
  
  # remove first line with initial conditions
  o = o[2:nrow(o),]

  # compute residuals
  res = o$Q - o$Qobs
  
  # format x-axis: for 7 date labels on the x-axis, equally distributed
  place_xlabel = c(o$d[1] +c(0:6) *(o$d[nrow(o)] - o$d[1])/6)
  xlabel       = substr(as.character(as.POSIXct(place_xlabel, 
                  origin="1970-01-01", tz="UTC")),1,10)
  
  #########
  # FIGURES
  #########
  
  pdf(paste("figures/analysis_residuals_", n,".pdf", sep=""), width=9, height=5.2, family="Times")
  par(mar=c(2.5,2.8,0.2,2.5), mfrow=c(4,1), mgp=c(1.5,0.3,0), tcl=-0.2)
  
  # fig 1: Qobs and Qmod
  
  # plot d$Qobs
  plot(o$d, o$Qobs, col = "black",                                     
       xlab="", ylab=substitute(paste("Q [mm h"^{-1}, "]")), 
       type="l",  xaxs="i", yaxs="i", xaxt="n",
       ylim = c(0,1.1*max(c(o$Qobs, o$Q))))   
  
  # add Q_mod
  lines(o$d, o$Q, col = "dodgerblue")                                  
  
  # add P as bars from the top
  par(new = TRUE)                                                 
  plot(o$d, o$P,                                                       
       col = "purple", xlab="", ylab="", type="h", xaxt="n", yaxt="n", 
       xaxs="i", yaxs="i",
       ylim=c(2*max(o$P,na.rm=TRUE),0)) 
  axis(side=4)                                                  
  mtext(substitute(paste("P [mm h"^{-1}, "]")), side=4, line=1.5, cex=0.7)
  axis(side=1, at=place_xlabel, labels=xlabel)
  
  # add legend
  legend(c(expression(paste("Q"[obs])),expression(paste("Q"[mod])),"P"),      
         col=c("black","dodgerblue","purple"),
         x="topleft", lty=1,  bty="n")  
  legend(paste("NS=", round(pars$NS,2)), x="topright",  bty="n")
  
  
  # fig 2: residuals
  plot(o$d, res, type="l", col="red",
       xaxs="i", yaxs="i", xaxt="n", xlab="", ylab=substitute(paste("Residual [mm h"^{-1}, "]")))
  axis(side=1, at=place_xlabel, labels=xlabel)
  abline(h=0, col="yellowgreen")
  
  # fig 3: autocorrelation residuals
  y = acf(res, type="correlation", plot=FALSE)
  plot(y, type="l", xlab="Lag", ylab="Autocorrelation Res.", main="", col="red")
  abline(h=0, col="yellowgreen")
  
  # fig 4: crosscorrelation residuals and precipitation
  y=ccf(res, o$P, type="correlation", plot=FALSE)
  plot(y,type="l", xlab="Lag", ylab="Crosscorr. Res.-P", main="", col="red")
  abline(h=0, col="yellowgreen")
  
  dev.off()

}


