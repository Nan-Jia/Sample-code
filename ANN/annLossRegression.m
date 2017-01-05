function [loss,grad] = annLossRegression(X, Y, theta, lambda, checkGrad)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [loss,grad] = annLossRegression(X, Y, theta, lambda)
% 
% Computes loss function for simple 3-layer artificial neural network regression decoder.
% Returns loss and also (optionally) its gradient.
% 
% INPUTS
% X           Array[nObservations,nFeatures=inputLayerSize].
%             Design matrix of features/predictors for each training set observation. 
% 
% Y           Array[nObservations,2].
%             X and Y components of target directions in complex coordinate
% 
% theta       Vector[nWeights,1].
%             Set of fitted weights for all ANN layers, unrolled into a vector.
%
% lambda      Scalar. (default = 0 = no regularization)
%             If model includes regularization, this is the regularization hyperparameter.
%             0 = no regularization; larger = stronger regularization
% 
% OUTPUTS
% loss        Scalar. ANN loss function evaluated for given weights and data.
% 
% OPTIONAL OUTPUTS (only returned if requested by calling function)
% grad        Vector[nWeights,1]. 
%             Gradient of loss function at evaluated model parameters.
%             Only used for gradient-based optimization methods.
% REFERENCES
%             
%             Andrew Ng _Machine Learning_ Coursera class
%
% NJ 2016-09-05: last modified for linear output node
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %% Process function arguments
  if (nargin < 4) || isempty(lambda),   lambda    = 0;      end
  if (nargin < 5) || isempty(checkGrad), checkGrad = 0;     end
  
  if nargout > 1, doGrad    = true;
  else            doGrad    = false;
  end  
    
  K         = size(Y,2);              % #classes 
  [N,L1]    = size(X);                % #observations, #units in input layer (#features)      
  L2        = (length(theta) - K)/(L1 + 1 + K); % #units in hidden layer (formula based on known organization of theta arg)

  
  % Reshape theta back into Theta1 and Theta2, the ANN layer weight matrices
  nW12      = L2*(L1+1);
  
  % Theta1  = matrix[hiddenLayerSize,inputLayerSize+1] implements layer1->2 transformation
  Theta1    = reshape(theta(1:nW12), [L2 L1+1]);
  
  % Theta2  = matrix[nClasses,hiddenLayerSize+1] implements layer2->3 transformation
  Theta2    = reshape(theta((nW12+1):end), [K L2+1]);

  % todo: remove ones concatenation here and below & normalize rest of code?
  Xin     = [ones(N,1), X];                     % Add column of 1's for bias units

  
  %% Forward propagation
  % Layer 2 (hidden) activation (+ 1's column for bias units) 
  A2    = [ones(N,1), sigmoid(Xin*Theta1')];  
  
  % Layer 3 (output) activation 
  A3    = sigmoid(A2*Theta2');                    

  
  %% Cost function
  h_X   = A3;
  
  % NJ 2016-09-05: modified for linear output node, loss function is sum of
  % squared error since we cannot use cross-entropy loss for continuous
  % function.
  % loss  = -(1/N)*sum(sum(Y.*log(h_X) + (1 - Y).*log(1 - h_X)));
  loss  = .5*sum(sum((Y-h_X).^2));
  
  % Regularization component of loss function
  if lambda ~= 0
    loss  = loss + (lambda/(2*N))*(sum(sum(Theta1(:,2:end).^2)) + sum(sum(Theta2(:,2:end).^2)));
  end
  
  if ~doGrad, return;  end      % If we don't need the gradient, we are done
  
  %disp(num2str(loss))
  %% Backpropagation
  % Backpropagate errors
  d3    = h_X - Y;
  d2 = d3 .* A3 .*(1-A3) * Theta2 .*A2 .*(1-A2);
  
  %% Compute weight gradients
  % NJ 2016-09-05: modified for quadratic loss function 
  
  Theta2_grad = (d3 .* A3 .*(1-A3))'*A2;
  Theta1_grad = d2(:,2:end)'*Xin;
  %was:  Theta2_grad = (1/N)*(d3'*A2);
  %was:  Theta1_grad = (1/N)*(d2(:,2:end)'*Xin);
  
  % Regularization component of gradient
  if lambda ~= 0  
    Theta2_grad = Theta2_grad + (1/N)*([zeros(K,1), lambda*Theta2(:,2:end)]);
    Theta1_grad = Theta1_grad + (1/N)*([zeros(L2,1), lambda*Theta1(:,2:end)]);
  end
  
  % Unroll gradients -> vector[nWeights,1]
  grad  = [Theta1_grad(:); Theta2_grad(:)];
  
  % Gradient checking to make sure back prop gradient estimation is close
  if checkGrad
   gradApprox = sub_gradientChecking(X,Y,theta);
   gradDiffMean = mean(abs(gradApprox-grad));
   gradDiffVar = std(abs(gradApprox-grad));
   disp(['gradient approximation diff mean: ', num2str(gradDiffMean), ', std: ', num2str(gradDiffVar)]);
   disp(['Loss: ', num2str(loss)])
  end
end

function gradApprox = sub_gradientChecking(X,Y,theta)
% Gradient checking to make sure back propagation is implemented correctly
    gradApprox = zeros(size(theta));
    epsilon = 1e-4;
    for i = 1:length(theta)
        thetaPlus = theta;
        thetaPlus(i) = thetaPlus(i) + epsilon;
        thetaMinus = theta;
        thetaMinus(i) = thetaMinus(i) - epsilon;
        JPlus = annLossRegression(X,Y,thetaPlus);
        JMinus = annLossRegression(X,Y,thetaMinus);
        gradApprox(i) = ( JPlus - JMinus )/(2*epsilon);
    end
end