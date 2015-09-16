function [trialtime abstime] = nexgetcodetime(trials, codenumber, varargin)
%SYNTAX:
%        [trialtime abstime] = nexgetcodetime(trials, codenumber, [instance])
%

[BHV NEURO] = getactivedata;

if isempty(varargin),
    cinstance = 1;
else
    cinstance = varargin{1};
end

tstart = NEURO.TrialTimes(trials);
tend = tstart + NEURO.TrialDurations(trials);

numtrials = length(trials);
abstime = zeros(numtrials, 1);
trialtime = zeros(numtrials, 1);
for t = 1:numtrials,
    cindex = (NEURO.CodeTimes >= tstart(t) & NEURO.CodeTimes <= tend(t));
    cnumbers = NEURO.CodeNumbers(cindex);
    ctimes = NEURO.CodeTimes(cindex);
    ct = ctimes(cnumbers == codenumber);
    if length(ct) < cinstance,
        abstime(t) = NaN;
        trialtime(t) = NaN;
    else
        abstime(t) = ct(cinstance);
        trialtime(t) = abstime(t) - tstart(t);
    end
end
