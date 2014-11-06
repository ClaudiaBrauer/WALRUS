
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


##########################
# FUNCTION SELECT_dates
##########################   

# This function cuts out the part of the dataset between the start- and end date.
# Call the function with the name of the dataset and values for "start" and "end"
# of the period you want to evaluate.
# Note that the format for start and end differs for daily and hourly data:
# for hourly data:  format: yyyymmddhh
# for daily data:   format: yyyymmdd

#' Select dates from a forcing data frame.
#' @description Select a shorter period from a forcing data frame.
#' @param dataframe a dataframe with date in YYYYmmddhh or YYYmmdd format and columns with P, ETpot, Q (at least one value), fXG (optional), fXS (optional), GWL (optional)
#' @param start start of the simulation perio (in YYYYmmddhh or YYYmmdd format)
#' @param end end of the simulation perio (in YYYYmmddhh or YYYmmdd format)
#' @return a shorter data frame of the \code{dataframe} input
#' @export WALRUS_selectdates
#' @examples
#' x=1
#' 
WALRUS_selectdates = function(dataframe, start, end)
{  
  get(dataframe)[get(dataframe)$date >= start & get(dataframe)$date <= end ,]
}



