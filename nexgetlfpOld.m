function [s, chosentrials, signames, spikes] = nexgetlfp(varargin)
%
% Loads LFP data from the currently active file, as set by the function
% opendatafile.
%
% If 'Signal' is a neuron (e.g., 'sig002a'), the LFP channel associated
% with that neuron will be loaded.  Otherwise, will load the corresponding
% AD channel indexed by a scalar (or channels indexed by a vector), or
% directly referred to by a string (e.g., 'AD15').
%
% If no signal is specified, all LFP channels with neurons will be loaded.
%
% THIS CURRENTLY REQUIRES THAT THE LFP DATA IS NOT FRAGMENTED.
%
%SYNTAX
%        s = nexgetlfp(param1, value1, param2, value2, ...)
%
%   or
%        s = nexgetlfp(S)
%
% in which S is a structure with fieldnames given by the parameters below.
%
% Parameters can be:   Values:                            Default:
% 'Trial'              trials to include (vector)         all trials
% 'Signal'             Signals (cell array or vector)     all signals with neurons.
% 'Channel'            Electrode (channel) number         all signals with neurons (supercedes 'Signal' if specified)
% 'TrialError'         trial-errors to include (vector)   all trial errors
% 'Condition'          conditions to include (vector)     all conditions
% 'BlockNumber'        blocks to include (vector)         all blocks
% 'BlockIndex'         blocks (ordinal number) (vector)   all blocks
% 'StartTime'          absolute time in ms (scalar)       0 ms
% 'EndTime'            absolute time in ms (scalar)       end of last trial
% 'StartCode'          start code (scalar)                start_trial
% 'StartOffset'        start offset (scalar)              0 ms
% 'Duration'           duration in ms (scalar)            5000 ms
%
% Parameters can also be fields from the ancillarydata.txt file for the
% corresponding neurons (for example, if multiple areas are recorded and a
% field exists called "Area" for each corresponding neuron, you can specify
% 'Area' as a parameter followed by a string or numeric argument corresponding 
% to one of the potential values it can take.  The LFP from the channel(s) on 
% which qualifying neurons reside will then be retrieved.
%
% The output, "s" is the 3D matrix of LFP data, arranged as:
% trial x time x channel number.  Included trials will represent the
% intersection of the criteria specified above.
%
% The second output variable is the vector of trials used.
%
% The third output variable contains the names of the AtoD channels used.
%
% The fourth output variable is the spikes found on that channel (arranged
% according to [trials x milliseconds x channels] ) in which each isolated neuron is
% given a unique number (e.g., time bins without spikes are "0", those with
% spikes from the first neuron are labeled "1", those from the second are
% "2" etc.).
%
% Created by WA, May, 2011
% Last modified by WA, 5/22/12

[~, NEURO] = getactivedata;

readspikes = 0;
if nargout > 3,
    readspikes = 1;
end

[chosentrials P] = trialselector(varargin);
if isempty(chosentrials),
    s = [];
    signames = [];
    return
end

lfplabels = fieldnames(NEURO.LFP);
lfpchans = NEURO.LFPInfo.Channel;

[SigIndx] = signalselectorLfp(P);
if ~any(SigIndx),
    return
end
P.signal = lfplabels(SigIndx);

[~, abstime] = nexgetcodetime(chosentrials, P.startcode);
t1 = abstime + P.startoffset;

signames = cell(length(P.signal), 1);
numtrials = length(chosentrials);
numchan = length(P.signal);
s = zeros(numtrials, P.duration, numchan, 'single');
sourcechan = zeros(numchan, 1);

fid = fopen(NEURO.File);
for k = 1:numchan,
    d = NEURO.LFP.(P.signal{k});
    signames(k) = P.signal(k);
    sourcechan(k) = d.Channel;
    for t = 1:numtrials,
        starttime = t1(t);
        offset = d.Offset + 2*(d.Frequency / 1000) * starttime;
        fseek(fid, offset, -1);
        lfp = fread(fid, [1 P.duration], 'int16')*d.ADtoMV + d.MVOffset;
        s(t, :, k) = lfp;
    end
end

fclose(fid); 
s = squeeze(s);
if readspikes,
    spikes = zeros(size(s), 'uint8');
    for k = 1:length(sourcechan), %loop in order to merge spikes from the same channel, "1" for first neuron, "2" for second, etc.
        spiketemp = nexgetspike('Channel', sourcechan, 'StartCode', P.startcode, 'StartOffset', P.startoffset, 'Duration', P.duration);
        if ndims(spiketemp) > 2,
            for j = 1:size(spiketemp, 3),
                spiketemp(:, :, j) = spiketemp(:, :, j).*j;
            end
        end
        spikes(:, :, k) = sum(spiketemp, 3);
    end
end
