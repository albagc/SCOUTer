% exe_example
load exampleX
%% PCA-MB
pcamodel_ref = pcamb_classic(X, 2, 0.05, 'cent');
% Interactive plots
figure('Name', 'Score plot (interactive)'), scoreplot(X, pcamodel_ref);
figure('Name', 'Distance plot (interactive)'), distplot(X, pcamodel_ref);
% Switch off interactivity
figure('Name', 'Information about x2')
subplot(121), distplot(X, pcamodel_ref, zeros(size(X, 1), 1), 'off');
subplot(122), scoreplot(X, pcamodel_ref, zeros(size(X, 1), 1), 'off');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Generation of ONE outlier (one step):
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
indsel = randperm(size(X, 1), 1);
x = X(indsel, :);
out_x_both = scout(x, pcamodel_ref, 20, 20); % Shift SPE and T^2
out_x_t2 = scout(x, pcamodel_ref, 20, 'none'); % Shift in T^2
out_x_spe = scout(x, pcamodel_ref, 'none', 20); % Shift in SPE

Xall = [x; out_x_both.X; out_x_t2.X; out_x_spe.X];
obstag = [0; 1; 2; 3];
figure('Name', 'Score plot (interactive)'), 
scoreplot(Xall, pcamodel_ref, obstag);
figure('Name', 'Distance plot (interactive)'), 
distplot(Xall, pcamodel_ref, obstag);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Generate a whole SET of outliers (one step):
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%% Generate of one outlier with 20 STEPS linearly spaced:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
indsel = randperm(size(X, 1), 1);
x = X(indsel, :);
outsteps = scout(x, pcamodel_ref, 20, 20, 'nsteps', 20, 'mode', 'steps');

Xall = [x; outsteps.X];
obstag = [0; ones(20,1)];
figure('Name', 'Score plot (interactive)'), 
scoreplot(Xall, pcamodel_ref, obstag);
figure('Name', 'Distance plot (interactive)'), 
distplot(Xall, pcamodel_ref, obstag);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Generate of outliers with 20 STEPS linearly and non-linearly spaced:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Generate a grid of outlying sets (4 steps linearly spaced):
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
