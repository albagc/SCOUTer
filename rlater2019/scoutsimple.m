function [outscout, SPE_0, T2_0] = scoutsimple(X, pcamodel, T2target, SPEtarget)
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
% Performs simple SCOUTing on the observations of X according to the 
% provided input parameters.
%
% INPUTS
%
% X: data matrix with observations to be displayed in the distance plot.
% pcamodel: struct with the information of the PCA model.
% T2target: Hotelling's T^2 target value for each observation in X.
% SPEtarget: SPE target value for each observation in X.
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

arguments
    X double
    pcamodel struct
    T2target
    SPEtarget
end
pcaout = pcame(X, pcamodel);
T2_0 = pcaout.T2;
SPE_0 = pcaout.SPE;
P = pcamodel.P;
% When the target value is not specified, the target value will be the
% initial value of the statistic (it will not be changed)
if strcmp(T2target,'none')
    T2target = T2_0;
end
if strcmp(SPEtarget,'none')
    SPEtarget = SPE_0;
end

Xaux = pcaout.Xpreprocessed;
a = sqrt(T2target./ T2_0) - 1;
b = sqrt(SPEtarget ./ SPE_0) - 1;
Xout = xshift(Xaux, P, a, b);

if strcmp(pcamodel.prepro, 'cent')
    Xout = Xout + pcamodel.m;
elseif strcmp(praref.prepro, 'autosc')
    Xout = (Xout .* repmat(pcamodel.s, size(Xout, 1), 1)) + pcamodel.m;
end

outscout.X = Xout;
outscout.SPE = SPEtarget;
outscout.T2 = T2target;
outscout.tag = ones(size(Xout,1),1);
outscout.step_spe = ones(size(Xout,1),1);
outscout.step_t2 = ones(size(Xout,1),1);
end