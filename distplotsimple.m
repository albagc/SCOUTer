function distplotsimple(T2, SPE, limt2, limspe, alpha , obstag)
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
% Returns the distance plot.
%
% INPUTS
%
% T2: double input with the Hotelling's T^2 (T^2) statistic vector.
% SPE: double input with the Squared Prediction Error (SPE) vector.
% limt2: double input with the Upper Control Limit of the T^2.
% limspe: double input with the Upper Control Limit of the SPE.
% alpha (optional): input with the Type I error assumed for the
%   UCLs. Default set to 0.05.
% obstag (optional): double vector indicating the tag (0 for reference and
%   1 for new) of the observations. Default set to zeros(size(T2));
%
% OUTPUTS
%
% (none)
arguments
    T2 double
    SPE double
    limt2 double
    limspe double
    alpha double = 0.05;
    obstag double = zeros(size(T2));
end
% Set axis limits
a = 1.25 * max([T2; limt2]);
b = 1.25 * max([SPE; limspe]);
conflev = (1 - alpha) * 100;

% Plot UCLs
plot(linspace(0, a, 100), limspe * ones(100, 1), 'r--', 'linewidth', ...
    1.2, 'HandleVisibility', 'off');
hold on
plot(limt2 * ones(100, 1), linspace(0, b, 100), 'r--', 'linewidth', ...
    1.2, 'HandleVisibility', 'off');

% Plot observations
markserie = {'o', '^'};
nameserie = {'Obs.ref', 'Obs.new'};
userie = unique(obstag);
colserie = [repmat({'b'}, 1, sum(userie == 0)), repmat({'r'}, 1, ...
    sum(userie > 0))];

for i = 1:length(userie)
    scatter(T2(obstag == userie(i),:), SPE(obstag == userie(i),:), 25, ...
        'Marker', markserie{i}, 'MarkerFaceColor', colserie{i}, ...
        'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'none', ...
        'DisplayName', nameserie{i});
end
annotation('textbox', [0.12, 0.92, 0.2, 0.06], 'String', ...
        strcat('UCL_{', string(conflev), '%}'), ...
        'BackgroundColor', 'none', 'EdgeColor', 'none', ...
        'HorizontalAlignment', 'left', 'FontSize', 7)
xlim([0, a]), ylim([0, b]),
grid on, 
xlabel('{\it T^2}'), 
ylabel('{\it SPE}'), 
title('Distance plot', 'FontSize', 11)
end