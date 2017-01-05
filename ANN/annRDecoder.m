function [predictedTgts, popVectors] = annRDecoder(trainingX, trainingY, testX, tgtDirections)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [predictedTgts, popVectors] = annRDecoder(trainingX, trainingY, testX, targetY, tgtDirections)
%
% Artifical neural network regression decoder. See annFitRegression.m for
% more details.
%
% INPUTS:
% trainingX   Training data set (nTrainTrials, nFeatures)
% trainingY   Training labels (nTrainTrials, 1)
% testX       Testing data set (nTestTrials, nFeatures)
% tgtDirections  Directions of targets corresponding to labels (nLabels, 1)
% 
% OUTPUTS:
% predictedTgts (nTestTrials, 1) of predicted target labels
% popVectors  (nTestTrials,1) of continuous estimates of target direction for each test trial.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Train ANN-r model using conjugate gradient descent option
[model,yhat] = annFitRegression(trainingX, trainingY,tgtDirections, 'optMethod','conjugatedescent');

% Discretize continuous population vectors into one of 'nTgts' categorical saccade target direction
trainingPredictedTgts = popVector2Tgt(yhat, tgtDirections);
disp(['Training accuracy: ', num2str(100*sum(trainingPredictedTgts == trainingY)/length(trainingY))])

% Test ANN-r model prediction
[popVectors, h2] = annPredictRegression(testX, model);
 
% Discretize predicted trial pop vectors into one of 'nTgts' categorical saccade target directions
predictedTgts = popVector2Tgt(popVectors, tgtDirections);

% Convert predicted test-trial pop vectors to angles (in radians) 
popVectors  = angle(popVectors); 
disp(['Actual target: ', num2str(targetY), ', ann predicted: ', num2str(predictedTgts)])

end

function  predictedTgts = popVector2Tgt(popVectors, tgtDirections)
% function  predictedTgts = popVector2Tgt(popVectors, tgtDirections)
%
% Discretize population vectors into one of 'nTgts' categorical saccade target directions
%

nTestTrls = length(popVectors);
nTgts     = length(tgtDirections);
popVectors    = popVectors(:);      % Make sure popVectors are in a column vector
tgtDirections = tgtDirections(:)';  % Make sure tgtDirections are in a row vector

% Express popVectors and tgtDirections in complex form (if not already)
if isreal(popVectors), popVectors = exp(1i*popVectors); end
if isreal(tgtDirections), tgtDirections = exp(1i*tgtDirections); end

d = abs(angle( repmat(popVectors,[1 nTgts]) ...       % Absolute circular distance between each pop vector 
     ./ repmat(tgtDirections, [nTestTrls 1]) ));      %  and each target direction
[~,predictedTgts] = min(d, [], 2);                    % Find tgt dir at min distance from each trial pop vector = predicted tgt      

predictedTgts(isnan(popVectors)) = NaN;

end