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
%
% INPUTS
%
% X: data matrix with observations to be displayed in the distance plot.
% pcamodel: struct with the information of the PCA model.
% obstag (optional): column vector of integers indicating the group of each
%   observation. Default value set to zeros(size(X,1),1).
% inter (optional): string indicating the status of the plot interactivity.
%   Default value set to 'on'.
% scoreopt (optional): struct indicating the PCs whose scores will be
%   used in the score plot. Default values are scoreopt.pc1 = 1 and
%   scoreopt.pc2 = 2;
%
% OUTPUTS
%
% Figure with distance plot.
arguments
    T2 double
    SPE double
    limt2 double
    limspe double
    alpha double = 0.05;
    obstag double = zeros(size(T2));
end
%% Calculate the scores according to the PCA model in pcamodel struct
n = length(T2);

a = 1.25 * max([T2; limt2]);
b = 1.25 * max([SPE; limspe]);
conflev = (1 - alpha) * 100;

% Upper Control Limits
plot(linspace(0, a, 100), limspe * ones(100, 1), 'r--', 'linewidth', ...
    1.2, 'HandleVisibility', 'off');
hold on
plot(limt2 * ones(100, 1), linspace(0, b, 100), 'r--', 'linewidth', ...
    1.2, 'HandleVisibility', 'off');

% Distance plot
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