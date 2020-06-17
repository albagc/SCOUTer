%% Load data and build a PCA model
load exampleX
pcamodel_ref = pcamb_classic(X, 2, 0.05, 'cent');
pcaout = pcame(X, pcamodel_ref);
figure('Name', 'PCA Model for reference data set')
dscplot(X, pcamodel_ref, 'off');
%% Switch on interactivity
figure('Name', 'PCA Model plot'), 
dscplot(X, pcamodel_ref, 'on');
%% SPE and H-T2 information
% Find observation with maximum SPE and display its contributions
[~, imaxspe] = max(pcaout.SPE);
figure('Name', 'SPE information'),
speinfo(pcaout.SPE, pcaout.E, pcamodel_ref.limspe, imaxspe);
figure('Name', 'H-T2 information'),
ht2info(pcaout.T2, pcaout.T2cont, pcamodel_ref.limt2, imaxspe);

%% Select one observation randomly and generate the three types of outliers
indsel = randperm(size(X, 1), 1);
x = X(indsel, :);
out_x_both = scout(x, pcamodel_ref, 'simple', 'spey', 20, 't2y', 20); 
out_x_t2 = scout(x, pcamodel_ref, 'simple', 't2y', 20); % Shift in T^2
out_x_spe = scout(x, pcamodel_ref, 'simple', 'spey', 20); % Shift in SPE

Xall = [x; out_x_both.X; out_x_t2.X; out_x_spe.X];
obstag = [0; ones(3,1)];
steps = [1:3]';

figure('Name', 'PCA Model plot'), 
dscplot(Xall, pcamodel_ref, 'on', 1, 2, obstag, steps, steps);

%% Generate a set of outliers increasing only the T^2 (one step)
T2target = 40*ones(size(X, 1), 1);
Xextreme = scout(X, pcamodel_ref, 'simple', 't2y', T2target);
Xall = [X; Xextreme.X];
obstag = [zeros(size(X, 1), 1); Xextreme.tag];
figure('Name', 'PCA Model plot'), 
dscplot(Xall, pcamodel_ref, 'off', 1, 2, obstag, Xextreme.step_spe, ...
    Xextreme.step_t2);

figure('Name', 'PCA Model plot'), 
dscplot(Xall, pcamodel_ref, 'on', 1, 2, obstag, Xextreme.step_spe, ...
    Xextreme.step_t2);

%% Select the set by brushing observations
figure('Name', 'PCA Model plot'), 
dscplot(X, pcamodel_ref, 'off') % Reference data set (Brush points) 
% Run the following lines while the figure is still open:
idloc = get(gcf, 'UserData');
Xbrush = X(idloc, :);

%% Generate one outlier with 10 steps linearly spaced
outsteps = scout(x, pcamodel_ref, 'steps', 't2y', 40, 'spey', 40, 'nsteps', 10);
Xall = [x; outsteps.X];
obstag = [0; outsteps.tag];

figure('Name', 'PCA Model plot'), 
dscplot(Xall, pcamodel_ref, 'off', 1, 2, obstag, outsteps.step_spe, ...
    outsteps.step_t2);

figure('Name', 'PCA Model plot'), 
dscplot(Xall, pcamodel_ref, 'on', 1, 2, obstag, outsteps.step_spe, ...
    outsteps.step_t2);
%% Generate a series of outliers with 10 steps linearly and non-linearly spaced
gparam = [0.3, 0.5, 1, 1.5, 3];
Xall = x;
tagall = 0;
stepsall = [];
for g = 1:numel(gparam)
    outgamma = scout(x, pcamodel_ref, 'steps', 't2y', 20, 'spey', 20, ...
        'nsteps', 10, 'gt2', gparam(g), 'gspe', gparam(numel(gparam) -g + 1));
    Xall = [Xall; outgamma.X];
end
tagall = zeros(size(Xall, 1), 1);
figure('Name', 'Distance plot with non-linear steps'), 
distplot(Xall, pcamodel_ref, 'off');
%% Generate a grid of outliers
outgrid = scout(x, pcamodel_ref, 'grid', 't2y', 40, 'spey', 40, ...
    'nstepsspe', 2, 'nstepst2', 3, 'gspe', 3, 'gt2', 0.3);
Xall = [x; outgrid.X];
obstag = [0; outgrid.tag];

figure('Name', 'PCA Model plot'), 
dscplot(Xall, pcamodel_ref, 'off', 1, 2, obstag, outgrid.step_spe, ...
    outgrid.step_t2);

figure('Name', 'PCA Model plot'), 
dscplot(Xall, pcamodel_ref, 'on', 1, 2, obstag, outgrid.step_spe, ...
    outgrid.step_t2);