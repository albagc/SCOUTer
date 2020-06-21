function dscplot(X, pcamodel, options)
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
% Returns the distance plot (left) and score plot (right) according to the
% input arguments.
%
% INPUTS
%
% X: data matrix with observations to be displayed in the distance plot.
% pcamodel: struct with the information of the PCA model.
%
% Name - Value pair Input Arguments:
% clicktoggle (optional): string to control interactive plot options with
%   values "on" or "off". Default set to "on". 
% pcx (optional): integer with the x-axis PC. Default set to 1.
% pcy (optional): integer with the y-axis PC. Default set to 2.
% obstag (optional): column vector of integers indicating the group of each
%   observation. Default value set to zeros(size(X,1),1).
% steps_spe (optional): column vector of integers indicating the SPE step 
%   of each observation. Default value set to zeros(size(X,1),1).
% steps_t2 (optional): column vector of integers indicating the T^2 step 
%   of each observation. Default value set to zeros(size(X,1),1).
% Default value set to 'on'.
%
% OTPUTS
%
% (none) 
arguments
    X double
    pcamodel struct
    options.click string {mustBeMember(options.click, ["on", "off"])} = 'on'
    options.pcx double = 1
    options.pcy double = 2
    options.obstag double = zeros(size(X, 1), 1)
    options.steps_spe double = zeros(size(X, 1), 1)
    options.steps_t2 double = zeros(size(X, 1), 1)
end
clicktoggle = options.click;
pcx = options.pcx;
pcy = options.pcy;
obstag = options.obstag;
steps_spe = options.steps_spe;
steps_t2 = options.steps_t2;

% Project the data onto the PCA model in pcamodel struct
pcaout = pcame(X, pcamodel);
T2 = pcaout.T2;
SPE = pcaout.SPE;
T = pcaout.T;

switch clicktoggle
    case 'off'
        subplot(121),
        distplotsimple(T2, SPE, pcamodel.limt2, pcamodel.limspe, ...
            pcamodel.alpha, obstag); hold on;
        a1 = gca;
        a1.Position(2) = 0.2;
        a1.Position(4) = 0.7;
        a1.FontSize = 8;
        spoint1 = scatter(a1, 0, 0, 25, 'Marker', 'o', ...
            'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'none', ...
            'HandleVisibility', 'off');
        
        subplot(122)
        scoreplotsimple(T, pcx, pcy, obstag, pcamodel.alpha); hold on;
        a2 = gca;
        a2.Position(2) = 0.2;
        a2.Position(4) = 0.7;
        a2.FontSize = 8;
        spoint2 = scatter(a2, 0, 0, 25, 'Marker', 'o', ...
            'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'none', ...
            'HandleVisibility', 'off');
        t1 = T(:, pcx);
        t2 = T(:, pcy);
        
        delete(findall(gcf, 'type', 'annotation'))
        
        annotation('textbox', [a1.Position(1), 0.92, 0.2, 0.05], ...
            'String', strcat('UCL_{', string((1-pcamodel.alpha)*100), '%}'), ...
            'BackgroundColor', 'none', 'EdgeColor', 'none', ...
            'HorizontalAlignment', 'left', 'FontSize', 7)
        annotation('textbox', [a2.Position(1), 0.92, 0.2, 0.05], ...
            'String', strcat('Conf.Ellipse_{', string((1-pcamodel.alpha)*100), '%}'), ...
            'BackgroundColor', 'none', 'EdgeColor', 'none', ...
            'HorizontalAlignment', 'left', 'FontSize', 7)
        
        legend('FontSize', 9, 'box', 'off', 'NumColumns', 1, ...
            'Position', [0 0.02 1 0.1])
        
        fig = gcf;
        fig.Units = 'Normalized';
        fig.Position(3) = 0.5;
        fig.Position(4) = 0.35;
        
        hBr = brush;
        hBr.Enable = 'on';
        hBr.Color = 'black';
        hBr.ActionPostCallback = {@onBrushAction};
        
    case 'on'
        
        a1 = subplot(6, 6, [1:3, 7:9]);
        distplotsimple(T2, SPE, pcamodel.limt2, pcamodel.limspe, ...
            pcamodel.alpha, obstag); hold on;
        spoint1 = scatter(T2(), SPE(), 25, 'Marker', 'o', ...
            'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'none', ...
            'HandleVisibility', 'off');
        a1.Position(1) = 0.07;
        a1.Position(3) = 0.4;
        
        t1 = T(:, pcx);
        t2 = T(:, pcy);
        a2 = subplot(6, 6, [4:6, 10:12]);
        scoreplotsimple(T, pcx, pcy, obstag, pcamodel.alpha); hold on;
        spoint2 = scatter(0, 0, 25, 'Marker', 'o', ...
            'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'none', ...
            'HandleVisibility', 'off');
        a2.Position(1) = 0.55;
        a2.Position(3) = 0.4;
        
        delete(findall(gcf, 'type', 'annotation'))
        
        annotation('textbox', [a1.Position(1), a1.Position(2) + a1.Position(4), 0.2, 0.05], ...
            'String', strcat('UCL_{', string((1-pcamodel.alpha)*100), '%}'), ...
            'BackgroundColor', 'none', 'EdgeColor', 'none', ...
            'HorizontalAlignment', 'left', 'FontSize', 7)
        annotation('textbox', [a2.Position(1), a1.Position(2) + a2.Position(4), 0.2, 0.05], ...
            'String', strcat('Conf.Ellipse_{', string((1-pcamodel.alpha)*100), '%}'), ...
            'BackgroundColor', 'none', 'EdgeColor', 'none', ...
            'HorizontalAlignment', 'left', 'FontSize', 7)
        
        legend('FontSize', 9, 'box', 'off', 'NumColumns', 1, ...
            'Position', [0 0.55 1 0.1])
        
        instr = annotation('textbox', [0.2, 0.45, 0.6, 0.075], 'String', ...
            {'Select an observation from the plot above to display its contributions:'},...
            'FitBoxToText', 'on', 'BackgroundColor', 'w', ...
            'HorizontalAlignment', 'center', 'FontSize', 9, ...
            'EdgeColor', 'none');
        
        set(gcf, 'WindowButtonDownFcn', @onClickAction)
