function [T, ax0] = scoreplot(X, pcamodel, obstag, inter, scoreopt)
% Statistically Controlled OUTliERs 
% A. González Cebrián, A. Folch-Fortuny, F. Arteaga and A. Ferrer
% Copyright (C) 2020 A. González Cebrián and F. Arteaga
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
%   Default value set to 'on'.
% scoreopt (optional): struct indicating the PCs whose scores will be
%   used in the score plot. Default values are scoreopt.pc1 = 1 and
%   scoreopt.pc2 = 2;
%
% OUTPUTS
%
% T: matrix with the coordinates of each observation in the score plot.
% ax0: handle with the graphical object containing the score plot.
%% Check inputs
if nargin < 3
    disp('No tag provided do distinguish between observations.')
    obstag = zeros(size(X,1),1);
    scoreopt = struct('pc1', 1, 'pc2', 2);
    inter = 'on';
elseif nargin == 3
    scoreopt = struct('pc1', 1, 'pc2', 2);
    inter = 'on';
elseif nargin == 4
    scoreopt = struct('pc1', 1, 'pc2', 2);
end
%% Calculate the scores according to the PCA model in pcamodel struct
if strcmp(pcamodel.prepro, 'cent')
    Xaux = X - pcamodel.m;
elseif strcmp(pcamodel.prepro, 'autosc')
    Xaux = (X - pcamodel.m) ./ repmat(pcamodel.s, size(X,1), 1);
end
T = Xaux * pcamodel.Pfull;
t1 = T(:, scoreopt.pc1);
t2 = T(:, scoreopt.pc2);
E = Xaux - T(:, 1:pcamodel.ncomp) * pcamodel.P';
SPE = sum(E .^ 2, 2);
n = size(T,1);
T2 = sum(T(:, 1:pcamodel.ncomp) .^2 ./ repmat(pcamodel.lambda, n, 1), 2);
T2matrix = T(:, 1:pcamodel.ncomp) .^2 ./ repmat(pcamodel.lambda, n, 1);

% Confidence ellipse (x,y)
n = size(t1,1);
limt1 = pcamodel.limits_t.(strcat('pc',string(scoreopt.pc1)));
limt2 = pcamodel.limits_t.(strcat('pc',string(scoreopt.pc2)));
t1min = min([t1; t2; limt1(1)]) * 1.1;
t1max = max([t1; t2; limt1(2)]) * 1.1;
tmax = max(abs([t1min, t1max]));
a = limt1(2); % horizontal radius
b = limt2(2); % vertical radius
t = -pi:0.01:pi;
x = a * cos(t);
y = b * sin(t);
%% Score plot
markseries = {'^', 'sq', 'o', '+', 'v'};
userie = unique(obstag);
if strcmp(inter,'on')
    subplot(2, 6, [1,2,3,7,8,9])
end
conflev = (1 - pcamodel.alpha) * 100;
plot(linspace(-tmax, tmax, 1000), zeros(1000, 1), 'k', ...
    'HandleVisibility', 'off'), hold on
plot(zeros(1000, 1), linspace(-tmax, tmax, 1000), 'k', ...
    'HandleVisibility', 'off')
% Model-Building subset
plot(t1(obstag==0,:), t2(obstag==0,:), '.', 'linewidth', 1, ...
    'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'Markersize', 12, ...
    'DisplayName', 'X_{ref}');
% Model-Exploitation subset
userie2 = userie(userie>0);
if ~isempty(userie2)
    for i = 1:length(userie2)
        plot(t1(obstag==userie2(i),:), t2(obstag==userie2(i),:), ...
            markseries{i}, 'linewidth', 1, 'MarkerFaceColor', 'r', ...
            'MarkerEdgeColor', 'r', 'Markersize', 4, 'DisplayName', ...
            strcat('X_{new_',string(i),'}'));
    end
end
xticks(-floor(tmax):round(2*tmax/10):floor(tmax));
yticks(-floor(tmax):round(2*tmax/10):floor(tmax));
grid on,
plot(x, y, 'r--', 'linewidth', 1.05, 'DisplayName',...
    strcat(string(conflev), '% C.L.'));
xlim([-tmax, tmax]), ylim([-tmax, tmax])
xlabel(strcat('t_{', string(scoreopt.pc1), '}'))
ylabel(strcat('t_{', string(scoreopt.pc2), '}'))
legend('FontSize', 8, 'box', 'off', 'location', 'southoutside', ...
    'box', 'off', 'NumColumns', 2)
title('Score plot')
ax0 = gca;
% If the plot is interactive
if strcmp(inter,'on')
    set(gcf,'WindowButtonDownFcn',...
        {@mytestcallback,t1,t2,E,T2matrix,SPE,T2,pcamodel.limspe,...
        pcamodel.limt2,ax0})
end
% Function being executed when the user clicks a point in the distance plot
    function mytestcallback(src,~,t1,t2,errmat,t2mat,spevec,t2vec,...
            limspe,limT2,ax0)
        xpt = get(ax0,'CurrentPoint');
        dist2 = sum((xpt(1,1:2) - [t1,t2]) .^ 2, 2);
        [~,iobs] = min(dist2);
        % Value of SPE
        subplot(2, 6, 4);
        b1_1 = bar(spevec(iobs),'b','EdgeColor','none'); hold on
        ax1_1 = ancestor(b1_1,'axes');
        b1xlim = xlim;
        plot(ax1_1, linspace(b1xlim(1), b1xlim(2), 50), ...
            limspe * ones(50, 1), 'r--', 'linewidth', 1.2); hold off
        ax1_1.XGrid = 'off'; ax1_1.YGrid = 'on';
        ax1_1.HitTest  = 'off';
        title('SPE'), xlabel(strcat('obs.',string(iobs)))
        ylim([0, 1.1*max(spevec)])
        % Contribution to SPE (error)
        subplot(2, 6, [5, 6]);
        b1 = bar(errmat(iobs,:),'b','EdgeColor','none');
        ax1 = ancestor(b1,'axes');
        ax1.XGrid = 'off'; ax1.YGrid = 'on';
        ax1.HitTest  = 'off';
        title(strcat('Contributions to SPE'))
        y1max = max(max(abs(errmat)));
        ylim([-1.1*y1max, 1.1*y1max])
        xlabel('Variables')
        
        % Value of Hotelling's T^2
        subplot(2, 6, 10);
        b1_2 = bar(t2vec(iobs),'b','EdgeColor','none');hold on
        ax1_2 = ancestor(b1_2,'axes');
        b2xlim = xlim;
        plot(ax1_2,linspace(b2xlim(1), b2xlim(2), 50), limT2 * ones(50, 1),...
            'r--', 'linewidth', 1.2); hold off
        ax1_2.XGrid = 'off'; ax1_2.YGrid = 'on';
        ax1_2.HitTest  = 'off';
        title('Hotelling T^2'), xlabel(strcat('obs.',string(iobs)))
        ylim([0, 1.1*max(t2vec)])
        
        % Contribution to Hotelling's T2
        subplot(2, 6, [11, 12]);
        b2 = bar(t2mat(iobs,:),'b','EdgeColor','none');
        ax2 = ancestor(b2,'axes');
        ax2.XGrid = 'off'; ax2.YGrid = 'on';
        ax2.HitTest  = 'off';
        title(strcat('Contributions to H.T^2'))
        y2max = max(max(abs(t2mat)));
        ylim([0, 1.1*y2max])
        xlabel('Components')
    end
end