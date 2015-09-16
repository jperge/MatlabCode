function [s, chosentrials, signames] = nexgetspikeJP(signame, startcode, startoffset, duration, TE, blkNum, trialPerf, LE)
%SYNTAX
%        [s chosentrials signames] = nexgetspike(param1, value1, param2, value2, ...)
%
%   or
%        [s chosentrials signames] = nexgetspike(S)
%
% in which S is a structure with fieldnames given by the parameters below.
%
% Parameters can be:   Values:                              Default:
% 'Trial'              trials to include (vector)           all trials
% 'Signal'             Signals (cell array or vector)       all neurons
% 'Channel'            Electrode (channel) number (vector)  all channels
% 'TrialError'         trial-errors to include (vector)     all trial errors
% 'Condition'          conditions to include (vector)       all conditions
% 'BlockNumber'        blocks to include (vector)           all blocks
% 'BlockIndex'         blocks (ordinal number) (vector)     all blocks
% 'StartTime'          absolute time in ms (scalar)         0 ms
% 'EndTime'            absolute time in ms (scalar)         end of last trial
% 'StartCode'          start code (scalar)                  start_trial
% 'StartOffset'        start offset (scalar)                0 ms
% 'Duration'           duration in ms (scalar)              5000 ms
%
% Note that you can also use a field from the NEURO.NeuronInfo structure
% (e.g., 'Area') to specify which signals to retrieve.
%
% The output, "s" is the 3D matrix of spike occurrences, arranged as:
% trial x time x signal number.  Included trials will represent the
% intersection of the criteria specified above.
%
% A second output argument is the vector of trials used.
%
% A third output is the list of signal names.
%
% If more than one signal-selection criterion is specified (e.g., 'Signal',
% 'Channel' or any field from the AncillaryText info file), the union of the
% neurons selected through each is returned (sorted in ascending named order).
%
% Created by WA, June, 2008
% Last modified 5/30/2013  --WA

s = [];
signames = '';

[BHV, NEURO] = getactivedata;

% trialPerf = varargin{14};
% LE        = varargin{16};
% blkNum    = varargin{12};
% 
[~, P] = trialselector('Signal', signame, 'StartCode', startcode, 'StartOffset', startoffset, 'Duration', duration, 'TrialError', TE, 'BlockNumber', blkNum);
chosentrials = find(BHV.BlockNumber==blkNum & trialPerf==LE);

if isempty(chosentrials),
    return
end

[SigIndx signames] = signalselector(P);
if ~any(SigIndx),
    return
end

fsig = find(SigIndx);

[~, abstime] = nexgetcodetime(chosentrials, P.startcode);
t1 = abstime + P.startoffset;
t2 = t1 + P.duration - 1;

numtrials = length(chosentrials);
numsigs = length(fsig);
s = zeros(numtrials, P.duration, numsigs, 'uint8');

neuronlabels = fieldnames(NEURO.Neuron);
for t = 1:numtrials,
    starttime = t1(t);
    endtime = t2(t);
    for k = 1:numsigs,
        signum = fsig(k);
        st = NEURO.Neuron.(neuronlabels{signum});
        st = st(st >= starttime & st < endtime) - starttime + 1;
        s(t, st, k) = 1;
    end
end

if numsigs == 1,
    s = squeeze(s);
end


