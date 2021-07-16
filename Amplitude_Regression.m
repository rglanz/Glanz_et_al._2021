function Results = Amplitude_Regression(responseStrength, responseStrengthShuffled, varargin)
% Results = Amplitude_Regression(responseStrength, responseStrengthShuffled,...)
%
% Computes log-linear regression of a unit's response strength with respect
% to movement amplitude (Figure 4B). Also computes the 99% confidence
% interval of shuffled data.
%
% Inputs        responseStrength            1xN array of response strength
%                                           values (in sps) with respect to
%                                           number of amplitude bins
%
%               responseStrengthShuffled    MxN array of response strength
%                                           values (as above) in which M
%                                           represents the number of
%                                           shuffles and N represents the
%                                           response strength in sps
%
%               Optional                    'Name', Value
%               'AmplitudeBins'             1xN array of amplitude bins in
%                                           mm (default is [1, 2, 4, 8, 16]
%
%               'Plot'                      boolean operator to plot (true
%                                           or 1) or not plot (false or 0)
%                                           results. Default is false.
%
% Output        Results.amplitudeBins       amplitudeBins input
%               Results.responseStrength    responseStrength input
%                                           (observed data)
%               Results.predictedCurve      response strength values
%                                           predicted by model
%               Results.modelFit            r^2 value of the model (fit)
%               Results.shuffledMean        mean values of the shuffled
%                                           data
%               Results.confidenceInterval  99% confidence interval of the
%                                           shuffled data (to be added to
%                                           or subtracted from the mean)
%
% Contributed by Ryan Glanz (ryan-glanz@uiowa.edu)
% Last updated 5.27.21 by RG
%

%% Parameter input
params = inputParser;
params.addRequired('responseStrength',@isnumeric);
params.addRequired('responseStrengthShuffled',@isnumeric);
params.addParameter('AmplitudeBins', [1, 2, 4, 8, 16], @isnumeric);
params.addParameter('Plot', false, @islogical);
params.parse(responseStrength, responseStrengthShuffled, varargin{:});

amplitudeBins = params.Results.AmplitudeBins;
toPlot = params.Results.Plot;

%% Regression (observed data)
regressionValues = polyfit(log10(amplitudeBins),...
    responseStrength, 1);   % [slope, intercept]
predictedCurve = polyval(regressionValues,...
    log10(amplitudeBins));   % data to plot

sumSquaresRegression = sum((responseStrength - predictedCurve) .^2);
sumSquaresTotal = sum((responseStrength - nanmean(responseStrength)) .^2);

modelFit = 1 - (sumSquaresRegression / sumSquaresTotal);    % r^2 value

%% Regression (shuffled data)
nShuffles = size(responseStrengthShuffled, 1);

shuffledCurve = zeros(size(responseStrengthShuffled));
for iShuffle = 1:nShuffles
    shuffledValues = polyfit(log10(amplitudeBins),...
        responseStrengthShuffled(iShuffle, :), 1);   % [slope, intercept]

    shuffledCurve(iShuffle, :) = polyval(shuffledValues,...
        log10(amplitudeBins));   % data to plot
end

shuffledMean = mean(shuffledCurve);
shuffledSEM = std(shuffledCurve) /...
    sqrt(size(shuffledCurve, 1));    % standard error of the mean
confidenceInterval = 2.58 * shuffledSEM; % 99% confidence interval

%% Output structure
Results.amplitudeBins = amplitudeBins;
Results.responseStrength = responseStrength;
Results.predictedCurve = predictedCurve;
Results.modelFit = modelFit;
Results.shuffledMean = shuffledMean;
Results.confidenceInterval = confidenceInterval;

%% Plot (optional)
if toPlot
    figure
    hold on
    
    plot(Results.amplitudeBins, Results.responseStrength, 'LineWidth',...
        2, 'Color', 'k')
    plot(Results.amplitudeBins, Results.predictedCurve, 'LineWidth',...
        2, 'Color', [0, 0, 0.7])
    fill([Results.amplitudeBins, fliplr(Results.amplitudeBins)],...
        [Results.shuffledMean - Results.confidenceInterval,...
        fliplr(Results.shuffledMean + Results.confidenceInterval)],...
        [0, 0, 0.7], 'EdgeColor', 'none', 'FaceAlpha', 0.2)
    
    xlabel('Movement amplitude (mm)')
    ylabel('Response strength (sps)')
    
    legend({'Observed Data', 'Model', 'Shuffled Data'},...
        'location', 'northwest')
end

end
