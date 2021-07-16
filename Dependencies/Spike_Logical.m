function logicalSpikes = Spike_Logical(spikes)
% Spike_Logical(spikes)
%
% Converts an index of spike times (in s) to a logical matrix (in ms).
%
% Input     spikeIndex         index of spike times (in s)
%
% Output    logSpikes          logical index of spike times (in ms)
%
% Contributed by Ryan Glanz (ryan-glanz@uiowa.edu)
% Last updated 10.28.20 by RG
%

%% Check for spike at time 0
spikes(spikes <= 0) = .001;

% Logical index
logicalSpikes = zeros(1, round(1000*spikes(end)));   % Convert s to ms
logicalSpikes(round(1000*spikes)) = 1;

logicalSpikes = logical(logicalSpikes);
end