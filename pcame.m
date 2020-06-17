function [pcaout] = pcame(X, pcamodel)
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
% X: NxM matrix with observations to be displayed in the distance plot.
% pcamodel: struct with the information of the PCA model.
%
% OUTPUTS
%
% pcaout: struct with fields containing the information from the
%   observations in X in terms of the PCA model of pcamodel. With fields:
%   - T: Scores matrix of dimensions NxK where K is the number of PCs.
%   - E: Error matrix of dimensions NxM.
%   - Xhat: Prediction of X with the PCA model, same dimensions of X (NxM).
%   - SPE: Squared Prediction Error vector.
%   - T2: Hotelling's T^2 vector.
%   - T2cont: Contributions for each observation and PC to the T^2.
%% Calculate distances according to the PCA model in pcamodel struct
n = size(X,1);
switch pcamodel.prepro
    case 'cent'
        Xaux = X - pcamodel.m;
    case 'autosc'
        Xaux = (X - pcamodel.m) ./ repmat(pcamodel.s, n, 1);
    case 'none'
        Xaux = X;
end
T = Xaux * pcamodel.P;
P = pcamodel.P;
E = Xaux - T * P';
SPE = sum(E .^ 2, 2);
T2 = sum(T .^ 2 ./ pcamodel.lambda, 2);
T2matrix = T(:, 1:pcamodel.ncomp) .^2 ./ repmat(pcamodel.lambda, n, 1);
% Output struct
pcaout.Xpreprocessed = Xaux;
pcaout.T = T;
pcaout.E = E;
pcaout.SPE = SPE;
pcaout.T2 = T2;
pcaout.T2cont = T2matrix;
end