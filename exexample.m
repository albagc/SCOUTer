% exe_example
load exampleX
%% Build model and illustrate model information
pcamodel_ref = pcamb_classic(X, 2, 0.05, 'cent');

figure('Name', 'Distance plot'), distplot(X, pcamodel_ref);

figure('Name', 'Score plot'), scoreplot(X, pcamodel_ref);
%% Generate outlier. Plot the reference data set and the outlier
indsel = randperm(size(X, 1), 1);
x2 = scout(X(indsel, :), pcamodel_ref, 20, 20);
% Prepare data for the plot
Xall = [X;x2]; % Concatenate both datasets (reference and outlier)
obs_id = [zeros(size(X,1),1);1]; % Ccolumn vector of 0s and 1s for the 
% reference and outliying observations respectively

% Interactive plots
figure('Name', 'Distance plot'), distplot(Xall, pcamodel_ref, obs_id);
figure('Name', 'Score plot'), scoreplot(Xall, pcamodel_ref, obs_id);
% Just plots without interaction (argument 'off')
figure('Name', 'Information about x2')
subplot(121),distplot(Xall, pcamodel_ref, obs_id, 'off');
subplot(122),scoreplot(Xall, pcamodel_ref, obs_id, 'off');

% Interactive polots
figure('Name', 'Distance plot'), distplot(x2, pcamodel_ref, 1);
figure('Name', 'Score plot'), scoreplot(x2, pcamodel_ref, 1);
% Just distance plot and scoreplot with information about the data
figure('Name', 'Information about x2')
subplot(121),distplot(x2, pcamodel_ref, 1, 'off');
subplot(122),scoreplot(x2, pcamodel_ref, 1, 'off');
%% Generate outlier with 5 steps and plot
[example_steps] = scoutsteps(X(indsel, :), pcamodel_ref, 20, 20, 5, 1);
% Prepare data for the plot
X_all = [X;example_steps.X]; % Concatenate both datasets 
obsid_steps = [zeros(size(X,1),1);ones(size(example_steps.X,1),1)];
% Ccolumn vector of 0s and 1s for the reference and outliying observations 
% respectively

% Plots
figure('Name', 'Distance plot'), distplot(X_all, pcamodel_ref, obsid_steps);
figure('Name', 'Score plot'), scoreplot(X_all, pcamodel_ref, obsid_steps);
% Just distance plot and scoreplot with information about the data
figure('Name', 'Information about x2')
subplot(121),distplot(X_all, pcamodel_ref, obsid_steps, 'off');
subplot(122),scoreplot(X_all, pcamodel_ref, obsid_steps, 'off');
%% Generate gradient of outliers
xsel = X(indsel, :);
% Vary only the SPE in 5 steps
example_steps_g1spe = scoutsteps(xsel, pcamodel_ref, 'none', 20, 5, 1);
% Vary only the T^2 in 5 steps
example_steps_g1t2 = scoutsteps(xsel, pcamodel_ref, 20, 'none', 5, 1);
% Vary both the SPE and T^2 in 5 steps
example_steps_g1spet2 = scoutsteps(xsel, pcamodel_ref, 20, 20, 5, 1);

% Prepare data for the plot
X_all = [X; example_steps_g1spe.X; example_steps_g1t2.X; ...
    example_steps_g1spet2.X;]; % Concatenate both datasets 
obsid_steps = [zeros(size(X,1),1); ones(size(example_steps_g1spe.X,1),1);...
    2*ones(size(example_steps_g1t2.X,1),1); ...
    3*ones(size(example_steps_g1spet2.X,1),1)]; % Ccolumn vector of 0s and 
% 1s for the reference and outliying observations respectively

% Plot
figure('Name', 'Distance plot'), distplot(X_all, pcamodel_ref, obsid_steps);
figure('Name', 'Score plot'), scoreplot(X_all, pcamodel_ref, obsid_steps);
% Just distance plot and scoreplot with information about the data
figure('Name', 'Information about x2')
subplot(121),distplot(X_all, pcamodel_ref, obsid_steps, 'off');
subplot(122),scoreplot(X_all, pcamodel_ref, obsid_steps, 'off');
%% Generate set of observations with the same properties
% Three steps from reference SPE and T^2 to SPE = T^2 = 20 for all obs.
nsteps = 3;
spetarg = 20*ones(size(X,1),1);
t2targ = spetarg;
example_steps_setg1 = scoutsteps(X, pcamodel_ref, t2targ, spetarg, 3, 1);
obsid_steps = reshape(repmat(0:nsteps,size(X,1),1), (nsteps+1)*size(X,1), 1);
% Ccolumn vector of 0s and 1s for the reference and outliying observations
% respectively
figure('Name', 'Distance plot')
distplot(example_steps_setg1.X, pcamodel_ref, obsid_steps);
figure('Name', 'Score plot')
scoreplot(example_steps_setg1.X, pcamodel_ref, obsid_steps);
% Just distance plot and scoreplot with information about the data
figure('Name', 'Information about x2')
subplot(121),distplot(example_steps_setg1.X, pcamodel_ref, obsid_steps, 'off');
subplot(122),scoreplot(example_steps_setg1.X, pcamodel_ref, obsid_steps, 'off');
%% Generate grid of SPE and T^2 
nx = size(X,1);
example_grid_g1 = scoutgrid(X, pcamodel_ref, 20*ones(nx,1),...
    20*ones(nx,1), 4, 0.5);
