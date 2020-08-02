% Statistically Controlled OUTliers
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
% DEMO SCRIPT reproducing results from JSS publication. 
%% Matlab version adapted:
my = version('-release');
if str2double(my(1:4))<2020
    addpath('rprev2020')
else
    addpath('r2020')
end
%% Load data and build a PCA model
load exampleX
pcamodel_ref = pcamb_classic(X, 2, 0.05, 'cent');
pcaout = pcame(X, pcamodel_ref);
figure('Name', 'PCA Model for reference data set')
dscplot(X, pcamodel_ref, 'click', 'off');
%% Switch on interactivity
figure('Name', 'PCA Model plot'), 
dscplot(X, pcamodel_ref, 'click', 'on');
%% SPE and H-T2 information
% Find observation with maximum SPE and display its contributions
[~, imaxspe] = max(pcaout.SPE);
figure('Name', 'SPE and T2 information'),
obscontribpanel(pcaout, pcamodel_ref.limspe, pcamodel_ref.limt2, imaxspe);
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
dscplot(Xall, pcamodel_ref, 'click', 'on', 'obstag', obstag, ...
    'steps_spe', steps, 'steps_t2', steps);

%% Generate a set of outliers increasing only the T^2 (one step)
T2target = 40*ones(size(X, 1), 1);
Xextreme = scout(X, pcamodel_ref, 'simple', 't2y', T2target);
Xall = [X; Xextreme.X];
obstag = [zeros(size(X, 1), 1); Xextreme.tag];
figure('Name', 'PCA Model plot'), 
dscplot(Xall, pcamodel_ref, 'click', 'off', 'obstag', obstag, ...
     'steps_spe', Xextreme.step_spe, 'steps_t2', Xextreme.step_t2);

figure('Name', 'PCA Model plot'), 
dscplot(Xall, pcamodel_ref, 'click', 'on', 'obstag', obstag, ...
     'steps_spe', Xextreme.step_spe, 'steps_t2', Xextreme.step_t2);

%% Select the set by brushing observations
figure('Name', 'PCA Model plot'), 
dscplot(X, pcamodel_ref, 'click', 'off') % Reference data set (Brush points) 
% Run the following lines while the figure is still open:
idloc = get(gcf, 'UserData');
Xbrush = X(idloc, :);

%% Generate one outlier with 10 steps linearly spaced
outsteps = scout(x, pcamodel_ref, 'steps', 't2y', 40, 'spey', 40, 'nsteps', 10);
Xall = [x; outsteps.X];
obstag = [0; outsteps.tag];

figure('Name', 'PCA Model plot'), 
dscplot(Xall, pcamodel_ref, 'click', 'off', 'obstag', obstag, ...
     'steps_spe', outsteps.step_spe, 'steps_t2', outsteps.step_t2);

figure('Name', 'PCA Model plot'), 
dscplot(Xall, pcamodel_ref, 'click', 'on', 'obstag', obstag, ...
     'steps_spe', outsteps.step_spe, 'steps_t2', outsteps.step_t2);
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
distplot(Xall, pcamodel_ref, 'click', 'off');
%% Generate a grid of outliers
outgrid = scout(x, pcamodel_ref, 'grid', 't2y', 40, 'spey', 40, ...
    'nstepsspe', 2, 'nstepst2', 3, 'gspe', 3, 'gt2', 0.3);
Xall = [x; outgrid.X];
obstag = [0; outgrid.tag];

figure('Name', 'PCA Model plot'), 
dscplot(Xall, pcamodel_ref, 'click', 'off', 'obstag', obstag, ...
     'steps_spe', outgrid.step_spe, 'steps_t2', outgrid.step_t2);

figure('Name', 'PCA Model plot'), 
dscplot(Xall, pcamodel_ref, 'click', 'on', 'obstag', obstag, ...
     'steps_spe', outgrid.step_spe, 'steps_t2', outgrid.step_t2);