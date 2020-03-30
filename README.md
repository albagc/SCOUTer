# Generation-of-outliers
Functions to simulate outliers according to the specifications in a PCA model.

pcamb_classic: function to fit a PCA model with a given set of data. 
 - Inputs: 
    - X: data matrix of dimensions NxK with observations used for the PCA-MB
	- ncomp: integer indicating the number of Principal Components of the model.
	- alpha (optional): value of the Type I risk assumed for the Upper Control Limits (UCL) calculation. Default value set to alpha = 0.05.
	- prepro (optional): string indicating preprocessing applied to X, its possible values are 'cent' and 'autosc'. Default value set to 'autosc'.
 - Output: pcamodel (struct with different fields containig the elements and information of the built PCA model).
	- pcamodel.m = mean vector (1 x K).
	- pcamodel.s = mean vector (1 x K).
	- pcamodel.P = loading matrix (K x ncomp).
	- pcamodel.Pfull = loading matrix (K x K).
	- pcamodel.lambda = vector with variances of the scores (1 x ncomp).
	- pcamodel.limspe = Upper Control Limit (for alpha value) for the SPE.
	- pcamodel.limt2 = Upper Control Limit (for alpha value) for the T^2.
	- pcamodel.prepro = string indicating preprocessing applied to X.
	- pcamodel.ncomp = integer indicating the number of PCs of the model.
	- pcamodel.alpha = value of the Type I risk assumed for the UCL.
	- pcamodel.n = number of observations used in the PCA-MB.
	- pcamodel.S = covariance matrix of observations used in the PCA-MB.
	- pcamodel.limits_t = control limits for the scores with a confidence level (1-alpha)x100 % 

scout: function to generate outliers from a given observation or set of observations.
 - Inputs : 
	- X: data matrix with observations to be displayed in the distance plot.
	- pcamodel: struct with the information of the PCA model.
	- T2target: Hotelling's T^2 target value for each observation in X.
	- SPEtarget: SPE target value for each observation in X.
	optional Name-Value pair arguments:
	- mode: 'step' for simultaneous increment in SPE and T2, or 'grid' to generate datasets with all the combinations of SPEm and T2m. Default set to 'step'.
	- nsteps: integer indicating the number of steps from SPE_0 to SPE_M (or T^2). Default set to 1. 
	- gspe: gamma value tunning the linearity of the steps from SPE_0 to SPE_M. Default set to 1.
	- gt2: gamma value tunning the linearity of the steps from T20 to T2_M. Default set to 1.
 - Outputs: 
	- outscout (struct with fields containing information about the generated oultiers):
		- X: matrix with the shifted observations from X. Structure:
           	obs1 step1
           	obs2 step1
           	...  step1
           	obsN step1
           	obs1 step2
           	...  ...
           	obsN stepM
		- T2: column vector with the T^2 values of the observations in X.
	   	- SPE: column vector with the SPE values of the observations in X.
		- step (ONLY if mode = 'steps'): column vector with the intermediate step between {SPE,T2}0 and {SPE, T2}M.
		- step_spe (ONLY if mode = 'grid'): column vector indicating the step between SPE0 and SPEM.
		- step_t2 (ONLY if mode = 'grid'): column vector indicating the step between T20 and T2M.
	- SPE_0: vector with the initial SPE values.
	- T2_0: vector with the initial Hotelling's T^2 values.

distplot: function to display the distance plot of the observations according to a PCA model.
 - Inputs : 
	- X: data matrix with observations to be displayed in the distance plot.
	- pcamodel: struct with the information of the PCA model.
	- obstag (optional): column vector of integers indicating the group of each observation. Default value set to zeros(size(X,1),1).
	- inter (optional): string indicating the status of the plot interactivity. Default value set to 'on'.
 - Outputs: 
	- SPE: column vector with the Squared Prediction Error for each observation in X.
	- T2: column vector with the Hotelling's T^2 value for each observation in X.
	- ax0: handle with the graphical object containing the distance plot.
				
scoreplot: function to display the score plot of the observations according to a PCA model.
 - Inputs : 
	- X: data matrix with observations to be displayed in the distance plot.
	- pcamodel: struct with the information of the PCA model.
	- obstag (optional): column vector of integers indicating the group of each observation. Default value set to zeros(size(X,1),1).
	- inter (optional): string indicating the status of the plot interactivity. Default value set to 'on'.
	- scoreopt (optional): struct indicating the PCs whose scores will be used in the score plot. Default values are scoreopt.pc1 = 1 and scoreopt.pc2 = 2;
 - Outputs: 
	- T: matrix with the coordinates of each observation in the score plot..
	- ax0: handle with the graphical object containing the score plot.