spelevels = example_grid_g1.spe_factor;
t2levels = example_grid_g1.t2_factor;
% One subplot for each level of SPE variation

u_spe = unique(spelevels);
%%
figure('Name', 'Grid results'),
for i = 1:length(u_spe)
    X_spestep = example_grid_g1.X(spelevels==u_spe(i),:);
    t2_tag = t2levels(spelevels==u_spe(i),:);
    subplot(2,5,i), scoreplot(X_spestep, pcamodel_ref, t2_tag, 'off');
    title(strcat('Score plot SPE_{',string(u_spe(i)),'}'))
    legend('off')
    subplot(2,5,5+i), distplot(X_spestep, pcamodel_ref, t2_tag, 'off'); 
    hold on
    plot(linspace(0,25,500),pcamodel_ref.limspe*ones(500,1),...
        'r--','linewidth',1.2,'HandleVisibility','off')
    plot(pcamodel_ref.limt2*ones(500,1),linspace(0,25,500),...
        'r--','linewidth',1.2,'HandleVisibility','off')
    ylim([0,25]),xlim([0,25])
    title(strcat('Distance plot SPE_{',string(u_spe(i)),'}'))
    legend('off')
end
%%
legend('show')
legend({'UCL','T^2_0','T^2_1','T^2_2','T^2_3','T^2_4'},...
    'Location','north','Orientation','Horizontal','NumColumns', 6)
%% SPE and T^2 vs velocity (gamma) parameter
nx = size(X,1);
gammapar = [0.3,0.5,0.75,1,1.5,2,3,5];
spe = {};
t2 = {};
spe_p50 = [];
spe_p2_5 = [];
spe_p97_5 = [];
t2_p50 = [];
t2_p2_5 = [];
t2_p97_5 = [];
for g = 1:length(gammapar)
    stat_gamma.(strcat('gamma_',string(g))) = scoutgrid(X, ...
        pcamodel_ref, 20*ones(nx,1),20*ones(nx,1), 20, gammapar(g));
    spe{g} = reshape(stat_gamma.(strcat('gamma_',string(g))).SPE, 50, 21);
    t2{g} = reshape(stat_gamma.(strcat('gamma_',string(g))).T2, 50, 21);
    spe_p50 = [spe_p50; median(spe{g})];
    spe_p2_5 = [spe_p2_5; prctile(spe{g}, 2.5)];
    spe_p97_5 = [spe_p97_5; prctile(spe{g}, 97.5)];
    
    t2_p50 = [t2_p50; median(t2{g})];
    t2_p2_5 = [t2_p2_5; prctile(t2{g}, 2.5)];
    t2_p97_5 = [t2_p97_5; prctile(t2{g}, 97.5)];  
end
%%
figure,
subplot(121)
for i = 1:size(spe_p50,1)
%     fill([1:21,fliplr(1:21)], [spe_p2_5(i,:), fliplr(spe_p97_5(i,:))],'b',...
%         'FaceAlpha', 0.2, 'EdgeColor', 'none'); hold on
    plot(spe_p50(i,:),'b', 'linewidth',1.2), 
    text(4 + i, 1.2*spe_p50(i,4 + i), ...
        strcat('\gamma=',string(gammapar(i)))), hold on
end
grid on
xlim([1,21]),xlabel('step'),ylabel('SPE'),
title('SPE from SPE_0 to SPE_{target}')

subplot(122)
for i = 1:size(t2_p50,1)
%     fill([1:21,fliplr(1:21)], [t2_p2_5(i,:), fliplr(t2_p97_5(i,:))],'b',...
%         'FaceAlpha', 0.2, 'EdgeColor', 'none'); hold on
    plot(t2_p50(i,:),'b', 'linewidth',1.2), 
    text(4 + i, 1.2*t2_p50(i,4 + i), ...
        strcat('\gamma=',string(gammapar(i)))), hold on
end
grid on
xlim([1,21]),xlabel('step'),ylabel('T^2'),
title('T^2 from T^2_0 to T^2_{target}')
