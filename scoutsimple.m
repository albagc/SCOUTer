function [outscout, SPE_0, T2_0] = scoutsimple(X, pcamodel, T2target, SPEtarget)
% Statistically Controlled OUTliERs
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
% T2target: Hotelling's T^2 target value for each observation in X.
% SPEtarget: SPE target value for each observation in X.
%
% OUTPUTS
%
% Xout: matrix with the shifted observations from X
%
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