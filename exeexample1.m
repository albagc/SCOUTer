% exe_example
% Preliminar step: load data and build a PCA model
load exampleX
pcamodel_ref = pcamb_classic(X, 2, 0.05, 'cent');

% Project the data on the PCA model and visualize.
% Interactive plots let click an observation to display more information
% about its error vector and its contribution to the T^2.
figure('Name', 'Score plot (interactive)'), scoreplot(X, pcamodel_ref);
figure('Name', 'Distance plot (interactive)'), distplot(X, pcamodel_ref);
% Switch off interactivity in order to position the handle as prefered in a
% figure.
figure('Name', 'Information about x2')
subplot(121), distplot(X, pcamodel_ref, zeros(size(X, 1), 1), 'off');
subplot(122), scoreplot(X, pcamodel_ref, zeros(size(X, 1), 1), 'off');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Generation of ONE outlier (one step).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% An observation is chosen randomly from X and the scout.m function is used
% in order to shift it according to the specified target values for the SPE
% and T^2. In this demo we set 3 scenarios, varying independently and
% simultaneously the pair of statistics, setting a target value of 20.
indsel = randperm(size(X, 1), 1);
x = X(indsel, :);
out_x_both = scout(x, pcamodel_ref, 20, 20); % Shift SPE and T^2
out_x_t2 = scout(x, pcamodel_ref, 20, 'none'); % Shift in T^2
out_x_spe = scout(x, pcamodel_ref, 'none', 20); % Shift in SPE
% In order to recognize with different markers each shift, all observations
% are vertically concatenated in Xall. Then, the obstag vector is created,
% assigning for each row (obsevation) of Xall, a different tag number. This
% enables the assignment of different markers to each tag ID.
Xall = [x; out_x_both.X; out_x_t2.X; out_x_spe.X];
obstag = [0; 1; 2; 3];
figure('Name', 'Score plot (interactive)'), 
scoreplot(Xall, pcamodel_ref, obstag);
figure('Name', 'Distance plot (interactive)'), 
distplot(Xall, pcamodel_ref, obstag);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Generate a whole SET of outliers (one step).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Following the previous example, now the simulation is generalized from a
% single observation, to a set of observations which will present the 
% specifications for SPE ant T^2.
n = size(X, 1);
% Shift SPE and T^2
out_X_both = scout(X, pcamodel_ref, 20*ones(n, 1), 20*ones(n, 1)); 
out_X_t2 = scout(X, pcamodel_ref, 20*ones(n, 1), 'none'); % Shift in T^2
out_X_spe = scout(X, pcamodel_ref, 'none', 20*ones(n, 1)); % Shift in SPE

Xall = [X; out_X_both.X; out_X_t2.X; out_X_spe.X];
obstag = [zeros(n, 1); ones(n, 1); 2*ones(n, 1); 3*ones(n, 1)];
figure('Name', 'Score plot (interactive)'),
scoreplot(Xall, pcamodel_ref, obstag);
figure('Name', 'Distance plot (interactive)'), 
distplot(Xall, pcamodel_ref, obstag);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Generate of one outlier with 20 STEPS linearly spaced.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In this example it is included an intermediate step between the initial
% values {SPE, T^2} and the target ones, which is the incremental variation
% of the SPE or/and the T^2. There are two new parameters to set:
%   - The number of m steps to perform until reaching the target values 
%   for each statistic. 
%   - The spacing between steps gamma, which tunes the linearity of the
%   spacing. If any value is provided, a linear spacing (gamma = 1) is
%   performed.
indsel = randperm(size(X, 1), 1);
x = X(indsel, :);
outsteps = scout(x, pcamodel_ref, 20, 20, 'nsteps', 20, 'mode', 'steps');
% The following graphs distinguish between the reference observation and
% the shifted ones, visualizing their linear spacing.
Xall = [x; outsteps.X];
obstag = [0; ones(20,1)];
figure('Name', 'Score plot (interactive)'), 
scoreplot(Xall, pcamodel_ref, obstag);
figure('Name', 'Distance plot (interactive)'), 
distplot(Xall, pcamodel_ref, obstag);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Generate of outliers with 20 STEPS linearly and non-linearly spaced.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This section performs different shifts returning as a plot the evolustion
% of the statistics along the shift steps, for different values of the
% gamma parameter in each statistic.
gparam = [0.3, 0.5, 0.75, 1, 1.5, 2, 3, 5];
Xall = x;
SPEgamma = [];
T2gamma = [];
for g = 1:length(gparam)
    [outsteps, spe0, t20] = scout(x, pcamodel_ref, 20, 20, 'nsteps', ...
        20, 'mode', 'steps', 'gspe', gparam(g), 'gt2', gparam(g));
    Xall = [Xall; outsteps.X];
    SPEgamma = [SPEgamma, [spe0; outsteps.SPE]];
    T2gamma = [T2gamma, [t20; outsteps.T2]];
