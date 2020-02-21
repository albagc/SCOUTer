% exe_example
load exampleX
%% Build model and illustrate model information
pcamodel_ref = pcamb_classic(X, 2, 0.05, 'cent');
figure('Name', 'Ref PCA model'), 
subplot(121), plotdist2(X, pcamodel_ref, 'ref');
subplot(122), scoreplot2(X, pcamodel_ref, 'ref');
%% Generate outlier and plot
indsel = randperm(size(X, 1), 1);
x2 = genoutX(X(indsel, :), pcamodel_ref, 20, 20);
figure('Name', 'Single shift with PCA model'), 
subplot(121), plotdist2(X, pcamodel_ref, 'ref'); hold on
plotdist2(x2, pcamodel_ref, 'new');
subplot(122), scoreplot2(X, pcamodel_ref, 'ref'); hold on
scoreplot2(x2, pcamodel_ref, 'new');
%%
figure('Name', 'Single shift'), 
subplot(121), plotdist2(x2, pcamodel_ref, 'new');
subplot(122), scoreplot2(x2, pcamodel_ref, 'new');
%% Generate outlier with 5 steps and plot
[x2_traj, spe_traj, t2_traj, spesteps, t2steps] = genoutXsteps(X(indsel, :), ...
    pcamodel_ref, 20, 20, 5);
markeropt = struct('shape', '^-', 'color', 'r', 'size', 6, ...
            'name', 'T_{new}');
figure('Name', 'Traj X2 steps'), 
subplot(121), 
plotdist2(X, pcamodel_ref, 'ref'); hold on
plotdist2(x2_traj, pcamodel_ref, 'new', markeropt);
subplot(122), 
scoreplot2(X, pcamodel_ref, 'ref'); hold on
scoreplot2(x2_traj, pcamodel_ref, 'new', markeropt);