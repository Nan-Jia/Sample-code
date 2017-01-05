function [yhat,h2] = annPredictRegression(X, model)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [yhat,h2] = annPredict(X, model)
%
% Predicts using a simple 3-layer artificial neural network classifier, 
% typically fitted using annFit(),
% 
% INPUTS
% X           Matrix[nObservations,nFeatures(NOT incl. intercept/bias)].
%             Design matrix of features/predictors for each observation (usu. testing/validation set). 
% 
% model       Struct. Fitted model weights, associated values, from logisticRegressionFit(). Fields:
%   Theta       Vector[nWeights,1]. Fitted ANN weights
%   nClasses    Scalar. Number of classes for given classification problem
%   HiddenLayerSize Scalar. Number of units in ANN hidden layer
% 
% OUTPUTS
% yhat        Vector[nObservations,1].
%             Predicted class label for each observation, in set {1:nClasses}
% 
% h2          Matrix[nObservations,nClasses].
%             Output layer unit activation for each observation...might be interpreted as
%             as score for each class???
% NJ 2016-09-05 last modified for linear output node
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  K         = model.nClasses;         % #classes 
  [N,L1]    = size(X);                % #observations, #units in input layer (#features)
  L2        = model.HiddenLayerSize;  % #units in hidden layer

  % Reshape theta vector back into Theta1 and Theta2, the ANN layer weight matrices
  nW12      = L2*(L1+1);
  
  % Theta1  = matrix[hiddenLayerSize,inputLayerSize+1] implements layer1->2 transformation
  Theta1    = reshape(model.Theta(1:nW12), [L2 L1+1]);
  
  % Theta2  = matrix[nClasses,hiddenLayerSize+1] implements layer2->3 transformation
  Theta2    = reshape(model.Theta((nW12+1):end), [K L2+1]);

  
  %% Compute network activations
  % Layer 2 (hidden) activation (+ 1's column for bias units)
  h1        = sigmoid([ones(N,1) X] * Theta1');
  
  % Layer 3 (output) activation
  h2        = sigmoid([ones(N,1) h1] * Theta2');
  
  
  %% Select class corresponding to output unit w/ highest activation, for each observation
  yhat = (h2(:,1)*2-1) + 1i*(h2(:,2)*2-1);

end
