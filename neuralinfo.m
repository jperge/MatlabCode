function [I, p, H] = neuralinfo(R, varargin)
%SYNTAX:
%
%        [I, p, H] = neuralinfo(cellarray, [bootstrap_iterations])
%
% or
%
%        [I, p, H] = neuralinfo(Responses, Stimuli, [bootstrap_iterations])
%
% Calculates the information about a stimulus (in bits) given by the 
% distribution of firing rates provided in the first input (arranged
% according to [trials x time] operating along the first dimension).  If
% cell arrays are provided, it is assumed each cell corresponds to the
% responses for a single stimulus.  Otherwise, the second input should 
% provide a single vector of integer assignments, one for each trial.
%
% The last input is optional, and specifies the number of iterations to
% perform to calculate a p-value (the second output) for I.  This 
% bootstrapping is achieved by randomizing the assignment of stimuli to the 
% observed neural responses.
% 
% Information about a given stimulus is given by:
%
% Sum over i: P(r(i) | s) * log2 (P(r(i) | s) / P(r(i))
%
% Where P(r(i) | s) is the probability of a specific response (e.g., firing 
% rate) given a particular stimulus, and P(r(i)) is the overall probability 
% of that neural response across all stimuli.
%
% The overall information about all stimuli is the sum over stimuli.
%
% H is the response entropy, defined as:
%
% Sum over i: P(r(i) * log2 (P(r(i)))
%
% The information can be normalized as:
%
% I / H^2
%
% The current algorithm is designed to work with discrete values (e.g.,
% number of spikes within a window of a few 10s or hundreds of ms).
% Continuous data will lead to apparently high information content simply
% because any specific value may occur only rarely (e.g., due to continuous
% noise).  Such data should be binned into sensible ranges, before using it
% as input to this function.
%
% Furthermore, this code will work fastest when integer spike counts are
% provided.
%
% Created 5/11/12  --WA
% Modified 6/4/13  --WA

nits = 0;
p = [];
if ~iscell(R),
    if isempty(varargin),
        error('If the first input is not a cell, a second input must index assignments');
    end
    S = varargin{1}; %category ("stimulus") assignments
    if ndims(S) > 2 || min(size(S)) > 1,
        error('Category assignments must be provided in a one-dimensional vector');
    end
    if length(varargin) > 1,
        nits = varargin{2};
    end
    numstim = length(unique(S));
    if ndims(R) > 2,
        error('First input array must not exceed 2 dimensions');
    end
    if min(size(R)) == 1 && size(R, 2) > size(R, 1), 
        R = R';
    end
else
    numstim = length(R);
    X = cell(numstim, 1);
    for i = 1:numstim,
        if ndims(R{i}) > 2,
            error('Data within input cells cannot exceed 2 dimensions')
        else
            if min(size(R{i})) == 1 && size(R{i}, 2) > size(R{i}, 1),
                R{i} = R{i}';
            end
        end
        X{i} = i*ones(size(R{i}, 1), 1);
    end
    R = cat(1, R{:});
    S = cat(1, X{:});
    if ~isempty(varargin),
        nits = varargin{1};
    end
end

%%
allintegers = 1;
if any(any(round(R) ~= R)),
    allintegers = 0;
end

%%
numbins = size(R, 2);
N = size(R, 1);
ustim = fastunique(S);

i = zeros(numstim, 1);
h = zeros(numstim, 1);
n = zeros(numstim, 1);
I = zeros(1, numbins);
H = zeros(1, numbins);

for bnum = 1:numbins,
    r = R(:, bnum);
    if allintegers,
        uvals = fastunique(r); %so if firing rates vary independent of stimulus according to time in trial, keeps info relative to local FR variation
    else
        uvals = unique(r);
    end
    Pr = fasthist(r, uvals)/N; %normalized histogram of number of occurrences of each response value (i.e., a given # of spikes)
    for k = 1:numstim,
        Rs = r(S == ustim(k));
        n(k) = length(Rs);
        Prs = fasthist(Rs, uvals)/length(Rs);
        i(k) = nansum(Prs.*log2(Prs./Pr));
        h(k) = nansum(Pr.*log2(Pr));
    end    
    Ps = n/N;
    I(bnum) = sum(Ps.*i);
    H(bnum) = sum(Ps.*h);
end

if nits, %bootstrap
    if numel(nits) > 1 || nits ~= round(nits) || nits < 1,
        error('"bootstrap_iterations" must be a scalar positive integer');
    end
    
    Irand = zeros(nits, numbins);
    Hrand = zeros(nits, numbins);
    for i = 1:nits,
        Srand = S(randperm(N));
        Irand(i, :) = neuralinfo(R, Srand);
    end
    Imat = repmat(I, nits, 1);
    p = sum(Irand >= Imat)/nits;
    
end


return





%% FOR CONTINUOUS INPUTS:
% Creates histograms of response values using bins large enough to include
% several nearby unique values, that may be interleaved, giving the false
% impression of high information content simply because certain very
% specific response values may never occur more than once...

allinputs = cat(1, D{:});
uvals = unique(allinputs);

k = length(uvals)/10; %this factor determines how granular the data is assumed to be (how many chunks to average over for each histogram bin)
ustep = k * median(diff(uvals)); %using the median discounts outliers; this calculates the width of each bin
minu = min(uvals);
maxu = max(uvals);

uvec = minu:ustep:maxu + ustep; % + ustep to make sure each value is given an equal opportunity to have a bin, including highest value

H = cell(numstim, 1);
for i = 1:numstim,
    h = hist(D{i}, uvec);
    H{i} = h./sum(h); %normalize so size of each distribution is not factored into the results (assumes over-all, each class is equally likely)
end

allH = cat(1, H{:});

% numsteps = length(uvec);
% Entropy = zeros(1, numsteps);
% for i = 1:numsteps,
%     h = allH(:, i);
%     h = h(logical(h));
%     Entropy(i) = sum(h.*-log2(h));
% end
% Entropy = mean(Entropy);

% pSS = allH/numstim; %normalize to the number of inputs
% pSpikeRate = sum(pSS/sum(sum(pSS)));
% pSpikeRate = repmat(pSpikeRate, numstim, 1)/numstim;
% pStimulus = 1/numstim; %assumes each stimulus feature is equally likely (as promoted by the normalized histograms, above)
% pStimulus = pStimulus*ones(size(pSS))/numsteps;
% 
% MI = pSS.*log(pSS./(pSpikeRate.*pStimulus));
% MI = nansum(nansum(MI));

PR = allH/numstim;
PRS = zeros(size(PR));
for i = 1:numstim,
    PRS(i, :) = PR(i, :)/sum(PR(i, :));
end
PR = sum(PR);

I = zeros(numstim, 1);
for i = 1:numstim,
    I(i) = nansum(PRS(i, :).*log2(PRS(i, :)./PR));
end
I = mean(I);


return

%% Test Code
a{1} = ceil(20*(rand(100, 10))+0);
a{2} = ceil(20*(rand(100, 10))+1);
a{3} = ceil(20*(rand(100, 10))+2);
a{4} = ceil(20*(rand(100, 10))+3);
[I, p] = neuralinfo(a, 100)


%%
function H = fasthist(input, vals)
% assumes both input and vals are n x 1 vectors
% ~ 10x faster than built-in "hist" function...

vals = vals';
A = input(:, ones(size(vals)));
B = vals(ones(size(input)), :);
H = sum(A == B);

%%
function u = fastunique(input)
%assumes inputs are all integers

m = min(input) + 1;
input = input + m;
b(input) = 1;
c = (1:length(b))';
u = c(logical(b)) - m;





