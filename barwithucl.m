function [axobj] = barwithucl(x, iobs, ucl, labeloptions)
% Statistically Controlled OUTlIERs
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
% Single bar plot with Upper Control Limis. Customized title and labels.
% Y-Axis limits are fixed according to the range of the values in x.
%
% INPUTS
%
% x: vector with the values of the statistic.
% iobs: index of the observations whose value will be displayed.
% ucl: Upper Control Limit of the statistic.
% 
% Name-Value pair input arguments:
% plotname (optional): string with the title of the plot.
% xlabelname (optional): string with the x-axis label. 
% ylabelname (optional): string with the y-axis label. 
%
% OUTPUTS
%
% axobj: parent axes of the bar plot
arguments
    x double
    iobs (1,1) {mustBeInteger, mustBeInRangeLength(iobs, x)}
    ucl (1,1) double = nan
    labeloptions.title (1,1) string = ""
    labeloptions.xlabel (1,1) string = ""
    labeloptions.ylabel (1,1) string = ""
end
plotname = labeloptions.title;
xlabelname = labeloptions.xlabel;
ylabelname = labeloptions.ylabel;
barobj = bar(x(iobs), 'b', 'EdgeColor', 'none'); hold on
axobj = ancestor(barobj, 'axes');
b1xlim = xlim;
plot(axobj, linspace(b1xlim(1), b1xlim(2), 50), ucl * ones(50, 1), ...
    'r--', 'linewidth', 1.2); hold off
axobj.XGrid = 'off'; 
axobj.YGrid = 'on';
axobj.HitTest  = 'off';
title(plotname), 
xticklabels(strcat('obs.', string(iobs))),
xlabel(xlabelname),
ylabel(ylabelname),
ylim([0, 1.1*max(x)])
end

% Custom validation function
function mustBeInRangeLength(arg,b)
    if (arg < 1) || (arg > length(b))
        error(['Value assigned to Data is not in range ',...
            num2str(1),'...',num2str(length(b))])
    end
end