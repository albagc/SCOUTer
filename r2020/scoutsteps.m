function [outscout, SPE_0, T2_0] = scoutsteps(X, pcamodel, T2target, SPEtarget, nsteps, gspe, gt2)
% Statistically Controlled OUTliers
% A. Gonzalez Cebrian, A. Folch-Fortuny, F. Arteaga and A. Ferrer
% Copyright (C) 2020 A. Gonzalez Cebrian, A. Folch-Fortuny and F. Arteaga
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% DESCRIPTION
%
% Performs step-wise SCOUTing on the observations of X according to the 
% provided input parameters.
%
% INPUTS
%
% X: data matrix with observations to be displayed in the distance plot.
% pcamodel: struct with the information of the PCA model.
% T2target: Hotelling's T^2 target value for each observation in X.
% SPEtarget: SPE target value for each observation in X.
% nsteps: integer indicating the number of steps from SPE_0 to SPE_M
%   (or T^2). Default set to 1.
% gspe: gamma value tunning the linearity of the steps from SPE_0 to
%   SPE_M. Default set to 1.
% gt2: gamma value tunning the linearity of the steps from T20 to
%   T2_M. Default set to 1.
%
% OUTPUTS
%
% outscout: struct with fields containing
%   - X: matrix with the shifted observations from X. Structure:
%           obs1 step1
%           obs2 step1
%           ...  step1
%           obsN step1
%           obs1 step2
%           ...  ...
%           obsN stepM
%   - T2: column vector with the T^2 values of the shifted observations.
%   - SPE: column vector with the SPE values of the shifted observations.
%   - tag: column vector indicating if the observation belongs to the
%   reference data set (0) or to the new generated nada (1).
%   - step_spe: column vector indicating the step between SPE_x and SPE_y.
%   - step_t2: column vector indicating the step between T2_x and T2_y.
% SPE_0: vector with the initial SPE values.
% T2_0: vector with the initial Hotelling's T^2 values.

arguments
    X double
    pcamodel struct
    T2target 
    SPEtarget 
    nsteps double {mustBeInteger}
    gspe double = 1
    gt2 double = 1
end

n = size(X, 1);
P = pcamodel.P;
[pcaout] = pcame(X, pcamodel);
Xaux = pcaout.Xpreprocessed;
T2_0 = pcaout.T2;
SPE_0 = pcaout.SPE;
% When the target value is not specified, the target value will be the
% initial value of the statistic (it will not be changed)
if strcmp(T2target,'none')
    T2target = T2_0;
end
if strcmp(SPEtarget,'none')
    SPEtarget = SPE_0;
end
factor_spe = diag(((1:nsteps)/nsteps).^gspe);
factor_t2 = diag(((1:nsteps)/nsteps).^gt2);
steps_spe = SPE_0 + repmat(SPEtarget - SPE_0, 1, nsteps) * factor_spe;
steps_t2 = T2_0 + repmat(T2target - T2_0, 1, nsteps) * factor_t2;
Xout = [];
for k = 1:size(steps_spe,2)
    spe_step = steps_spe(:, k);
    t2_step = steps_t2(:, k);
    a = sqrt(t2_step ./ T2_0) - 1;
    b = sqrt(spe_step ./ SPE_0) - 1;
    Xstep = xshift(Xaux, P, a, b);
    Xout = vertcat(Xout, Xstep);
end
xi_step = reshape(repmat(1:k, n, 1), k*n, 1);
if strcmp(pcamodel.prepro, 'cent')
    Xout = Xout + pcamodel.m;
elseif strcmp(pcamodel.prepro, 'autosc')
    Xout = (Xout .* repmat(pcamodel.s, size(Xout, 1), 1)) + pcamodel.m;
end
outscout.X = Xout;
outscout.SPE = reshape(steps_spe, n*k, 1);
outscout.T2 = reshape(steps_t2, n*k, 1);
outscout.step_spe = xi_step;
outscout.step_t2 = xi_step;
outscout.tag = ones(size(Xout, 1), 1);
end