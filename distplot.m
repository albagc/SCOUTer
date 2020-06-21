function distplot(X, pcamodel, options)
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
% Returns the distance plot according to the input arguments.
%
% INPUTS
%
% X: data matrix with observations to be displayed in the distance plot.
% pcamodel: struct with the information of the PCA model.
%
% Name - Value pair Input Arguments:
% clicktoggle(optional): string to control interactive plot options with
%   values "on" or "off". Default set to "on".
% obstag (optional): column vector of integers indicating the group of each
%   observation. Default value set to zeros(size(X,1),1).
% steps_spe (optional): column vector of integers indicating the SPE step
%   of each observation. Default value set to zeros(size(X,1),1).
% steps_t2 (optional): column vector of integers indicating the T^2 step
%   of each observation. Default value set to zeros(size(X,1),1).
%
% OTPUTS
%
% (none) returns the distance plot.
arguments
    X double
    pcamodel struct
    options.clicktoggle string {mustBeMember(options.clicktoggle, ["on", "off"])} = 'on'
    options.obstag double = zeros(size(X, 1), 1)
    options.steps_spe double = zeros(size(X, 1), 1)
    options.steps_t2 double = zeros(size(X, 1), 1)
end
clicktoggle = options.clicktoggle;
obstag = options.obstag;
steps_spe = options.steps_spe;
steps_t2 = options.steps_t2;

% Calculate distances according to the PCA model in pcamodel struct
pcaout = pcame(X, pcamodel);
T2 = pcaout.T2;
SPE = pcaout.SPE;

switch clicktoggle
    case 'off'
        a1 = subplot(6, 6, 1:12);
        distplotsimple(T2, SPE, pcamodel.limt2, pcamodel.limspe, ...
            pcamodel.alpha, obstag); hold on        
        spoint = scatter(T2(), SPE(), 25, 'Marker', 'o', 'MarkerFaceColor', 'none', ...
            'MarkerEdgeColor', 'none', 'HandleVisibility', 'off');
        delete(findall(gcf, 'type', 'annotation'))
        annotation('textbox', [a1.Position(1), a1.Position(2) + a1.Position(4), 0.2, 0.05], ...
            'String', strcat('UCL_{', string((1-pcamodel.alpha)*100), '%}'), ...
            'BackgroundColor', 'none', 'EdgeColor', 'none', ...
            'HorizontalAlignment', 'left', 'FontSize', 7)
        
        legend('FontSize', 10, 'box', 'off', 'NumColumns', 1, ...
            'Position', [0 0.4 1 0.05])
        
        annotation('textbox', [0.2, 0.35, 0.6, 0.05], 'String', ...
            {'Select an observation from the plot above to display its contributions:'}, ...
            'FitBoxToText', 'on', 'BackgroundColor', 'w', 'HorizontalAlignment',...
            'center', 'FontSize', 9, 'EdgeColor', 'none')
        set(gcf, 'WindowButtonDownFcn', @onClickAction)
        
        fig = gcf;
        fig.Units = 'Normalized';
        fig.Position(3) = 0.5;
        fig.Position(4) = 0.35;
        
        hBr = brush;
        hBr.Enable = 'on';
        hBr.Color = 'black';
        hBr.ActionPostCallback = {@onBrushAction};
        
    case 'on'
        
        a1 = subplot(6, 6, 1:12);
        distplotsimple(T2, SPE, pcamodel.limt2, pcamodel.limspe, ...
            pcamodel.alpha, obstag); hold on;
        spoint = scatter(T2(), SPE(), 25, 'Marker', 'o', ...
            'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'none', ...
            'HandleVisibility', 'off');
        delete(findall(gcf, 'type', 'annotation'))        
        annotation('textbox', [a1.Position(1), a1.Position(2) + a1.Position(4), 0.2, 0.05], ...
            'String', strcat('UCL_{', string((1-pcamodel.alpha)*100), '%}'), ...
            'BackgroundColor', 'none', 'EdgeColor', 'none', ...
            'HorizontalAlignment', 'left', 'FontSize', 7)
        
        legend('FontSize', 9, 'box', 'off', 'NumColumns', 1, ...
            'Position', [0 0.5 1 0.1])
        
        instr = annotation('textbox', [0.2, 0.45, 0.6, 0.05], 'String', ...
            {'Select an observation from the plot above to display its contributions:'}, ...
            'FitBoxToText', 'on', 'BackgroundColor', 'w', ...
            'HorizontalAlignment', 'center', 'FontSize', 9, ...
            'EdgeColor', 'none');
        
        set(gcf, 'WindowButtonDownFcn', @onClickAction)
end

% Callback for brush selection
    function onBrushAction(src, event)
        delete(spoint)
        % Extract coordinates
        iloc = find(event.Axes.Children.BrushData ~= 0);
        spoint = scatter(a1, T2(iloc), SPE(iloc), 25, ...
            'Marker', 'o', 'MarkerFaceColor', 'k', ...
            'MarkerEdgeColor', 'k', 'HandleVisibility', 'off');
        set(src, 'UserData', iloc)
    end

% Callback for click action
    function onClickAction(~, ~)
        delete(spoint)
        ax0 = gca;
        xpt = get(ax0, 'CurrentPoint');
        dist2 = sum((xpt(1,1:2) - [T2, SPE]) .^ 2, 2);
        [~,iobs] = min(dist2);
        delete(instr)
        steps_spe_all = [zeros(sum(obstag == 0), 1); steps_spe];
        steps_t2_all = [zeros(sum(obstag == 0), 1); steps_t2];
        nscout = sum(steps_spe == steps_spe(1));
        iobs2 = iobs - obstag(iobs) * sum(obstag == 0);
        nobsorig = iobs2 - nscout * obstag(iobs) * (ceil(iobs2 / nscout) - 1);
        
        % Plot selected point
        spoint = scatter(T2(iobs), SPE(iobs), 25, ...
            'Marker', 'o', 'MarkerFaceColor', 'k', ...
            'MarkerEdgeColor', 'k', 'HandleVisibility', 'off');
        
        % Anotation
        instr = annotation('textbox', [0.1, 0.45, 0.8, 0.075], 'String', ...
            {'Select an observation from the plot above to display its contributions:', ...
            strcat('Selected observation (black dot):', {'  '}, ...
            'Row ID:', {' '}, string(nobsorig), {'         '}, ...
            'SPE step: ', {' '}, string(steps_spe_all(iobs)), {'         '}, ...
            'T^2 step: ', {' '}, string(steps_t2_all(iobs)))},...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'center', ...
            'FontSize', 9, 'EdgeColor', 'none', 'FitBoxToText', 'off');
        
        % Contribution to SPE (error)
        subplot('Position', [0.15, 0.1100, 0.35, 0.25]),
        custombar(pcaout.E, iobs, 'title', 'Contributions to {\it SPE}', ...
            'xlabel', '\fontsize{9}Variables');
        
        % Contribution to Hotelling's T2
        subplot('Position', [0.55, 0.1100, 0.35, 0.25]),
        ct2 = custombar(pcaout.T2cont, iobs, 'title', 'Contributions to {\it T^2_A}', ...
            'xlabel', '\fontsize{9}PCs');
        ct2.YLim(1) = 0;
    end
end