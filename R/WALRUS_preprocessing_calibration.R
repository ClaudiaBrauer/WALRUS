
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

#' Preprocessing for calibration
#' @description Converts discharge and/or groundwater times series to same time steps as output_steps.
#' @return a data frame with the water budget.
#' @export WALRUS_preprocessing_calibration
#' @examples
#' x=1
#' 
WALRUS_preprocessing_calibration = function()
{
  
  L          =   length(output_date)
  step_start =   output_date[1:(L-1)]
  step_end   =   output_date[2:L    ]
  # the first discharge measurement is duplicated to get an initial value (is also done in the model)
  # the next discharge sums are computed from the difference in cumulative sums
  Qobs_forNS  <<- c(func_Qobs(output_date[2]),(func_Qobs (step_end) - func_Qobs (step_start))) [warming_up_idx:L]
  # groundwater is not cumulative and the first measurement is included in the function (in preprocessing)
  dGobs_forNS <<- func_dGobs (output_date)
  # so these vectors are the same length as the output file
                   
}