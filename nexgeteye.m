function [X Y V chosentrials] = nexgeteye(varargin)
%SYNTAX
%        [x y v] = nexgeteye(param1, value1, param2, value2, ...)
%
%   or
%        [x y v] = nexgeteye(S)
%
% in which S is a structure with fieldnames given by the parameters below.
%
% Parameters can be:   Values:                            Default:
% 'Trial'              trials to include (vector)         all trials
% 'Signal'             Signals (cell array or vector)     all signals
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
% The outputs are the x- and y- eye-positions, as well as the eye-velocity.
% Included trials will represent the
% intersection of the criteria specified above.
%
% A second output argument is the vector of trials used.
%
% Created by WA, February, 2009

[BHV NEURO] = getactivedata;

[chosentrials P] = trialselector(varargin);

smoothwin = 10;
smoothtype = 'gauss';

%determine analog offset (trial start is assumed to be code 9, but that may
%have occurred several tens of ms after analog data logging had begun):
numtrials = length(BHV.CodeTimes);
aoffset = zeros(numtrials, 1);
trial_start_code = 9;
for i = 1:numtrials,
    cn = BHV.CodeNumbers{i};
    ct = BHV.CodeTimes{i};
    ao = ct(cn == trial_start_code);
    aoffset(i) = ao(1);
end

aoffset = aoffset(chosentrials);
ct = nexgetcodetime(chosentrials, P.startcode);
ct = ct + aoffset;
t1 = ct + P.startoffset;
t2 = t1 + P.duration - 1;

numtrials = length(chosentrials);
X = NaN*zeros(numtrials, P.duration);
Y = X;
V = X;

for t = 1:numtrials,
    eyedata = BHV.AnalogData{chosentrials(t)}.EyeSignal;
    x = eyedata(:, 1);
    y = eyedata(:, 2);
    dx = diff(x);
    dy = diff(y);
    v = sqrt((dx.^2) + (dy.^2)) * BHV.AnalogInputFrequency;
    v = smooth(v, smoothwin, smoothtype);
    v = cat(1, v, NaN);
    starttime = t1(t);
    endtime = t2(t);
    startindx = 1;
    endindx = endtime - starttime + 1;
    if starttime < 1,
        startindx = -starttime + 2;
        starttime = 1;
    end
    if endtime > length(x),
        endindx = endindx - (endtime - length(x));
        endtime = length(x);
    end
    X(t, startindx:endindx) = x(starttime:endtime)';
    Y(t, startindx:endindx) = y(starttime:endtime)';
    V(t, startindx:endindx) = v(starttime:endtime)';
end


