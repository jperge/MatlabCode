function [output numbins] = binspikes(s, binsize, stepsize)
% SYNTAX:
%        [output numbins] = binspikes(spikes, binsize, stepsize)
%
% Creates sliding bin array of average spike rates for each trial.
% "spikes" must be a binary array, arranged as: (trials, milliseconds).
% "binsize" and "stepsize" are in milliseconds.
%
% A third dimension can be used for additional signal matrices (e.g.,
% additional simultaneously-recorded neurons).

[numtrials duration numsigs] = size(s);
numbins = floor(duration/stepsize) - ceil(binsize/stepsize) + 1;
output = zeros(numtrials, numbins, numsigs);

for signum = 1:numsigs,
    for thisbin = 1:numbins,
        t1 = (thisbin*stepsize) - stepsize + 1;
        t2 = t1 + binsize - 1;
        output(:, thisbin, signum) = sum(s(:, t1:t2, signum), 2);
    end
end

if numsigs == 1,
    output = squeeze(output);
end
