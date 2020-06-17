function [barobs, barcont] = speinfo(SPE, E, limspe, iobs)
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
% Information about Squared Prediction Error (SPE) for an observation, i.e.:
% information about the distance of the observation to the the PCA model 
% hyperplane:
% - Bar plot indicating the value of the statistic for the observation, 
% referenced by the Upper Control Limit. 
% - Bar plot with the contribution that each variable had for the SPE
% of the selected observation (i.e. its error vector).
%
% INPUTS
%
% SPE: A vector with values of the SPE statistic.
% E: A matrix with the contributions of each variable (columns) for each 
%   observation (rows) to the SPE. It is the error term obtained from the 
%   unexplained part of X by the PCA model.
% limspe: A number with the value of the Upper Control Limit for the SPE (at a certain confidence level (1-alpha)*100 %).
% iobs: Integer with the index of the observation of interest.
% speplots: ggplot object with the generated bar plots.

subplot('Position', [0.1, 0.2, 0.2, 0.7])
barobs = barwithucl(SPE, iobs, limspe, '{\it SPE}', ...
    '\fontsize{9}Obs.Index', '{\it SPE_i}');
% Contribution to SPE (error)
subplot('Position', [0.4, 0.2, 0.5, 0.7])
barcont = custombar(E, iobs, 'Contributions to {\it SPE}', ...
    '\fontsize{9}Variables');
fig = gcf;
fig.Units = 'Normalized';
fig.Position(3) = 0.4;
fig.Position(4) = 0.3;
end
