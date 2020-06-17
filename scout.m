function [outscout, SPE_0, T2_0] = scout(X, pcamodel, mode, varargin)
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
%
% INPUTS
%
% X: data matrix with observations to be displayed in the distance plot.
% pcamodel: struct with the information of the PCA model.
% mode: string with procedure to generate steps. 
% T2y: Hotelling's T^2 target value for each observation in X.
% SPEy: SPE target value for each observation in X.
% nsteps (optional): integer with number of steps for the SPE and the T2.
% nstepsspe (optional): integer with number of steps for the SPE.
% nstepst2 (optional): integer with number of steps for the T2.
% gt2 (optional): number with T2's speed parameter.
% gspe (optional): number with SPE's speed parameter.
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
%
narginchk(3, 17)
options = struct('nsteps', 1, 't2y', 'none', 'spey', 'none', ...
    'nstepsspe', 1, 'nstepst2', 1, 'gspe', 1, 'gt2', 1);
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
T2target = options.t2y;
SPEtarget = options.spey;
nsteps = options.nsteps;
nstepsspe = options.nstepsspe;
nstepst2 = options.nstepst2;
gspe = options.gspe;
gt2 = options.gt2;

switch mode
    case 'simple'
        [outscout, SPE_0, T2_0] = scoutsimple(X, pcamodel, T2target, SPEtarget);
    case 'steps'
        [outscout, SPE_0, T2_0] = scoutsteps(X, pcamodel, T2target, SPEtarget, nsteps, gspe, gt2);
    case 'grid'
        [outscout, SPE_0, T2_0] = scoutgrid(X, pcamodel, T2target, SPEtarget, nstepsspe, nstepst2, gspe, gt2);  
end

end