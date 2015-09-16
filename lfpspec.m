function [output mag phas] = lfpspec(input, fmax)
% assumes each bin is 1 ms.

fstep = 2;
frange1 = 0:fstep:fmax;
frange2 = 1:fstep:fmax+1;
linput = length(input);

output1 = filter_lfp(input, frange1);
output1 = squeeze(output1)';
output2 = filter_lfp(input, frange2);
output2 = squeeze(output2)';
output = zeros(fmax, linput);
output(frange1(1:end-1)+1, :) = output1;
output(frange2(1:end-1)+1, :) = output2;

if nargout > 1,
    [phas mag] = phase_vector(output);
end



