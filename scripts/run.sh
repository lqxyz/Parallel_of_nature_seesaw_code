#!/bin/bash

# Plot time series of delta O18
octave plotfit_d18o.m

# Plot warm/cool stack figure from different proxies
octave plot_stack_figure.m

# Plot warm window
# matlab -nodisplay < split.m
octave split.m 

# Compare the histogram from Matlab and Fortran results
octave hist_MC_MCc.m

# Compare the runtime between Matlab and Fortran (single or multiple cores)
octave MC_time_comparison.m 

