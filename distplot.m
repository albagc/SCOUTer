function [SPE, T2, ax0] = distplot(X, pcamodel, obstag, inter)
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
% Default value set to 'on'.
%
% OUTPUTS
%
% SPE: column vector with the Squared Prediction Error for each observation
% in X.
% T2: column vector with the Hotelling's T^2 value for each observation
% in X.
% ax0: handle with the graphical object containing the distance plot.
%% Check inputs
if nargin < 3
    disp('No tag provided do distinguish between observations.')
    obstag = zeros(size(X,1),1);
    inter = 'on';
elseif nargin == 3
    inter = 'on';
end
%% Calculate distances according to the PCA model in pcamodel struct
if strcmp(pcamodel.prepro, 'cent')
    Xaux = X - pcamodel.m;
elseif strcmp(pcamodel.prepro, 'autosc')
    Xaux = (X - pcamodel.m) ./ repmat(pcamodel.s, size(X,1), 1);
end
T = Xaux * pcamodel.P;
E = Xaux - T * pcamodel.P';
SPE = sum(E .^ 2, 2);
n = size(T,1);
T2 = sum(T .^2 ./ repmat(pcamodel.lambda, n, 1), 2);
T2matrix = T .^2 ./ repmat(pcamodel.lambda, n, 1);
%% Distance plot
markseries = {'^', 'sq', 'o', '+', 'v'};
userie = unique(obstag);
if strcmp(inter,'on')
    subplot(2,4,[1,2,5,6]);
end
a = 1.25 * max([T2; pcamodel.limt2]);
b = 1.25 * max([SPE; pcamodel.limspe]);
conflev = (1 - pcamodel.alpha) * 100;
plot(linspace(0, a, 100), pcamodel.limspe * ones(100, 1), 'r--',...
    'linewidth', 1.2,'DisplayName',strcat('UCL_{', string(conflev), '%}'));
hold on
plot(pcamodel.limt2 * ones(100, 1), linspace(0, b, 100), 'r--',...
    'linewidth', 1.2,'HandleVisibility','off');
% Model-Building subset
plot(T2(obstag==0,:), SPE(obstag==0,:), '.', 'linewidth', 1, ...
    'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'Markersize', 12, ...
    'DisplayName', 'X_{ref}');
% Model-Exploitation subset(s)
userie2 = userie(userie>0);
if ~isempty(userie2)
    for i = 1:length(userie2)
        plot(T2(obstag==userie2(i),:), SPE(obstag==userie2(i),:), ...
            markseries{i}, 'linewidth', 1, 'MarkerFaceColor', 'r', ...
            'MarkerEdgeColor', 'r', 'Markersize', 4, 'DisplayName', ...
            strcat('X_{new_',string(i),'}'));
    end
end
xlim([0, a]), ylim([0, b]),
legend('FontSize', 8, 'location', 'southoutside', 'box', 'off', ...
    'NumColumns', 2)
grid on, xlabel('T^2'), ylabel('SPE'), title('Distance plot')
ax0 = gca;
% If the plot is interactive
if strcmp(inter,'on')
    set(gcf,'WindowButtonDownFcn',{@mytestcallback,T2,SPE,E,T2matrix,ax0})
end
% Function being executed when the user clicks a point in the distance plot
    function mytestcallback(src,~,t2vec,spevec,errmat,t2mat,ax0)
        xpt = get(ax0,'CurrentPoint');
        dist2 = sum((xpt(1,1:2) - [t2vec,spevec]) .^ 2, 2);
        [~,iobs] = min(dist2);
        % Contribution to SPE (error)
        subplot(2,4,[3,4]);
        b1 = bar(errmat(iobs,:),'b','EdgeColor','none');
        ax1 = ancestor(b1,'axes');
        ax1.XGrid = 'off'; ax1.YGrid = 'on';
        title(strcat('Contribution to SPE (obs.',string(iobs),')'))
        y1max = max(max(abs(errmat)));
        ylim([-1.1*y1max, 1.1*y1max])
        xlabel('Variables')
        % Contribution to Hotelling's T2
        subplot(2,4,[7,8]);
        b2 = bar(t2mat(iobs,:),'b','EdgeColor','none');
        ax2 = ancestor(b2,'axes');
        ax2.XGrid = 'off'; ax2.YGrid = 'on';
        title(strcat('Contribution to H.T^2 (obs.',string(iobs),')'))
        y2max = max(max(abs(t2mat)));
        ylim([-1.1*y2max, 1.1*y2max])
        xlabel('Components')
    end
end