end

% Callback for brush selection
    function onBrushAction(src, event)
        delete(spoint1), delete(spoint2)
        % Extract coordinates
        iloc = find(event.Axes.Children.BrushData ~= 0);
        spoint1 = scatter(a1, T2(iloc), SPE(iloc), 25, ...
            'Marker', 'o', 'MarkerFaceColor', 'k', ...
            'MarkerEdgeColor', 'k', 'HandleVisibility', 'off');
        
        spoint2 = scatter(a2, t1(iloc), t2(iloc), 25, ...
            'Marker', 'o', 'MarkerFaceColor', 'k', ...
            'MarkerEdgeColor', 'k', 'HandleVisibility', 'off');
        set(src, 'UserData', iloc)
    end

% Callback for click action
    function onClickAction(~, ~)
        delete(spoint1), delete(spoint2)
        ax0 = gca;
        xpt = get(ax0, 'CurrentPoint');
        if strcmp(ax0.Title.String, 'Distance plot')
            dist2 = sum((xpt(1,1:2) - [T2,SPE]) .^ 2, 2);
        elseif strcmp(ax0.Title.String, 'Score plot')
            dist2 = sum((xpt(1, 1:2) - [t1, t2]) .^ 2, 2);
        end
        [~,iobs] = min(dist2);
        delete(instr)
        steps_spe_all = [zeros(sum(obstag == 0), 1); steps_spe];
        steps_t2_all = [zeros(sum(obstag == 0), 1); steps_t2];
        nscout = sum(steps_spe == steps_spe(1));
        iobs2 = iobs - obstag(iobs) * sum(obstag == 0);
        nobsorig = iobs2 - nscout * obstag(iobs) * (ceil(iobs2 / nscout) - 1);
        
        % Plot selected point
        spoint1 = scatter(a1, T2(iobs), SPE(iobs), 25, ...
            'Marker', 'o', 'MarkerFaceColor', 'k', ...
            'MarkerEdgeColor', 'k', 'HandleVisibility', 'off');
        
        spoint2 = scatter(a2, t1(iobs), t2(iobs), 25, 'Marker', 'o', ...
            'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', ...
            'HandleVisibility', 'off');
        
        % Anotation
        instr = annotation('textbox', [0.1, 0.45, 0.8, 0.075], 'String', ...
            {'Select an observation from the plot above to display its SPE, its T^2 and its contributions:', ...
            strcat('Selected observation (black dot):', {'  '}, ...
            'Row ID:', {' '}, string(nobsorig), {'         '}, ...
            'SPE step: ', {' '}, string(steps_spe_all(iobs)), {'         '},...
            'T^2 step: ', {' '}, string(steps_t2_all(iobs)))},...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'center', ...
            'FontSize', 9, 'EdgeColor', 'none', 'FitBoxToText', 'off');
        
        % Value of SPE
        subplot('Position', [0.0700, 0.1100, 0.0500, 0.25]),
        barwithucl(SPE, iobs, pcamodel.limspe, 'title','{\it SPE}', ...
            'xlabel','\fontsize{8}Obs.Index', 'ylabel', '{\it SPE_i}');
        
        % Contribution to SPE (error)
        subplot('Position', [0.17, 0.1100, 0.35, 0.25]),
        custombar(pcaout.E, iobs, 'title', 'Contributions to {\it SPE}', ...
            'xlabel', '\fontsize{9}Variables');
        
        % Value of Hotelling's T^2
        subplot('Position', [0.6, 0.1100, 0.0500, 0.25]),
        barwithucl(T2, iobs, pcamodel.limt2, 'title', 'Hotelling-{\itT^2}', ...
            'xlabel', '\fontsize{8}Obs.Index', 'ylabel', '{\it T^2_i}');
        
        % Contribution to Hotelling's T2
        subplot('Position', [0.7, 0.1100, 0.25, 0.25]),
        ct2 = custombar(pcaout.T2cont, iobs, 'title', 'Contributions to {\itT^2_A}', ...
            'xlabel', '\fontsize{9}PCs');
        ct2.YLim(1) = 0;
    end
end

