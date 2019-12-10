#!/bin/bash

singularity run \
--cleanenv \
--home `pwd`/INPUTS \
--bind INPUTS:/INPUTS \
--bind OUTPUTS:/OUTPUTS \
mavoltl-v1.0.0.simg \
assr_label TESTPROJ-x-TESTSUBJ-x-TESTSESS-x-TESTSCAN-x-Temporal_Lobe_v3 \
seg_niigz /INPUTS/T1_seg.nii.gz \
vol_txt /INPUTS/T1_label_volumes.txt \
out_dir /OUTPUTS
