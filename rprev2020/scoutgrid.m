function [outscout, SPE_0, T2_0] = scoutgrid(X, pcamodel, T2target, SPEtarget, nstepsspe, nstepst2, gspe, gt2)
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
% Performs grid-wise SCOUTing on the observations of X according to the 
% provided input parameters.
%
% INPUTS
%
% X: matrix with observations to be shifted as row-vectors.
% pcamodel: struct with the information of the PCA model.
% T2target: Hotelling's T^2 target value for each observation in X.
% SPEtarget: SPE target value for each observation in X.
% nstepsspe: integer indicating the number of steps from SPE_x to SPE_y.
%   Default set to 1.
% nstepst2: integer indicating the number of steps from T^2_x to T^2_y.
%   Default set to 1.
% gspe: number with SPE speed parameter. Default set to 1.
% gt2: number with T2's speed parameter. Default set to 1.
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
%   - T2: column vector with the T^2 values of the observations in X.
%   - SPE: column vector with the SPE values of the observations in X.
%   - tag: column vector indicating if the observation belongs to the
%   reference data set (0) or to the new generated nada (1).
%   - step_spe: column vector indicating the step between SPE0 and SPEM.
%   - step_t2: column vector indicating the step between T20 and T2M.
% SPE_0: vector with the initial SPE values.
% T2_0: vector with the initial Hotelling's T^2 values.
narginchk(6,8)
switch nargin
    case 6
        gspe = 1;
        gt2 = 1;
    case 7
        gt2 = 1;
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
factor_spe = diag(([1:nstepsspe]/nstepsspe).^gspe);
factor_t2 = diag(([1:nstepst2]/nstepst2).^gt2);
difmat_spe = repmat(SPEtarget - SPE_0, 1, nstepsspe);
difmat_t2 = repmat(T2target - T2_0, 1, nstepst2);
steps_spe = SPE_0 + difmat_spe * factor_spe;
steps_t2 = T2_0 + difmat_t2 * factor_t2;

Xout = [];
for k = 1:size(steps_spe, 2)
    spe_step = steps_spe(:, k);
    b = sqrt(spe_step ./ SPE_0) - 1;
    for k2 = 1:size(steps_t2, 2)
        t2_step = steps_t2(:, k2);
        a = sqrt(t2_step ./ T2_0) - 1;
        Xstep2 = xshift(Xaux, P, a, b);
        Xout = vertcat(Xout, Xstep2);
    end
end

xi_t2 = repmat(reshape(steps_t2, n*k2, 1), k, 1);
xi_step_t2 = repmat(reshape(repmat(1:k2, n, 1), n*k2, 1), k, 1);
xi_spe = reshape(repmat(steps_spe, k2, 1), n*k2*k, 1);
xi_step_spe = reshape(repmat(1:k, n*k2, 1), n*k2*k, 1);

if strcmp(pcamodel.prepro, 'cent')
    Xout = Xout + pcamodel.m;
elseif strcmp(praref.prepro, 'autosc')
    Xout = (Xout .* repmat(pcamodel.s, size(Xout, 1), 1)) + pcamodel.m;
end
outscout.X = Xout;
outscout.SPE = xi_spe;
outscout.T2 = xi_t2;
outscout.step_spe = xi_step_spe;
outscout.step_t2 = xi_step_t2;
outscout.tag = ones(size(Xout, 1), 1);
end