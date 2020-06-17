function [barobs, barcont] = ht2info(T2, T2mat, limt2, iobs)
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
% Information about Hotelling's T^2_A (T^2) for an observation, i.e.:
% information about the Mahalanobis distance of the observation on the PCA 
% model.
%
% INPUTS
%
% T2: double vector with values of the T^2 statistic.
% T2mat: double matrix with the contributions of each variable (columns) 
%   for each observation (rows) to the T^2.
% limt2: double with the value of the T^2 Upper Control Limit 
%   (with confidence level (1-alpha)*100 %).
% iobs: integer with the index of the observation of interest.
%
% OUTPUTS
%
% barobs: axis of the bar plot with the T^2 value.
% barcont: axis of the bar plot with the contributions to the T^2.
arguments
    T2 double
    T2mat double
    limt2 (1,1) double
    iobs (1,1) {mustBeInteger, mustBeInRangeLength(iobs, T2)}
end
% Bar with value
subplot('Position', [0.1, 0.2, 0.2, 0.7])
barobs = barwithucl(T2, iobs, limt2, 'title', '\fontsize{9}Hotelling-{\itT^2}', ...
            'xlabel', '\fontsize{9}Obs.Index', 'ylabel', '{\it T^2_i}');
% Contribution 
subplot('Position', [0.4, 0.2, 0.5, 0.7])
barcont = custombar(T2mat, iobs, 'title', '\fontsize{9}Contributions to {\itT^2_A}', ...
            'xlabel', '\fontsize{9}PCs');
barcont.YLim(1) = 0;
% Set figure dimensions
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
