function [axv] = barwithucl(x, iobs, ucl, plotname, xlabelname, ylabelname)
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
% INPUTS
%
% x: vector with the values of the statistic.
% ibos: index of the observations whose value will be displayed.
% ucl: upper control limit for the value of the statistic.
% plotname (optional): string with the title of the plot.
% xlabelname (optional): string with the x-axis label. 
% ylabelname (optional): string with the y-axis label. 
%
% OUTPUTS
%
% axv: axis of the bar plot
arguments
    x double
    iobs double
    ucl double
    plotname string = "";
    xlabelname string = "";
    ylabelname string = "";
end
b1_1 = bar(x(iobs), 'b', 'EdgeColor', 'none'); hold on
axv = ancestor(b1_1, 'axes');
b1xlim = xlim;
plot(axv, linspace(b1xlim(1), b1xlim(2), 50), ucl * ones(50, 1), ...
    'r--', 'linewidth', 1.2); hold off
axv.XGrid = 'off'; 
axv.YGrid = 'on';
axv.HitTest  = 'off';
title(plotname), 
xticklabels(strcat('obs.', string(iobs))),
xlabel(xlabelname),
ylabel(ylabelname),
ylim([0, 1.1*max(x)])
end