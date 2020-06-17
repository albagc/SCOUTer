function scoreplot(X, pcamodel, clicktoggle, pcx, pcy, obstag, steps_spe, steps_t2)
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
% clicktoggle (optional): string indicating the status of the plot interactivity.
%   Default value set to 'on'.
% obstag (optional): vector of integers indicating the group of each
%   observation. Default value set to zeros(size(X,1),1).
% pcx (optional): integer with PC represented in the horizontal axis.
%   Default value set to 1.
% pcy (optional): integer with PC represented in the vertical axis.
%   Default value set to 2.
%
% OUTPUTS
%
% T: matrix with the coordinates of each observation in the score plot.
% ax0: handle with the graphical object containing the score plot.
arguments
    X double
    pcamodel struct
    clicktoggle string = 'on'
    pcx double = 1
    pcy double = 2
    obstag double = zeros(size(X, 1), 1)
    steps_spe double = zeros(size(X, 1), 1);
    steps_t2 double = zeros(size(X, 1), 1);
end
%% Calculate the scores according to the PCA model in pcamodel struct
pcaout = pcame(X, pcamodel);
T = pcaout.T;

if strcmp(clicktoggle, 'on')
    subplot(4, 6, 1:12),
end
scoreplotsimple(T, pcx, pcy, obstag, pcamodel.alpha)
spoint = scatter(0, 0, 25, 'Marker', 'o', ...
    'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'none', ...
    'HandleVisibility', 'off');
ax0 = gca;
t1 = T(:, pcx);
t2 = T(:, pcy);

if strcmp(clicktoggle, 'on')
    legend('FontSize', 10, 'box', 'off', 'NumColumns', 1, ...
        'Position', [0 0.42 1 0.05])
    annotation('textbox', [0.2, 0.35, 0.6, 0.05], 'String', ...
        {'Please click on your observation of interest to display further information'},...
        'FitBoxToText', 'on', 'BackgroundColor', 'w', 'HorizontalAlignment',...
        'center', 'FontSize', 9, 'EdgeColor', 'none')
    set(gcf,'WindowButtonDownFcn', {@mytestcallback, t1, t2, pcaout.E, ...
        pcaout.T2cont, pcaout.SPE, pcaout.T2, pcamodel.limspe, ...
        pcamodel.limt2, ax0})
else
    legend('FontSize', 10, 'box', 'off', 'NumColumns', 1, ...
        'Location', 'southoutside')
end
% Function being executed when the user clicks a point in the distance plot
    function mytestcallback(src, ~, t1, t2, errmat, t2mat, spevec, ...
            t2vec, limspe, limT2, ax0)
        delete(spoint)
        xpt = get(ax0, 'CurrentPoint');
        dist2 = sum((xpt(1, 1:2) - [t1, t2]) .^ 2, 2);
        [~, iobs] = min(dist2);
        delete(findall(gcf,'type', 'annotation'))
        steps_spe_all = [zeros(sum(obstag == 0), 1); steps_spe];
        steps_t2_all = [zeros(sum(obstag == 0), 1); steps_t2];
        nscout = sum(steps_spe == steps_spe(1));
        iobs2 = iobs - obstag(iobs) * sum(obstag == 0);
        nobsorig = iobs2 - nscout * obstag(iobs) * (ceil(iobs2 / nscout) - 1);
        
        % Plot selected point
        spoint = scatter(t1(iobs), t2(iobs), 25, ...
            'Marker', 'o', 'MarkerFaceColor', 'k', ...
            'MarkerEdgeColor', 'k', 'HandleVisibility', 'off');
        
        % Anotation
        annotation('textbox', [0.1, 0.3, 0.8, 0.1], 'String', ...
            {'Select an observation from the plot above to display its SPE, its T^2 and its contributions:', ...
            strcat('Selected observation (black dot):', {'  '}, ...
            'Row ID:', {' '}, string(nobsorig), {'         '}, ...
            'SPE step: ', {' '}, string(steps_spe_all(iobs)), {'         '},...
            'T^2 step: ', {' '}, string(steps_t2_all(iobs)))},...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'left', ...
            'FontSize', 9, 'EdgeColor', 'none', 'FitBoxToText', 'on')
        
        % Value of SPE
        subplot(4, 6, 19),
        barwithucl(spevec, iobs, limspe, '{\it SPE}', ...
            '\fontsize{8}Obs.Index', '{\it SPE_i}');
        
        % Contribution to SPE (error)
        subplot(4, 6, [20, 21]);
        custombar(errmat, iobs, 'Contributions to {\it SPE}', ...
            '\fontsize{9}Variables');
        
        % Value of Hotelling's T^2
        subplot(4, 6, 22),
        barwithucl(t2vec, iobs, limT2, 'Hotelling-{\itT^2}', ...
            '\fontsize{8}Obs.Index', '{\it T^2_i}');
        
        % Contribution to Hotelling's T2
        subplot(4, 6, [23, 24]);
        custombar(t2mat, iobs, 'Contributions to {\itT^2_A}', ...
            '\fontsize{9}PCs');
    end
end