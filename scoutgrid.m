function [outgrid] = scoutgrid(X, pcamodel, T2_target, SPE_target, nsteps, g)
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
% nsteps: number of steps between the SPE initial and target values.
% g: gamma parameter idicating the velocity at which the increment in the
%   SPE and T^2 is performed.
%
% OUTPUTS
%
% outgrid: struct with output information..
%   X: matrix with the shifted observations from X presenting SPE and T2
%       specified target values.
%   T2: column vector with the T^2 values of the observations in each step.
%   SPE: column vector with the SPE values of the observations in each
%       step.
%   spe_factor: column vector with the SPE values of the observations in
%       step.
%   t2_factor: column vector with the SPE values of the observations in
%       step.
%% Check inputs
if strcmp(pcamodel.prepro, 'cent')
    Xaux = X - pcamodel.m;
elseif strcmp(praref.prepro, 'autosc')
    Xaux = (X - pcamodel.m) ./ repmat(pcamodel.s, size(X, 1), 1);
end
p = size(Xaux, 2);
n = size(Xaux, 1);
Xout = [];
P = pcamodel.P;
I = eye(p);
T1 = Xaux * P;
E = Xaux - T1 * P';
SPE_X = sum(E .^ 2, 2);
T2_X = sum(T1 .^ 2 ./ pcamodel.lambda, 2);

spe0 = repmat(SPE_X, nsteps + 1, 1);
if strcmp(SPE_target,'none')
    speM = spe0;
else
    speM = repmat(SPE_target, nsteps + 1, 1);
end
m_nsteps = reshape(repmat((0:nsteps), n, 1), (nsteps+1)*n, 1);
spesteps = spe0 + (m_nsteps/nsteps).^g.* (speM - spe0);

t20 = repmat(T2_X, nsteps + 1, 1);
if strcmp(T2_target,'none')
    t2M = t20;
else
    t2M = repmat(T2_target, nsteps + 1, 1);
end
t2steps = t20 + (m_nsteps/nsteps).^g.* (t2M - t20);

spefac = [];
t2fac = [];
for k = 1:nsteps+1
    b = sqrt(spesteps(1+n*(k-1):n*(k)) ./ SPE_X) - 1;
    for k2 = 1:nsteps+1
        a = sqrt(t2steps(1+n*(k2-1):n*(k2)) ./ T2_X) - 1;
        for ni = 1:size(Xaux, 1)
            x1 = Xaux(ni, :);
            x2 = (x1 * (I + b(ni) * (I - (P * P'))) * (I + a(ni) * (P * P')));
            Xout = [Xout; x2];
        end
        t2fac = [t2fac; k2*ones(ni,1)-1];
    end
    spefac = [spefac; k*ones(k2*ni,1)-1];  
end
if strcmp(pcamodel.prepro, 'cent')
    Xout = Xout + pcamodel.m;
elseif strcmp(praref.prepro, 'autosc')
    Xout = (Xout .* repmat(pcamodel.s, size(Xout, 1), 1)) + pcamodel.m;
end
outgrid.X = Xout;
outgrid.SPE = spesteps;
outgrid.T2 = t2steps;
outgrid.spe_factor = spefac;
outgrid.t2_factor = t2fac;
end