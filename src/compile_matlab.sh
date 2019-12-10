#!/bin/bash

# Compile
/usr/local/MATLAB/R2019b/bin/matlab -nodisplay -nosplash -nodesktop -r "compile_matlab; exit"

# Set world execute permissions on executables for singularity
chmod +rx ../bin/mavoltl
chmod +rx ../bin/run_mavoltl.sh

