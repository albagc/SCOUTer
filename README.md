# Generation-of-outliers
Functions to simulate outliers according to the specifications in a PCA model.

- pcamb_classic: function to fit a PCA model with a given set of data. 
  Inputs : X (matrix with data), ncomp (number of PCs), alpha (type I risk to compute the UCLs for the SPE and T2) and preprocessing (string with possible values 'cent' or 'autosc' in order to indicate a mean centering or mean centering + unitary variance scaling).
  Outputs: pcamodel (struct with different fields containig the elements and information of the built PCA model).

- genoutX: function to generate outliers.
  Inputs : X (matrix with data that will be shifted), pcamodel (PCA model struct with the information of the PCA model according to which the new observations will be outlying), T2target (column vector with the T2 target values for the different rows in X) and SPEtarget (column vector with the SPE target values for the different rows in X).
  Outputs: X2 (matrix shifted with outlying observations as rows), T2X (original T2 value of the observations in X), SPEX (original SPE value of the observations in X).
  
- plotdist2: plot the distance-plot.
  Inputs: X (matrix with the observations), pcamodel (PCA model from which the distances will be calculated), mode (string with values 'new' or 'ref' depenging on if the data in X is the reference data set used for the PCA model bulding or new data that will be marked differently in the plot) and markeropt (optional argument with default values indicating the appearance of the points in the plot).
  Outputs: T2 (values for the T2 of the observations in X), SPE (values for the SPE of the observations in X), d1d2 (Line object with graphical properties of the points in the plot), p1 (Line object with graphical properties of the SPE UCL in the plot) and p2 (Line object with  graphical properties of the points in the plot).
  
- scoreplot2: plot the score plot.
  Inputs: X (matrix with the observations), pcamodel (PCA model from which the distances will be calculated), mode (string with values 'new' or 'ref' depenging on if the data in X is the reference data set used for the PCA model bulding or new data that will be marked differently in the plot), markeropt (optional argument with default values indicating the appearance of the points in the plot) and scoreopt (optional argument with default values indicating the components to be plotted and the parameted alpha for the confidence ellipsoid in the plot).
  Outputs: T (values for the scores T of the observations in X), t1t2 (Line object with graphical properties of the points in the plot) and ell (Line object with graphical properties of the ellipse in the plot).
