### Change Q-h-relation

# Build a function in which the discharge is computed as a function of stage height.
func_Q_hS_example = function(x, pars, hSmin)
{
  if(x <= 0)
  {
    0
  }else if(x < 200)
  {
    0.55* 10 ^(0.16 + 2.01 * log10(x/1000) + 0.13 * log10(x/1000)^2)
  }else{
    0.55* 10 ^(0.27 + 2.32 * log10(x/1000) + 0.35 * log10(x/1000)^2)
  }
}

# Then set this function as the current stage-discharge relation.
set_func_Q_hS(func_Q_hS_example)

# And to check if you did it right:
show_func_Q_hS()

# To check the value for a specific stage height manually:
func_Q_hS_example(x=1000)

# To plot the stage-discharge relation
hS = c(1:2000)
Q  = c()
for(i in 1:length(hS)){Q[i] = func_Q_hS_example(hS[i])}
plot(hS, Q, type="l", col="dodgerblue")
