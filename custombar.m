function [axv] = custombar(X, iobs, plotname, xlabelname, ylabelname)
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
% statvec: matrix with values to be displayed.
% ibos: index of the observations whose values will be displayed.
% plotname: string with the title that will be displayed on the plot.
% xlabelname: string with the label for the x-axis.
%
% OUTPUTS
%
% axv: Plots the values with the upper control limit of the statistic
arguments
    X double
    iobs double
    plotname string = "";
    xlabelname string = "";
    ylabelname string = "";
end
b1 = bar(X(iobs,:), 'b', 'EdgeColor', 'none', 'HandleVisibility', 'off');
axv = ancestor(b1, 'axes');
axv.XGrid = 'off'; 
axv.YGrid = 'on';
axv.HitTest  = 'off';
axv.FontSize = 9;
title(plotname)
y1max = max(max(abs(X)));
ylim([-1.1*y1max, 1.1*y1max])
xlabel(xlabelname)
ylabel(ylabelname)
end