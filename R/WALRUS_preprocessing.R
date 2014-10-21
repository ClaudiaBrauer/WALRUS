
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

#' Preprocessing
#' @description Preprocesses the forcing data.
#' @param f a dataframe with forcing data: date in YYYYmmddhh or YYYmmdd format and columns with P, ETpot, Q (at least one value), fXG (optional), fXS (optional), dG (optional)
#' @param dt the time step size increase (e.g. when given hourly data and want to producre daily model output, use 24.)
#' @return a vector \code{output_date} with the moments on which output should be generated
#' @export WALRUS_preprocessing
#' @examples
#' x=1
#' 
WALRUS_preprocessing = function(f, dt)
{
  
  # separate files for separate variables?
  # check for missing variables
  if(is.null(f$date )==TRUE){date=c(1:nrow(f)*dt*3600)}
  if(is.null(f$P    )==TRUE){print("Error: please supply P in forcing data frame")}
  if(is.null(f$ETpot)==TRUE){print("Error: please supply ETpot in forcing data frame")}
  if(is.null(f$Q    )==TRUE){print("Error: please supply Q in forcing data frame")}
  if(is.null(f$fXG  )==TRUE){f$fXG   =rep(0,nrow(f))}
  if(is.null(f$fXS  )==TRUE){f$fXS   =rep(0,nrow(f))}
  if(is.null(f$hSmin)==TRUE){f$hSmin =rep(0,nrow(f))}
  if(is.null(f$dG   )==TRUE){f$dG    =rep(0,nrow(f))}
  if(is.null(f$warm )==TRUE){f$warm=0}
  
  # fill data gaps
  if(is.na(sum(f$P))==TRUE)
    {print(paste("Note: missing P set to zero (", length(which(is.na(f$P))), " cases)", sep=""))
    f$P = na.fill(f$P,0)}
  if(is.na(sum(f$ETpot))==TRUE)
    {print(paste("Note: missing ETpot interpolated (", length(which(is.na(f$ETpot))), " cases)", sep=""))
    f$ETpot = na.approx(f$ETpot)}
  if(is.na(sum(f$Q))==TRUE)
    {print(paste("Note: missing Q interpolated (", length(which(is.na(f$Q))), " cases)", sep=""))
    f$Q = na.approx(f$Q)}
  if(is.na(sum(f$fXG))==TRUE)
    {print(paste("Note: missing fXG interpolated (", length(which(is.na(f$fXG))), " cases)", sep=""))
    f$fXG = na.approx(f$fXG)}
  if(is.na(sum(f$fXS))==TRUE)
    {print(paste("Note: missing fXS interpolated (", length(which(is.na(f$fXS))), " cases)", sep=""))
    f$fXS = na.approx(f$fXS)}
  if(is.na(sum(f$hSmin))==TRUE)
    {print(paste("Note: missing fXS interpolated (", length(which(is.na(f$hSmin))), " cases)", sep=""))
    f$hSmin = na.approx(f$hSmin)}
  if(is.na(sum(f$dG))==TRUE)
    {print(paste("Note: missing dG interpolated (", length(which(is.na(f$dG))), " cases)", sep=""))
    f$dG = na.approx(f$dG)}
  
  # write date as number of seconds since 1970
  if(is.null(f$date)==FALSE)
  {
    if(f$date[1] > 1e7 & f$date[1] < 1e8)
    {
      date = as.numeric(strptime(as.character(f$date), format="%Y%m%d", tz="UTC"))
    }else if(f$date[1] > 1e9 & f$date[1] < 1e10)
    {
      date = as.numeric(strptime(as.character(f$date), format="%Y%m%d%H", tz="UTC"))
    }else if(f$date[1] > 1e11 & f$date[1] < 1e12)
    {
      date = as.numeric(strptime(as.character(f$date), format="%Y%m%d%H%M", tz="UTC"))
    }else{
      print("date not in format yyyymmdd, yyyymmddhh or yyyymmddhhmm")
    }
  }
  # add t=-1 (necessary as starting point for cumulative functions)
  d_initial = date[1] - (date[2]-date[1]) *dt
  d_end     = date[nrow(f)] + (date[nrow(f)]-date[nrow(f)-1]) *dt
  date      = c(d_initial, date, d_end)
  # make functions from forcing time series
  func_P      <<- cmpfun(approxfun(date, cumsum(c(0,0,f$P     )), rule=2))
  func_ETpot  <<- cmpfun(approxfun(date, cumsum(c(0,0,f$ETpot )), rule=2))
  func_Qobs   <<- cmpfun(approxfun(date, cumsum(c(0,0,f$Q     )), rule=2))
  func_fXG    <<- cmpfun(approxfun(date, cumsum(c(0,0,f$fXG   )), rule=2))
  func_fXS    <<- cmpfun(approxfun(date, cumsum(c(0,0,f$fXS   )), rule=2))
  func_hSmin  <<- cmpfun(approxfun(date, c(f$hSmin[1],f$hSmin,f$hSmin[nrow(f)]), rule=2))
  func_dGobs  <<- cmpfun(approxfun(date, c(f$dG   [1],f$dG   ,f$hSmin[nrow(f)]), rule=2))
  
  # write date as global varaible
  forcing_date     <<- date

  # make output date vector and belonging function
  nr               =   floor((length(forcing_date)-1)/dt)
  idx              =   c(1,seq(2,((nr*dt+1)),dt))
  output_date      <<- forcing_date[idx]
  warming_up_idx   <<- which(output_date >= (output_date[2] + f$warm[1]*3600))[1] -1 # so 1 if no warming up period
  
}