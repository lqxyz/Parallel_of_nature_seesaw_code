#!/bin/bash

# Compare the histogram from Matlab and Fortran results
octave hist_MC_MCc.m

# Compare the runtime between Matlab and Fortran (single or multiple cores)
octave MC_time_comparison.m 
