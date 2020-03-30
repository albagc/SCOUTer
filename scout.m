function [outscout, SPE_0, T2_0] = scout(X, pcamodel, T2_M, SPE_M, varargin)
% Statistically Controlled OUTliERs
% A. González Cebrián, A. Folch-Fortuny, F. Arteaga and A. Ferrer
% Copyright (C) 2020 A. González Cebrián and F. Arteaga
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
%
% INPUTS
%
% X: data matrix with observations to be displayed in the distance plot.
% pcamodel: struct with the information of the PCA model.
% T2target: Hotelling's T^2 target value for each observation in X.
% SPEtarget: SPE target value for each observation in X.
% optional Name-Value pair arguments:
%   - mode: 'step' for simultaneous increment in SPE and T2, or 'grid' to
%   generate datasets with all the combinations of SPEm and T2m. Default
%   set to 'step'.
%   - nsteps: integer indicating the number of steps from SPE_0 to SPE_M 
%   (or T^2). Default set to 1. 
%   - gspe: gamma value tunning the linearity of the steps from SPE_0 to
%   SPE_M. Default set to 1.
%   - gt2: gamma value tunning the linearity of the steps from T20 to
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
%   - T2: column vector with the T^2 values of the observations in X.
%   - SPE: column vector with the SPE values of the observations in X.
%   if mode = 'steps'
%       - step: column vector with the intermediate step between {SPE,T2}0 and
%           {SPE, T2}M.
%   if mode = 'grid'
%       - step_spe: column vector indicating the step between SPE0 and SPEM.
%       - step_t2: column vector indicating the step between T20 and T2M.
% SPE_0: vector with the initial SPE values.
% T2_0: vector with the initial Hotelling's T^2 values.
%% Check inputs
narginchk(4,12)
options = struct('mode', 'steps', 'nsteps', 1, 'gspe', 1, 'gt2', 1);
optionNames = fieldnames(options);
if round(length(varargin)/2)~=length(varargin)/2 % Check pairs
    error('Each Name argument needs a value pair argument')
end
for pair = reshape(varargin,2,[])
    inName = lower(pair{1});
    if any(strcmp(inName,optionNames))
        options.(inName) = pair{2};
    else
        error('The %s input is not recognized by this function',inName)
    end
end
mode = options.mode;
nsteps = options.nsteps;
gspe = options.gspe;
gt2 = options.gt2;
%%
if strcmp(pcamodel.prepro, 'cent')
    Xaux = X - pcamodel.m;
elseif strcmp(pcamodel.prepro, 'autosc')
    Xaux = (X - pcamodel.m) ./ repmat(pcamodel.s, size(X, 1), 1);
end
n = size(X,1);
p = size(Xaux, 2);
Xout = [];
P = pcamodel.P;
I = eye(p);
T = Xaux * P;
E = Xaux - T * P';
SPE_0 = sum(E .^ 2, 2);
T2_0 = sum(T .^ 2 ./ pcamodel.lambda, 2);
% When the target value is not specified, the target value will be the
% initial value of the statistic (it will not be changed)
if strcmp(T2_M,'none')
    T2_M = T2_0;
end
if strcmp(SPE_M,'none')
    SPE_M = SPE_0;
end
factor_spe = diag(([1:nsteps]/nsteps).^gspe);
factor_t2 = diag(([1:nsteps]/nsteps).^gt2);
difmat_spe = repmat(SPE_M - SPE_0, 1, nsteps);
difmat_t2 = repmat(T2_M - T2_0, 1, nsteps);
steps_spe = SPE_0 + difmat_spe * factor_spe;
steps_t2 = T2_0 + difmat_t2 * factor_t2;
switch mode
    case 'steps'
        xi_step = [];
        for k = 1:size(steps_spe,2)
            spe_step = steps_spe(:, k);
            t2_step = steps_t2(:, k);
            a = sqrt(t2_step ./ T2_0) - 1;
            b = sqrt(spe_step ./ SPE_0) - 1;
            for ni = 1:size(Xaux, 1)
                x1 = Xaux(ni, :);
                x2 = (x1 * (I + b(ni) * (I - (P * P'))) * (I + a(ni) * (P * P')));
                Xout = [Xout; x2];
            end
            xi_step = [xi_step; k*ones(ni,1)];
        end
        if strcmp(pcamodel.prepro, 'cent')
            Xout = Xout + pcamodel.m;
        elseif strcmp(praref.prepro, 'autosc')
            Xout = (Xout .* repmat(pcamodel.s, size(Xout, 1), 1)) + pcamodel.m;
        end
        outscout.X = Xout;
        outscout.SPE = reshape(steps_spe, ni*k, 1);
        outscout.T2 = reshape(steps_t2, ni*k, 1);
        outscout.step = xi_step;
    case 'grid'
        xi_t2 = [];
        xi_spe = [];
        xi_step_spe = [];
        xi_step_t2 = [];
        for k = 1:size(steps_spe, 2)
            spe_step = steps_spe(:, k);
            b = sqrt(spe_step ./ SPE_0) - 1;
            for k2 = 1:size(steps_t2, 2)
                t2_step = steps_t2(:, k2);
                a = sqrt(t2_step ./ T2_0) - 1;
                for ni = 1:size(Xaux, 1)
                    x1 = Xaux(ni, :);
                    x2 = (x1 * (I + b(ni) * (I - (P * P'))) * (I + a(ni) * (P * P')));
                    Xout = [Xout; x2];
                end
                xi_t2 = [xi_t2; t2_step];
                xi_step_t2 = [xi_step_t2; k2*ones(ni,1)];
            end
            xi_spe = [xi_spe; repmat(spe_step, k2, 1)];
            xi_step_spe = [xi_step_spe; k*ones(ni*k2,1)];
        end
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
end
end