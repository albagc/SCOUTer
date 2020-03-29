function [Xout, T2X, SPEX] = scout(X, pcamodel, T2target, SPEtarget)
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
%
% OUTPUTS
%
% Xout: matrix with the shifted observations from X presenting SPE and T2
%   specified target values.
% T2X: column vector with the initial T^2 values of the observations in X.
% SPEX: column vector with the initial SPE values of the observations in X.
%% Project observations on the PCA model
if strcmp(pcamodel.prepro, 'cent')
    Xaux = X - pcamodel.m;
elseif strcmp(pcamodel.prepro, 'autosc')
    Xaux = (X - pcamodel.m) ./ repmat(pcamodel.s, size(X, 1), 1);
end
p = size(Xaux, 2);
Xout = [];
P = pcamodel.P;
I = eye(p);
T1 = Xaux * P;
E = Xaux - T1 * P';
SPEX = sum(E .^ 2, 2);
T2X = sum(T1 .^ 2 ./ pcamodel.lambda, 2);
if strcmp(T2target,'none')
    T2target = T2X;
end
if strcmp(SPEtarget,'none')
    SPEtarget = SPEX;
end
% Calculate shift factors and shift observations 
a = sqrt(T2target ./ T2X) - 1;
b = sqrt(SPEtarget ./ SPEX) - 1;
for ni = 1:size(Xaux, 1)
    x1 = Xaux(ni, :);
    x2 = (x1 * (I + b(ni) * (I - (P * P'))) * (I + a(ni) * (P * P')));
    Xout = [Xout; x2];
end
if strcmp(pcamodel.prepro, 'cent')
    Xout = Xout + pcamodel.m;
elseif strcmp(pcamodel.prepro, 'autosc')
    Xout = (Xout .* repmat(pcamodel.s, size(Xout, 1), 1)) + pcamodel.m;
end
end