% Compile the matlab code so we can run it without a matlab license. To
% create a linux container, we need to compile on a linux machine. That
% means a VM, if we are working on OS X.
%
% We require on our compilation machine:
%     Matlab 2019b, including compiler, with license
%
% The matlab version matters. If we compile with R2019b, it will only run
% under the R2019b Runtime.

mcc -m -C -N -v ...
-p /usr/local/MATLAB/R2019b/toolbox/images ...
-a ../NIfTI_20140122 ...
-a . ...
-d ../bin ...
mavoltl.m
