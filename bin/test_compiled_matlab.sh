#!/bin/bash

xvfb-run --server-num=$(($$ + 99)) \
--server-args='-screen 0 1600x1200x24 -ac +extension GLX' \
bash run_mavoltl.sh /usr/local/MATLAB/MATLAB_Runtime/v97 \
assr_label TESTPROJ-x-TESTSUBJ-x-TESTSESS-x-TESTSCAN-x-Temporal_Lobe_v3 \
seg_niigz ../INPUTS/T1_seg.nii.gz \
vol_txt ../INPUTS/T1_label_volumes.txt \
out_dir ../OUTPUTS
