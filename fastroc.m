function [a pval x y] = fastroc(input1, input2, varargin)
%SYNTAX:
%        [a pval x y] = fastroc(input1, input2, rectify_flag, bootstrap_iterations, tail)
%
%Receiver Operating Characteristic (ROC) curve for the distribution of
%values in the two input distributions.  Ignores NaN values.
%
%To save time, input checking is not performed. An error is generated if
%the inputs are not two vectors.  Inputs are also converted to "single"
%precision.
%
%If 'bootstrap_iterations' is specified, a bootstrap is calculated and the
%p-value calculated from the bootstrap distribution is returned in a second
%output argument.
%
%The optional argument "tail" determines the sort of p-value returned:
%
%To compare if input1 > input2, set the tail = 1 (default), and the p-value will
%reflect a one-tailed test.  To compare whether input1 ~= input2, set the 
%rectify_flag = 2, and the p-value will be adjusted to reflect a two-tailed test.
%
%Setting the rectify flag affects the resulting area: if rectified, the area 
%will always be > 0.5.
%
%created 3/12/10  -WA (can operate 2-10x as fast as "roc", depending on the
%size of the inputs.
%modified 5/11/11 -WA (switched from matrix point-by-point to cumsum
%method, ~5-10x faster than previous (depends on size of inputs) and can
%handle much larger vectors without running into memory issues.


%eliminate NaNs:
input1 = single(input1(:));
input2 = single(input2(:));

input1 = input1(~isnan(input1));
input2 = input2(~isnan(input2));
pval = NaN;

if isempty(input1) || isempty(input2),
    a = NaN;
    return
end

n1 = length(input1);
n2 = length(input2);

% OLD CODE USING MATRICES FOR PAIRWISE COMPARISONS OF ALL POSSIBLE VALUE PAIRS
% m1 = input1';
% m2 = input2;
% m1 = m1(ones(n2, 1), :);
% m2 = m2(:, ones(1, n1));
% a1 = sum(sum(m1 > m2)); %rate limiting step
% a2 = sum(sum(m1 == m2));
% aref = (a1 + (0.5*a2))/(n1 * n2);
% y = NaN;
% x = NaN;

n = n1 + n2;
nrev = n:-1:1;
input = [input1; input2];
revinput = input(nrev);
[~, indx] = sort(input);
indx = indx <= n1;
y1 = cumsum(indx)/n1;
x1 = cumsum(~indx)/n2;
[~, indx] = sort(revinput);        %Re-sorting using reversed order then
indx = n + 1 - indx;               %taking indices relative to the end
indx = indx <= n1;                 %of the array will balance out the 
y2 = cumsum(indx)/n1;              %preferential sorting of ties, so the
x2 = cumsum(~indx)/n2;             %average of the two values is the true
x = (x1 + x2)/2;                   %ROC.
y = (y1 + y2)/2;
a = trapz(y, x);

% figure
% hold on
% plot(x1, y1, 'r');
% plot(x2, y2, 'b');
% plot(x, y, 'k')

if ~isempty(varargin),
    rflag = varargin{1};
    if rflag, %rectify
        if a < 0.5,
            a = 1 - a;
        end
    end
    if length(varargin) > 1 && varargin{2}, % bootstrap
        tail = 1;
        if length(varargin) > 2,
            tail = varargin{3};
            if numel(tail) > 1 || (tail ~= 1 && tail ~= 2),
                error('Optional argument "tail" must equal 1 or 2');
            end
        end
        nits = varargin{2};
        c = cat(1, input1, input2);
        p = rand(n1 + n2, nits);
        [~, where] = sort(p);
        c = c(where);
        revc = c(nrev, :);
        
        [~, indx] = sort(c);
        indx = indx <= n1;
        y1 = cumsum(indx)/n1;
        x1 = cumsum(~indx)/n2;
        [~, indx] = sort(revc);
        indx = n + 1 - indx;
        indx = indx <= n1;
        y2 = cumsum(indx)/n1;
        x2 = cumsum(~indx)/n2;
        rx = (x1 + x2)/2;
        ry = (y1 + y2)/2;

        ra = sum(diff(ry).*(rx(2:n, :) + rx(1:n-1, :))/2); %because trapz doesn't work on two matrices
        if tail == 1,
            pval = sum(ra > a)/nits;
        else
            pval = (sum(ra > a | ra < 1 - a))/nits;
        end
    end
end


