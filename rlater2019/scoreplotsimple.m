function scoreplotsimple(T, pcx, pcy, obstag, alpha, varT)
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
% Returns the score plot.
%
% INPUTS
%
% T: data matrix with the scores to be displayed in the score plot.
% pcx (optional): integer indicating the PC in the horizontal axis. Default
%   value set to 1.
% pcy (optional): integer indicating the PC in the vertical axis. Default
%   value set to 2.
% obstag (optional): double vector indicating the tag (0 for reference and
%   1 for new) of the observations. Default set to zeros(size(T2));
% alpha (optional): double input with the Type I error assumed for the
%   UCLs. Default set to 0.05.
% varT (optional): vector with the variances of the scores of the PCA
%   model. Default set to var(T).
%
% OUTPUTS
%
% (none)  
arguments
    T double
    pcx double = 1;
    pcy double = 2;
    obstag double = zeros(size(T, 1), 1);
    alpha double = 0.05;
    varT double = var(T);
end
% Calculate the scores according to the PCA model in pcamodel struct
t1 = T(:, pcx);
t2 = T(:, pcy);
n = size(t1,1);
% Limits for scores
z = ((n - 1) * (n - 1) / n) * betainv(1 - alpha, 1, (n - 3) / 2);
limits_t = sqrt(varT([pcx, pcy]) * z);
    
% Confidence ellipse (x,y)
a = limits_t(1); % horizontal radius
b = limits_t(2); % vertical radius
t = -pi:0.01:pi;
x = a * cos(t);
y = b * sin(t);

tmin1 = min([t1; - limits_t(1)]) * 1.1;
tmax1 = max([t1; limits_t(1)]) * 1.1;
tlim1 = max(abs([tmin1, tmax1]));
tmin2 = min([t2; - limits_t(2)]) * 1.1;
tmax2 = max([t2; limits_t(2)]) * 1.1;
tlim2 = max(abs([tmin2, tmax2]));
tmaxall = max([tlim1, tlim2]);

markserie = {'o', '^'};
nameserie = {'Obs.ref', 'Obs.new'};
userie = unique(obstag);
colserie = [repmat({'b'}, 1, sum(userie == 0)), repmat({'r'}, 1, ...
    sum(userie > 0))];

conflev = (1 - alpha) * 100;
% Horizontal and vertical axis
plot(linspace(-tmaxall, tmaxall, 100), zeros(100, 1), 'k', ...
    'linewidth', 0.75, 'HandleVisibility', 'off');
hold on
plot(zeros(100, 1), linspace(-tmaxall, tmaxall, 100), 'k', ...
    'linewidth', 0.75, 'HandleVisibility', 'off');
% Scores
for i = 1:length(userie)
    scatter(t1(obstag==userie(i),:), t2(obstag==userie(i),:), 25, ...
        'Marker', markserie{i}, 'MarkerFaceColor', colserie{i}, ...
        'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'none', ...
        'DisplayName', nameserie{i});
end
annotation('textbox', [0.12, 0.92, 0.2, 0.05], 'String', ...
        strcat('Conf.Ellipse_{', string(conflev), '%}'), ...
        'BackgroundColor', 'none', 'EdgeColor', 'none', ...
        'HorizontalAlignment', 'left', 'FontSize', 7)
xticks(-floor(tmaxall):round(2*tmaxall/10):floor(tmaxall));
yticks(-floor(tmaxall):round(2*tmaxall/10):floor(tmaxall));
grid on,
plot(x, y, 'r--', 'linewidth', 1.05, 'HandleVisibility', 'off');
xlim([-tmaxall, tmaxall]), ylim([-tmaxall, tmaxall])
xlabel(strcat('{\it t_{', string(pcx), '}}'))
ylabel(strcat('{\it t_{', string(pcy), '}}'))
legend('FontSize', 10, 'box', 'off', ...
    'NumColumns', 1, 'Position', [0 0.42 1 0.05])
title('Score plot', 'FontSize', 11)
end