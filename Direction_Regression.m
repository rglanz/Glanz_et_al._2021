function Results = Direction_Regression(responseStrength, responseStrengthShuffled, varargin)
% Results = Direction_Regression(responseStrength, responseStrengthShuffled,...)
%
% Computes the regression of a unit's response strength with respect to
% movement direction (Figure 5E). Also computes the 99% confidence
% interval of shuffled data.
%
% Inputs       responseStrength             1xN array of response strength
%                                           values (in sps) with respect to
%                                           anterior, posterior, medial,
%                                           and lateral directions
%
%              responseStrengthShuffled     MxN array of response strength
%                                           values (as above) in which M
%                                           represents the number of
%                                           shuffles and N represents the
%                                           response strength in sps
%
%              Optional                     'Name', Value
%               'Plot'                      boolean operator to plot (true)
%                                           or not plot (false) results.
%                                           Default is false.
%
% Output       Results.aPSlope              difference in response strength
%                                           (posterior - anterior)
%              Results.aPShuffledMean       difference in response strength
%                                           for shuffled data (posterior -
%                                           anterior)
%              Results.aPConfidenceInterval 99% confidence interval of
%                                           shuffled data (posterior -
%                                           anterior)
%              Results.mLSlope              difference in response strength
%                                           (lateral - medial)
%              Results.mLShuffledMean       difference in response strength
%                                           for shuffled data (lateral -
%                                           medial)
%              Results.mLConfidenceInterval 99% confidence interval of
%                                           shuffled data (lateral -
%                                           medial)
%
%
% Contributed by Ryan Glanz (ryan-glanz@uiowa.edu)
% Last updated 5.27.21 by RG
%

%% Parameter input
params = inputParser;
params.addRequired('responseStrength',@isnumeric);
params.addRequired('responseStrengthShuffled',@isnumeric);
params.addParameter('Plot', false, @islogical);
params.parse(responseStrength, responseStrengthShuffled, varargin{:});

toPlot = params.Results.Plot;

%% Regresssion (observed data)
anteriorPosteriorSlope = responseStrength(2) - responseStrength(1);
medialLateralSlope = responseStrength(4) - responseStrength(3);

%% Regression (shuffled data)
aPShuffled = diff(responseStrengthShuffled(:, 1:2), 1, 2);  % Mx1 slope
aPShuffledMean = mean(aPShuffled);
aPShuffledSEM = std(aPShuffled) / sqrt(numel(aPShuffled));
aPConfidenceInterval = 2.58 * aPShuffledSEM;    % 99% confidence interval

mLShuffled = diff(responseStrengthShuffled(:, 3:4), 1, 2);  % Mx1 slope
mLShuffledMean = mean(mLShuffled);
mLShuffledSEM = std(mLShuffled) / sqrt(numel(mLShuffled));
mLConfidenceInterval = 2.58 * mLShuffledSEM;    % 99% confidence interval

%% Output structure
Results.aPSlope = anteriorPosteriorSlope;
Results.aPShuffledMean = aPShuffledMean;
Results.aPConfidenceInterval = aPConfidenceInterval;
Results.mLSlope = medialLateralSlope;
Results.mLShuffledMean = mLShuffledMean;
Results.mLConfidenceInterval = mLConfidenceInterval;

%% Plot (optional)
if toPlot
    axisLimits = max([ceil(max([Results.aPSlope, Results.mLSlope])),...
        abs(floor(min([Results.aPSlope, Results.mLSlope])))]);
    axisValues = -axisLimits:axisLimits;
    
    figure
    hold on
    
    h1 = scatter(Results.mLSlope, -Results.aPSlope, 100, 'filled',...
        'MarkerEdgeColor', 'k', 'MarkerFaceColor', [0.2, 0.2, 1]);
    h2 = fill([axisValues, fliplr(axisValues)], [(-Results.aPShuffledMean -...
        Results.aPConfidenceInterval)*ones(size(axisValues)),...
        fliplr((-Results.aPShuffledMean + Results.aPConfidenceInterval)*...
        ones(size(axisValues)))], [0.9, 0.9, 0.9], 'EdgeColor', 'none');
    fill([(Results.mLShuffledMean - Results.mLConfidenceInterval)*...
        ones(size(axisValues)), fliplr((Results.mLShuffledMean +...
        Results.mLConfidenceInterval)*ones(size(axisValues)))],...
        [axisValues, fliplr(axisValues)], [0.9, 0.9, 0.9],...
        'EdgeColor', 'none')
    
    legend([h1, h2], {'Model', 'Shuffled Data'})
    
    xlabel('Medial-Lateral (mm)')
    ylabel('Posterior-Anterior (mm)')
end