end

figure('Name', 'Steps in statistics'),
subplot(121),
for g = 1:length(gparam)
    plot(SPEgamma(:,g), 'bsq-'), hold on
    text(5 + g, 1.05*SPEgamma(6 + g, g), strcat('\gamma = ', ...
        string(gparam(g))), 'FontSize', 8, ...
        'Rotation', 40)
end
xlim([0,22])
xlabel('steps'), ylabel('SPE'), title('SPE curve with different \gamma')
subplot(122),
for g = 1:length(gparam)
    plot(T2gamma(:,g), 'bsq-'), hold on
    text(5 + g, 1.05*T2gamma(6 + g, g), strcat('\gamma = ', ...
        string(gparam(g))), 'FontSize', 8, ...
        'Rotation', 40)
end
xlim([0,22])
xlabel('steps'), ylabel('T^2'), title('T^2 curve with different \gamma')

% This is a second scenario where different gamma values are used to
% control the spacing of each statistic.
Xall_2 = x;
gparam2 = [0.3, 0.5, 1, 1.5, 3];
SPEgamma = [];
T2gamma = [];
for g = 1:length(gparam2)
    [outsteps, spe0, t20] = scout(x, pcamodel_ref, 20, 20, 'nsteps', ...
        20, 'mode', 'steps', 'gspe', gparam2(g), 'gt2', gparam2(end-g+1));
    Xall_2 = [Xall_2; outsteps.X];
    SPEgamma = [SPEgamma, [spe0; outsteps.SPE]];
    T2gamma = [T2gamma, [t20; outsteps.T2]];
end

figure('Name', 'Curve distance plot')
for g = 1:length(gparam2)
    plot(T2gamma(:, g), SPEgamma(:, g), 'bsq-'), hold on
    text(2.75*g-1, 1.3*SPEgamma(5 + g, g), {strcat('\gamma_{SPE} = ', ...
        string(gparam2(g))), strcat('\gamma_{T^2} = ', ...
        string(gparam2(end - g + 1)))}, 'FontSize', 9)
end
xlim([0, 21]), ylim([0, 21])
xlabel('T^2'), ylabel('SPE'), title('Curves for different \gamma pairs')

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Generate a grid of outlying sets (4 steps linearly spaced).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Finally, a last example is simulated. In this case, instead of increasing
% in a step-wise joint manner both the SPE and the T^2, a grid of steps is
% created. This implies simulating all possible combinations of pairs for
% the {SPE, T^2} along their increments. Thus, instead of having M new
% observations where M is the number of steps, a set of MxM observations is
% created for all combinations of both statistics. 
% A grid with 4 steps is simulated, with steps linearly spaced.
nsteps = 4;
outgrid = scout(X, pcamodel_ref, 50, 20, 'nsteps', nsteps, 'mode', 'grid');
obstag = reshape(repmat([0:nsteps], n, 1), (nsteps+1)*n, 1);
% Different subplots for each SPE level, and different markers for each T^2
% level
figure('Name','Grid data'),
for i = 1:nsteps
    Xspe_level = outgrid.X(outgrid.step_spe == i, :);
    Xall_level = [X; Xspe_level];
    subplot(2, nsteps, i),
    scoreplot(Xall_level, pcamodel_ref, obstag, 'off');
    title(strcat('Score plot (SPE_', string(i),')'))
    legend off
    subplot(2, nsteps, i + nsteps),
    distplot(Xall_level, pcamodel_ref, obstag, 'off');
    hold on
    plot(linspace(0,51,500),pcamodel_ref.limspe*ones(500,1),...
        'r--','linewidth',1.2,'HandleVisibility','off')
    plot(pcamodel_ref.limt2*ones(500,1),linspace(0,25,500),...
        'r--','linewidth',1.2,'HandleVisibility','off')
    xlim([0, 51]), ylim([0, 21]), legend off
    title(strcat('Distance plot (SPE_', string(i),')'))
end
