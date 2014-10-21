
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

#' Converts date format.
#' @description Converts YYYmmddHH to seconds since 1970-01-01.
#' @param d date/time combination in date or POSIX-format
#' @return number of seconds since 1970-01-01
#' @export WALRUS_date_conversion
#' @examples
#' x=1
#' 
WALRUS_date_conversion = function(d)
{
  
  d_char = as.character(as.POSIXct(d, origin="1970-01-01", tz="UTC"))
  d_num  = c()
  
  for(i in 1:length(d))
  {
    if(nchar(d_char[i]) == 10)
    {
      d_num[i] = as.numeric(substr(d_char[i],1 ,4 ))*10000000000 +
                 as.numeric(substr(d_char[i],6 ,7 ))*100000000   +
                 as.numeric(substr(d_char[i],9 ,10))*1000000     
    }else{
      d_num[i] = as.numeric(substr(d_char[i],1 ,4 ))*10000000000 +
                 as.numeric(substr(d_char[i],6 ,7 ))*100000000   +
                 as.numeric(substr(d_char[i],9 ,10))*1000000     +
                 as.numeric(substr(d_char[i],12,13))*10000       +
                 as.numeric(substr(d_char[i],15,16))*100         +
                 as.numeric(substr(d_char[i],18,19))
    }
  }
  
  return(d_num)
}