function [T ,t1t2, ell] = scoreplot2(X, pcamodel, mode, markeropt, scoreopt)
% Check input arguments and set default values for optionals
if nargin < 3
    error('Not enough arguments')
elseif nargin == 3
    scoreopt = struct('pc1', 1, 'pc2', 2, 'alpha', pcamodel.alpha);
    if strcmp(mode, 'ref')
        markeropt = struct('shape', '.', 'color', 'b', 'size', 12, ...
            'name', 'T_{ref}');
    elseif strcmp(mode, 'new')
        markeropt = struct('shape', '^', 'color', 'r', 'size', 6, ...
            'name', 'T_{new}');
    else
        error('Mode argument not recognized')
    end
elseif nargin == 4
    scoreopt = struct('pc1', 1, 'pc2', 2, 'alpha', pcamodel.alpha);
end

if strcmp(pcamodel.prepro, 'cent')
    Xaux = X - pcamodel.m;
elseif strcmp(pcamodel.prepro, 'autosc')
    Xaux = (X - pcamodel.m) ./ repmat(pcamodel.s, size(X,1), 1);
end
T = Xaux * pcamodel.Pfull;
t1 = T(:, scoreopt.pc1);
t2 = T(:, scoreopt.pc2);

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

conflev = (1 - scoreopt.alpha) * 100;
plot(linspace(-tmax, tmax, 1000), zeros(1000, 1), 'k'), hold on
plot(zeros(1000, 1), linspace(-tmax, tmax, 1000), 'k'),
t1t2 = plot(t1, t2, markeropt.shape, 'Color', markeropt.color, ...
    'linewidth', 1.2, 'MarkerFaceColor', markeropt.color, ...
    'MarkerEdgeColor', markeropt.color, 'Markersize', markeropt.size, ...
    'DisplayName', markeropt.name);
if strcmp(mode, 'ref')
    xticks(-floor(tmax):1:floor(tmax));
    yticks(-floor(tmax):1:floor(tmax));
else
    xticks(-floor(tmax):round(2*tmax/10):floor(tmax));
    yticks(-floor(tmax):round(2*tmax/10):floor(tmax));
    grid off
end
grid on,
ell = plot(x, y, 'r--', 'linewidth', 1.05, 'DisplayName',...
    strcat(string(conflev), '% C.L.'));
xlim([-tmax, tmax]), ylim([-tmax, tmax])
xlabel(strcat('T_{', string(scoreopt.pc1), '}'))
ylabel(strcat('T_{', string(scoreopt.pc2), '}'))
legend([t1t2, ell]), legend('FontSize', 10, 'box', 'off',...
    'location', 'southoutside', 'box', 'off', 'NumColumns', 2)
title('Score plot')

end