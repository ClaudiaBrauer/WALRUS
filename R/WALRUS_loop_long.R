
##   The Wageningen Lowland Runoff Simulator (WALRUS): 
##   a lumped rainfall-runoff model for catchments with shallow groundwater
##   
##   Copyright (C) 2015 Claudia Brauer
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

#' Use this function instead of \code{WALRUS_loop} when using very long time series.
#' Divides the time series in chunks, calls \code{WALRUS_loop} and pasts output together.
#' @description One of the main WALRUS-functions. Computes initial values and provides the for-loop with flexible time step.
#' @param pars the parameter set used for the run.
#' @param chunk_size the maximum number of time steps to run in one go (default 200,000).
#' @param show_progress whether the progress should be printed to screen (default false).
#' @param name character string with a name for the temporary file
#' @return a data frame with the model output for all output time steps.
#' @export WALRUS_loop_long
#' @examples
#' x=1
#' 
WALRUS_loop_long = function(pars, chunk_size=1e4, show_progress=FALSE, name="")
  {

  # Save output_date with different name
  output_date_all <<- output_date
  
  # write table
  o = data.frame(matrix(nrow=0, ncol=10, dimnames=list(NULL, 
                 c("ETact","Q","fGS","fQS","dV","dVeq","dG","hQ","hS","W"))))
  options(scipen=999)                              # to suppress e-4 notation in data files
  filename = paste0("output/output_temp_",name,".dat")
  write.table(o, filename, row.names=FALSE) 
  
  # Run WALRUS in chunks
  nr_chunks       = ceiling(length(output_date_all) / chunk_size)
  last_chunk_size = length(output_date_all) - (nr_chunks-1) * chunk_size
  
  if(nr_chunks>1)
  {
    for(chunk_nr in 1:(nr_chunks-1))
    {
      if(show_progress==TRUE) {print(paste0(round(chunk_nr/nr_chunks*100),"%"))}
      
      # Select part of the output
      if(chunk_nr==1){
        output_date <<- output_date_all[((chunk_nr-1)*chunk_size+1):(chunk_nr*chunk_size)]
      }else{
        output_date <<- output_date_all[((chunk_nr-1)*chunk_size):(chunk_nr*chunk_size)]
      }
      
      # Run WALRUS
      mod = WALRUS_loop(pars=pars)
      
      # Save output
      if(chunk_nr != 1){mod = mod[2:(chunk_size+1),]}
      write(t(as.matrix(mod[,1:10])), file=filename, ncolumns=10, append=TRUE)
      
      # Add last states to parameter files for first state
      pars$dV0 = mod$dV[chunk_size]
      pars$dG0 = mod$dG[chunk_size]
      pars$hQ0 = mod$hQ[chunk_size]
      pars$hS0 = mod$hS[chunk_size]
      
      # remove mod from memory
      rm(mod)
    }
  }
  
  # Same for last  chunk
  if(show_progress==TRUE) {print("100%")}
  if(nr_chunks>1){output_date <<- output_date_all[(chunk_nr*chunk_size):(chunk_nr*chunk_size+last_chunk_size)]}
  mod = WALRUS_loop(pars=pars)
  if(nr_chunks == 1){
    mod = mod[1:last_chunk_size,]
  }else{
    mod = mod[2:(last_chunk_size+1),]
  }
  
  # Retrieve whole output_date for postprocessing
  output_date <<- output_date_all
  
  write(t(as.matrix(mod[,1:10])), file=filename, ncolumns=10, append=TRUE)
  rm(mod)
  
  # return complete data frame
  return(read.table(filename, header=TRUE))

}
