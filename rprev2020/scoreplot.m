function scoreplot(X, pcamodel, varargin)
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
% Returns the score plot according to the input arguments.
%
% INPUTS
%
% X: data matrix with observations to be displayed in the distance plot.
% pcamodel: struct with the information of the PCA model.
%
% Name - Value pair Input Arguments:
% click (optional): string indicating the status of the plot interactivity.
%   Default value set to 'on'.
% pcx (optional): integer with PC represented in the horizontal axis.
%   Default value set to 1.
% pcy (optional): integer with PC represented in the vertical axis.
%   Default value set to 2.
% obstag (optional): vector of integers indicating the group of each
%   observation. Default value set to zeros(size(X,1),1).
% steps_spe (optional): column vector of integers indicating the SPE step
%   of each observation. Default value set to zeros(size(X,1),1).
% steps_t2 (optional): column vector of integers indicating the T^2 step
%   of each observation. Default value set to zeros(size(X,1),1).
%
% OUTPUTS
%
% (none)
% Check inputs
narginchk(2,14)
% name-value pair arguments
options = struct('click','on','pcx',1,'pcy',2,'obstag',...
    zeros(size(X, 1), 1),'steps_spe',zeros(size(X, 1), 1),'steps_t2',...
    zeros(size(X, 1), 1));
optionNames = fieldnames(options);
if round(length(varargin)/2)~=length(varargin)/2 % Check pairs
    error('Each Name argument needs a value pair argument')
end
for pair = reshape(varargin,2,[])
    inName = lower(pair{1});
    if any(strcmp(inName,optionNames))
        options.(inName) = pair{2};
    else
        error('The %s input is not recognized by this function',inName)
    end
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
        a1 = subplot(6, 6, 1:12);
        scoreplotsimple(T, pcx, pcy, obstag, pcamodel.alpha)
        spoint = scatter(0, 0, 25, 'Marker', 'o', ...
            'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'none', ...
            'HandleVisibility', 'off');
        delete(findall(gcf, 'type', 'annotation'))
        annotation('textbox', [a1.Position(1), a1.Position(2) + a1.Position(4), 0.2, 0.05], ...
            'String', strcat('Conf.Ellipse_{', string((1-pcamodel.alpha)*100), '%}'), ...
            'BackgroundColor', 'none', 'EdgeColor', 'none', ...
            'HorizontalAlignment', 'left', 'FontSize', 7)
        
        legend('FontSize', 10, 'box', 'off', 'NumColumns', 1, ...
            'Position', [0 0.4 1 0.05])
        
        annotation('textbox', [0.2, 0.35, 0.6, 0.05], 'String', ...
            {'Select an observation from the plot above to display its SPE, its T^2 and its contributions:'}, ...
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
        scoreplotsimple(T, pcx, pcy, obstag, pcamodel.alpha)
        spoint = scatter(0, 0, 25, 'Marker', 'o', ...
            'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'none', ...
            'HandleVisibility', 'off');
        delete(findall(gcf, 'type', 'annotation'))
        annotation('textbox', [a1.Position(1), a1.Position(2) + a1.Position(4), 0.2, 0.05], ...
            'String', strcat('Conf.Ellipse_{', string((1-pcamodel.alpha)*100), '%}'), ...
            'BackgroundColor', 'none', 'EdgeColor', 'none', ...
            'HorizontalAlignment', 'left', 'FontSize', 7)
        
        legend('FontSize', 9, 'box', 'off', 'NumColumns', 1, ...
            'Position', [0 0.5 1 0.1])
        
        instr = annotation('textbox', [0.2, 0.45, 0.6, 0.05], 'String', ...
            {'Select an observation from the plot above to display its SPE, its T^2 and its contributions:'}, ...
            'FitBoxToText', 'on', 'BackgroundColor', 'w', ...
            'HorizontalAlignment', 'center', 'FontSize', 9, ...
            'EdgeColor', 'none');
        
        set(gcf, 'WindowButtonDownFcn', @onClickAction)
end

t1 = T(:, pcx);
t2 = T(:, pcy);

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
        annotation('textbox', [0.1, 0.45, 0.8, 0.075], 'String', ...
            {'Select an observation from the plot above to display its SPE, its T^2 and its contributions:', ...
            strcat('Selected observation (black dot):', {'  '}, ...
            'Row ID:', {' '}, string(nobsorig), {'         '}, ...
            'SPE step: ', {' '}, string(steps_spe_all(iobs)), {'         '},...
            'T^2 step: ', {' '}, string(steps_t2_all(iobs)))},...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'center', ...
            'FontSize', 9, 'EdgeColor', 'none', 'FitBoxToText', 'on')
        
        % Value of SPE
        subplot('Position', [0.0700, 0.1100, 0.0500, 0.25]),
        barwithucl(SPE, iobs, pcamodel.limspe, 'title', '{\it SPE}', ...
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