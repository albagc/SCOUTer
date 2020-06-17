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
% information about the distance of the observation to the PCA model 
% model.
%
% INPUTS
%
% SPE: double vector with values of the SPE statistic.
% E: double matrix with the contributions of each variable (columns) 
%   for each observation (rows) to the SPE.
% limspe: double with the value of the SPE Upper Control Limit 
%   (with confidence level (1-alpha)*100 %).
% iobs: integer with the index of the observation of interest.
%
% OUTPUTS
%
% barobs: axis of the bar plot with the SPE value.
% barcont: axis of the bar plot with the contributions to the SPE.
arguments
    SPE double
    E double
    limspe (1,1) double
    iobs (1,1) {mustBeInteger, mustBeInRangeLength(iobs, SPE)}
end
subplot('Position', [0.1, 0.2, 0.2, 0.7])
barobs = barwithucl(SPE, iobs, limspe, 'title', '{\it SPE}', ...
    'xlabel', '\fontsize{9}Obs.Index', 'ylabel', '{\it SPE_i}');
% Contribution to SPE (error)
subplot('Position', [0.4, 0.2, 0.5, 0.7])
barcont = custombar(E, iobs, 'title', 'Contributions to {\it SPE}', ...
    'xlabel', '\fontsize{9}Variables');
fig = gcf;
fig.Units = 'Normalized';
fig.Position(3) = 0.4;
fig.Position(4) = 0.3;
end
% Custom validation function
function mustBeInRangeLength(arg,b)
    if (arg < 1) || (arg > length(b))
        error(['Value assigned to Data is not in range ',...
            num2str(1),'...',num2str(length(b))])
    end
end