function [axobj] = custombar(X, iobs, labeloptions)
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
% X: matrix with observations as row vectors.
% iobs: index of the observations whose value will be displayed.
% plotname (optional): string with the title of the plot.
% xlabelname (optional): string with the x-axis label. 
% ylabelname (optional): string with the y-axis label. 
%
% OUTPUTS
%
% axobj: parent axes of the bar plot
arguments
    X double
    iobs double {mustBeInteger, mustBeInRangeSize(iobs,X,1)}
    labeloptions.title (1,1) string = ""
    labeloptions.xlabel (1,1) string = ""
    labeloptions.ylabel (1,1) string = ""
end
plotname = labeloptions.title;
xlabelname = labeloptions.xlabel;
ylabelname = labeloptions.ylabel;
barobj = bar(X(iobs,:), 'b', 'EdgeColor', 'none', 'HandleVisibility', 'off');
axobj = ancestor(barobj, 'axes');
axobj.XGrid = 'off'; 
axobj.YGrid = 'on';
axobj.HitTest  = 'off';
axobj.FontSize = 9;
title(plotname)
y1max = max(max(abs(X)));
ylim([-1.1*y1max, 1.1*y1max])
xlabel(xlabelname)
ylabel(ylabelname)
end
% Custom validation function

function mustBeInRangeSize(arg,B,dimB)
    if (arg < 1) || (arg > size(B,dimB))
        error(['Value assigned to Data is not in range ',...
            num2str(2),'...',num2str(size(B,dimB))])
    end
end