function [model,yhat] = annFitRegression(X, y,tgtDirections, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [model,yhat] = annFitRegression(X, y, varargin)
% 
% Fits a simple 3-layer artificial neural network regression to training data. 
% 
% Options include method used to
% fit model {'quasi-newton','conjugatedescent','gradientdescent','irls'}.
% 
% 
% INPUTS
% X           Matrix[nObservations,nFeatures].
%             Design matrix of features/predictors for each training set observation.
% 
% y           Vector[nObservations,2].
%             Actual class label for each training data observation.
%             Should be given as label in {1:nClasses} for each observation.
%             y will be decomposed into the X, and Y components of the
%             complex coordinate.
% 
% OPTIONAL INPUTS: (given as name/value pairs in varargin)
% hiddenLayerSize Scalar. (optional; default = input layer size)
%             Number of network units in hidden layer
% 
% lambda      Scalar. (optional; default = 0 [no regularization])
%             Regularization hyperparameter
%             0 = no regularization, larger lambda = stronger regularization
% 
% optMethod   String. (optional; default = 'conjugatedescent')
%             Optimizer to use to fit logistic model:
%             'gradientdescent' : Standard gradient descent w/ learning rate alpha/N
%                                 using my own gradientDescent() func
%             'conjugatedescent': Conjugate descent using open source func fmincg()
%             'quasi-newton'    : Quasi-Newton method, using Matlab fminunc() func
% 
% alpha       Scalar. (optional; default = 100)
%             Sets learning rate for optMethod=='gradientdescent'. 
%             Note: actual learning rate used is alpha/N. 
% 
% OUTPUTS
% model       Struct. Fitted model parameters and associated values. Fields include:
%   Theta       Vector[nWeights,1]. Fitted ANN weights
%   nClasses    Scalar. Number of classes for given classification problem
%   HiddenLayerSize Scalar. Number of units in ANN hidden layer
% 
% yhat        Vector[nObservations,1].
%             Predicted classes for each observation, in set {1:nClasses}
% 
% REFERENCES
%             
%             Andrew Ng _Machine Learning_ Coursera class
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  [nObs,inpLayerSize]  = size(X);     % #observations, #features = input layer size
  % nClasses  = max(y);                 % #classes
  nOutputNode = 2;
  %% Process function arguments
  defaults  = { 'hiddenLayerSize',inpLayerSize, ...                 % Default = input/hidden layers same size
                'lambda',         0, ...                            % Default = no regularization
                'optMethod',      'conjugatedescent', ...           % Default = Conjugate Decscent
                'alpha',          100 };                            % Default = 100/N
  [hiddenLayerSize,lambda,optMethod,alpha] = processArgs(defaults(1:2:end), defaults(2:2:end), varargin{:});

  % NJ 2016-09-05: modified for 2 output nodes - real and imag components
  % of complex angle
  Y         = zeros(nObs, 2);
  
  complexDirs = exp(1i*tgtDirections(y));
  % Real component goes to Y(:,1), linearly mapped from [-1 1] to [0 1]
  Y(:,1) = (real(complexDirs)+1)/2;
  % Imaginary component goes to Y(:,2), linearly mapped from [-1 1] to [0
  % 1]
  Y(:,2) = (imag(complexDirs)+1)/2;
  
  %% Set up loss function for ANN fit

  % Set up logistic loss function as anonymous func to pass to optimizer
  lossFunc 	= @(theta) (annLossRegression(X, Y, theta, lambda));

  % Initialize ANN weights to small random values
  thetaInit1  = sub_initRandomWeights(inpLayerSize, hiddenLayerSize);
  thetaInit2  = sub_initRandomWeights(hiddenLayerSize, nOutputNode);
  % Unroll weights into single long vector for full ANN model
  thetaInit   = [thetaInit1(:); thetaInit2(:)];
 
  % Initialize optimization options
  options     = sub_setOptions(optMethod, nObs, alpha);
  
    
  %% Fit ANN model using given optimization method
  switch lower(optMethod)
  case 'conjugatedescent';
    [thetaHat, lossHistory, iter]  = fmincg(lossFunc, thetaInit, options);  
  case 'gradientdescent';  
    [thetaHat, lossHistory, iter]   = gradientDescent(lossFunc, thetaInit, options.Alpha, options.TolFun, options.MaxIter);   
  case 'quasi-newton';
    thetaHat  = fminunc(lossFunc, thetaInit, options);
  otherwise;  
    error('annFit: Optimization method ''%s'' not coded up yet');
  end
  disp(['Iter: ',num2str(iter)])
  disp(['Loss history: ',num2str(lossHistory(end-10:end))])

dloss   = abs(lossHistory(2:end) - lossHistory(1:end-1));
avgloss = (abs(lossHistory(2:end)) + abs(lossHistory(1:end-1)) + eps)/2;  
figure;
subplot(2,1,1); plot(lossHistory,'o'); title([num2str(iter) ' iterations']);
subplot(2,1,2); plot(dloss./avgloss,'o');

  
  % Save to output struct
  model = struct('Theta', thetaHat,  'nClasses', nOutputNode,  'HiddenLayerSize', hiddenLayerSize, 'continuousOutput', true);
    
  %% Predicted classes for training set
  if nargout > 1
    yhat  = annPredictRegression(X, model);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Set options for optimization function
function  options = sub_setOptions(optMethod, nObs, alpha)
  options = optimset('GradObj','on', 'MaxIter',150000, 'TolFun',1e-4, 'Display','off');  % 'MaxIter',100  stoppingCrit
  switch lower(optMethod)
  case 'quasi-newton';    options = optimset(options, 'LargeScale','off');
  case 'gradientdescent'; options.Alpha = alpha/nObs;
                          
                          % options.TolFun= options.TolFun/nObs;
  end
end


%% Initialize small random weights for a layer of given input,output size
function W = sub_initRandomWeights(L_in, L_out)
% INPUTS
% L_in    Scalar. # incoming connections for weight matrix to initialize
% L_out   Scalar. # outgoing connections for weight matrix to initialize
% 
% OUTPUTS
% W       Matrix[L_out,L_in+1]. Randomly initialized weight matrix, 
%         including extra row for "bias units"

  epsilon = sqrt(6./(L_in + L_out));
  W       = 2*epsilon*(rand(L_out, 1 + L_in) - 0.5);
end

