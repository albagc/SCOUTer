function distplot(X, pcamodel, clicktoggle, obstag, steps_spe, steps_t2)
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
% obstag (optional): column vector of integers indicating the group of each
%   observation. Default value set to zeros(size(X,1),1).
% inter (optional): string indicating the status of the plot interactivity.
% Default value set to 'on'.
%
% OUTPUTS
%
% SPE: column vector with the Squared Prediction Error for each observation
% in X.
% T2: column vector with the Hotelling's T^2 value for each observation
% in X.
% ax0: handle with the graphical object containing the distance plot.

arguments
    X double
    pcamodel struct
    clicktoggle string = 'on';
    obstag double = zeros(size(X, 1), 1);
    steps_spe double = zeros(size(X, 1), 1);
    steps_t2 double = zeros(size(X, 1), 1);
end
% Calculate distances according to the PCA model in pcamodel struct
pcaout = pcame(X, pcamodel);
T2 = pcaout.T2;
SPE = pcaout.SPE;

% Distance plot
if strcmp(clicktoggle, 'on')
    subplot(4, 6, 1:12),
end

distplotsimple(T2, SPE, pcamodel.limt2, pcamodel.limspe, pcamodel.alpha,...
    obstag); hold on
spoint = scatter(T2(), SPE(), 25, 'Marker', 'o', 'MarkerFaceColor', 'none', ...
    'MarkerEdgeColor', 'none', 'HandleVisibility', 'off');
ax0 = gca;

if strcmp(clicktoggle, 'on')
    legend('FontSize', 10, 'box', 'off', 'NumColumns', 1, ...
        'Position', [0 0.42 1 0.05])
    annotation('textbox', [0.2, 0.35, 0.6, 0.05], 'String', ...
        {'Please click on your observation of interest to display further information'},...
        'FitBoxToText', 'on', 'BackgroundColor', 'w', 'HorizontalAlignment',...
        'center', 'FontSize', 9, 'EdgeColor', 'none')
    set(gcf, 'WindowButtonDownFcn', {@mytestcallback, T2, SPE, pcaout.E, ...
        pcaout.T2cont, ax0})
else
    legend('FontSize', 10, 'box', 'off', 'NumColumns', 1, ...
        'Location', 'southoutside')
end

% Function being executed when the user clicks a point in the distance plot
    function mytestcallback(src, ~, t2vec, spevec, errmat, t2mat, ax0)
        delete(spoint)
        xpt = get(ax0, 'CurrentPoint');
        dist2 = sum((xpt(1,1:2) - [t2vec,spevec]) .^ 2, 2);
        [~,iobs] = min(dist2);
        delete(findall(gcf, 'type', 'annotation'))
        steps_spe_all = [zeros(sum(obstag == 0), 1); steps_spe];
        steps_t2_all = [zeros(sum(obstag == 0), 1); steps_t2];
        nscout = sum(steps_spe == steps_spe(1));
        iobs2 = iobs - obstag(iobs) * sum(obstag == 0);
        nobsorig = iobs2 - nscout * obstag(iobs) * (ceil(iobs2 / nscout) - 1);
        
        % Plot selected point
        spoint = scatter(t2vec(iobs), spevec(iobs), 25, ...
            'Marker', 'o', 'MarkerFaceColor', 'k', ...
            'MarkerEdgeColor', 'k', 'HandleVisibility', 'off');
        
        % Anotation
        annotation('textbox', [0.1, 0.3, 0.8, 0.12], 'String', ...
            {'Select an observation from the plot above to display its SPE, its T^2 and its contributions:', ...
            strcat('Selected observation (black dot):', {'  '}, ...
            'Row ID:', {' '}, string(nobsorig), {'         '}, ...
            'SPE step: ', {' '}, string(steps_spe_all(iobs)), {'         '},...
            'T^2 step: ', {' '}, string(steps_t2_all(iobs)))},...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'left', ...
            'FontSize', 9, 'EdgeColor', 'none', 'FitBoxToText', 'on')
        
        % Contribution to SPE (error)
        subplot(4, 6, 19:21)
        custombar(errmat, iobs, 'Contributions to {\it SPE}', ...
            '\fontsize{9}Variables');
        
        % Contribution to Hotelling's T2
        subplot(4, 6, 22:24)
        custombar(t2mat, iobs, 'Contributions to {\it T^2_A}', ...
            '\fontsize{9}PCs');
    end
end