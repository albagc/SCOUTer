function [SPE, T2, d1d2, p1, p2] = plotdist2(X, pcamodel, mode, markeropt)
if nargin < 3
    error('Not enough arguments')
elseif nargin == 3
    if strcmp(mode, 'ref')
        markeropt = struct('shape', '.', 'color', 'b', ...
            'size', 12, 'name', 'X_{ref}');
    elseif strcmp(mode, 'new')
        markeropt = struct('shape', '^', 'color', 'r', ...
            'size', 6, 'name', 'X_{new}');
    else
        error('Mode argument not recognized')
    end
end
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

a = 1.25 * max([T2; pcamodel.limt2]);
b = 1.25 * max([SPE; pcamodel.limspe]);
p1 = plot(linspace(0, a, 100), pcamodel.limspe * ones(100, 1), 'r--',...
    'linewidth', 1.2); 
hold on
p2 = plot(pcamodel.limt2 * ones(100, 1), linspace(0, b, 100), 'r--',...
    'linewidth', 1.2);
d1d2 = plot(T2, SPE, markeropt.shape, 'Color', markeropt.color, ...
    'linewidth', 1.2, 'MarkerFaceColor', markeropt.color, ...
    'MarkerEdgeColor', markeropt.color, 'Markersize', markeropt.size, ...
    'DisplayName', markeropt.name);
grid on,
conflev = (1 - pcamodel.alpha) * 100;
xlim([0, a]), ylim([0, b]), 
legend([d1d2, p1], {markeropt.name, strcat('UCL_{', string(conflev), '%}')})
legend('FontSize', 10, 'location', 'southoutside', 'box','off', 'NumColumns',2)
grid on, xlabel('T^2'), ylabel('SPE'), title('Distance plot')
end