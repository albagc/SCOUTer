function obscontribpanel(pcaout, limspe, limt2, iobs)
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
% Information about Squared Prediction Error and Hotelling's T^2_A (T^2)
% for an observation, i.e.:
% information about the Mahalanobis distance of the observation on the PCA
% model.
%
% INPUTS
%
% pcaout: struct containing the following fields:
%   - SPE: double vector with values of the SPE statistic.
%   - E: double matrix with the contributions of each variable (columns)
%   for each observation (rows) to the SPE.
%   - T2: double vector with values of the T^2 statistic.
%   - T2cont: double matrix with the contributions of each variable (columns)
%   for each observation (rows) to the T^2.
% limspe: double with the value of the SPE Upper Control Limit
%   (with confidence level (1-alpha)*100 %).
% limt2: double with the value of the T^2 Upper Control Limit
%   (with confidence level (1-alpha)*100 %).
% iobs: integer with the index of the observation of interest.
%
% OUTPUTS
%
% barobs: axis of the bar plot with the T^2 value.
% barcont: axis of the bar plot with the contributions to the T^2.
arguments
    pcaout struct
    limspe (1,1) double
    limt2 (1,1) double
    iobs (1,1) {mustBeInteger}
end
SPE = pcaout.SPE;
E = pcaout.E;
T2 = pcaout.T2;
T2mat = pcaout.T2cont;
% Value of SPE
subplot(2, 3, 1),
barwithucl(SPE, iobs, limspe, 'title','{\it SPE}', ...
    'xlabel','\fontsize{8}Obs.Index', 'ylabel', '{\it SPE_i}');

% Contribution to SPE (error)
subplot(2, 3, [2,3]),
custombar(E, iobs, 'title', 'Contributions to {\it SPE}', ...
    'xlabel', '\fontsize{9}Variables');

% Value of Hotelling's T^2
subplot(2, 3, 4),
barwithucl(T2, iobs, limt2, 'title', 'Hotelling-{\itT^2}', ...
    'xlabel', '\fontsize{8}Obs.Index', 'ylabel', '{\it T^2_i}');

% Contribution to Hotelling's T2
subplot(2, 3, [5,6]),
ct2 = custombar(T2mat, iobs, 'title', 'Contributions to {\itT^2_A}', ...
    'xlabel', '\fontsize{9}PCs');
ct2.YLim(1) = 0;

end
% Custom validation function
function mustBeInRangeLength(arg,b)
if (arg < 1) || (arg > length(b))
    error(['Value assigned to Data is not in range ',...
        num2str(1),'...',num2str(length(b))])
end
end
