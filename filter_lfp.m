function output = filter_lfp(lfp, frange)
% SYNTAX:
%        output = filter_lfp(lfp, filter_pass_range_Hz)
%
% Band-pass filtering for LFP signals.
%
% The input "lfp" should be a vector or a matrix with signals in rows.
% It is assumed that each element corresponds to 1 ms.
%
% "filter_pass_range_Hz" is at least a two-element vector with the min and max
% frequencies (intervening values will be ingored, and assumed continuous).
%
% For example:
%
%       output = filter_lfp(lfp, [0 4 8 14 30 70])
% 
% will produce 5 rows of output for a single signal input, corresponding to
% approximately the delta, theta, alpha, beta and gamma frequency ranges.
%
% Created 2001 -WA
% Last modified May, 2011 -WA
%
% See also: phase_vector, vector_sum

if ndims(lfp) == 2 && min(size(lfp)) == 1,
    n = length(lfp);
    lfp = lfp(:)';
else
    n = size(lfp, 2);
end

numsignals = size(lfp, 1);
numf = length(frange)-1;
output = zeros(numsignals, n, numf);
scale = n/1000; %assume one data point per millisecond

for i = 1:numf,
    fmin = frange(i);
    fmax = frange(i+1);
    fmin = round(fmin*scale);
    if fmin == 0, fmin = 1; end
    fmax = round(fmax*scale);
    if fmax >= n, fmax = n-1; end
    thisrange = fmin:fmax;
    filt = zeros(1, n);
    filt(thisrange) = 1;
    filt(n-thisrange) = 1;
    filt = filt(ones(numsignals, 1), :);

    F = fft(lfp, [], 2);
    output(:, :, i) = real(ifft(F.*filt, [], 2));
end

return
%% TEST CODE
% Can you reconstruct the original signal from its band-passed parts?
% NOTE: signal will be very close, but not perfect, likely due to
% overlapping frequency edges in the bandpass components.

figure
%opendatafile;
%s = nexgetlfp('Signal', 1, 'StartCode', 23, 'StartOffset', -1500, 'Duration', 5000, 'TrialError', 0);
plot(s(1, :), 'k');
hold on
count = 0;
fs = zeros(100, size(s, 2));
for i = 0:5:500,
    count = count + 1;
    fs(count, :) = filter_lfp(s(1, :), [i i+5]);
end
plot(sum(fs), 'r');



