function Results = Unit_Unit_Correlation(spikes, windowLength, varargin)
% Unit_Unit_Correlation(spikes, windowLength,...)
%
% Computes a correlation between the firing rates of each unit-unit pair,
% binned by time. Auto-correlations and redundant correlations are saved as
% NaNs.
%
% Dependencies: Spike_Logical.m
%
% Inputs:   spikes              Nx1 cell of spike times, in s
%
%           windowLength        time bin of firing rate comparisons, in s
%
%           Optional            'Name', Value
%           'Plot'              boolean operator to plot (true)
%                               or not plot (false) results.
%                               Default is false.
%
% Output:   Results             NxN array of Pearson correlation (r)
%                               between (binned) firing rate of all
%                               unit-unit pairs.
%
% Contributed by Ryan Glanz (ryan-glanz@uiowa.edu)
% Last updated 10.28.20 by RG
%

%% Parameter input
params = inputParser;
params.addRequired('spikes', @iscell);
params.addRequired('windowLength', @isnumeric);
params.addParameter('Plot', false, @islogical);
params.parse(spikes, windowLength, varargin{:});

toPlot = params.Results.Plot;

%% Correlation
Results = nan(size(spikes, 1), size(spikes, 1));
prog = [];
for iA = 1:size(spikes, 1)
    for iB = 1:size(spikes, 1)
        if iA > iB
            aSpikes = spikes{iA};
            bSpikes = spikes{iB};
            
            % Logical matrix of spike times
            aLogical = Spike_Logical(aSpikes);
            bLogical = Spike_Logical(bSpikes);
            
            % Trim logical matrices
            minLength = min([length(aLogical), length(bLogical)]);
            minLength = minLength - mod(minLength, 1000*windowLength);
            aLogical = aLogical(1:minLength);
            bLogical = bLogical(1:minLength);
            
            % Bin spikes
            aBin = sum(reshape(aLogical, 1000*windowLength, []));
            bBin = sum(reshape(bLogical, 1000*windowLength, []));
            
            Results(iA, iB) = corr(aBin', bBin');
        else
            Results(iA, iB) = NaN;
        end
    end
    
    fprintf(repmat('\b', 1, numel(prog)))
    prog = sprintf('Unit %d of %d', iA, size(spikes, 1));
    fprintf(prog)
end
fprintf(repmat('\b', 1, numel(prog)))

%% Plot
if toPlot
    figure
    
    imagesc(Results)
    colormap(jet)
    c1 = colorbar;
    caxis([0, 1])
    
    xlabel('Units')
    ylabel('Units')
    ylabel(c1, 'Pearson correlation (r)')
end

end
