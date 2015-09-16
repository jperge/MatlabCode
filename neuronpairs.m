function [n1 n2 indx1 indx2 n1Area n2Area n1n2Distance chan1 chan2 lfp1 lfp2 lfpchan1 lfpchan2] = neuronpairs(ctype)
%SYNTAX:
%        [n1 n2 indx1 indx2 n1Area n2Area n1n2distance chan1 chan2 lfp1 lfp2 lfpchan1 lfpchan2] = neuronpairs(type)
%
%Returns neuron pairs (by signal name and index) for a specified "type" of
%relationship.  The input "type" can be:
%
% 'All'                 all neuron pairs in the currently active file
% 'CrossChannel'        all neuron pairs excluding those on the same channel
% 'CrossArea'           only neuron pairs recorded across areas
% 'ByArea'              neuron pairs recorded within the same area
% 'CrossChannelByArea'  neuron pairs across channels but within an area
%
%Note that to use "CrossArea" there must be a field in the
%AncillaryData.txt file called "Area."
%
%To compute a distance between neurons (in mm), there must be fields in the
%AncillaryData.txt file called "Position_AP" (=X), "Position_DV" (=Y) and
%"Position_Depth" (=Z).  Currently assumes depth is # of turns with 3 turns
%~= 1mm.
%
%The last two pairs of output arguments return the LFP names and LFP
%channels of those LFP signals that also match the specified criteria.
%Note that this list of LFP pairs includes only LFP channels on which
%neurons were recorded.
%
%Created by WA, 6/19/13
%Modified to include LFPs 11/18/13 --WA

if ~ischar(ctype),
    error('"Type" input must be a character string corresponding to ''All'', ''CrossChannel'', ''CrossArea'' or ''CrossChannelbyArea''')
end

[~, NEURO] = getactivedata;

neuronlabels = fieldnames(NEURO.Neuron);
channel = NEURO.NeuronInfo.Channel;
fn = fieldnames(NEURO.NeuronInfo);
fArea = strcmpi(fn, 'area');
if any(fArea),
    brainarea = NEURO.NeuronInfo.(fn{fArea});
else
    brainarea = '';
end
fXpos = strcmpi(fn, 'Position_AP'); %expand the possibilities later...
fYpos = strcmpi(fn, 'Position_DV');
fZpos = strcmpi(fn, 'Position_Depth');
if any(fXpos) && any(fYpos) && any(fZpos),
    Xpos = NEURO.NeuronInfo.(fn{fXpos});
    Ypos = NEURO.NeuronInfo.(fn{fYpos});
    Zpos = NEURO.NeuronInfo.(fn{fZpos});
    Xpos = cat(1, Xpos{:});
    Ypos = cat(1, Ypos{:});
    Zpos = cat(1, Zpos{:})/3; %Currently, position_depth = # of turns, with 3 turns ~= 1mm.
else
    Xpos = [];
    Ypos = [];
    Zpos = [];
end

if strcmpi(ctype, 'all'),
    pairtype = 1;
elseif strcmpi(ctype, 'crosschannel'),
    pairtype = 2;
elseif strcmpi(ctype, 'crossarea'),
    pairtype = 3;
elseif strcmpi(ctype, 'byarea'),
    pairtype = 4;
elseif strcmpi(ctype, 'crosschannelbyarea')
    pairtype = 5;
else
    error('Unrecognized input option');
end

if isempty(brainarea) && pairtype > 2,
    error('No "Area" field found (should be created in AncillaryInfo.txt)');
end

n = length(neuronlabels);
n1 = cell(n*n, 1);
n2 = cell(n*n, 1);
indx1 = zeros(n*n, 1);
indx2 = zeros(n*n, 1);
n1Area = cell(n*n, 1);
n2Area = cell(n*n, 1);
n1n2Distance = NaN(n*n, 1);
chan1 = zeros(n*n, 1);
chan2 = zeros(n*n, 1);

count = 0;
for x = 1:n-1,
    for y = x+1:n,
        takethis = 0;
        if pairtype == 1, %all
            takethis = 1;
        elseif pairtype == 2, %crosschannel
            if channel(x) ~= channel(y),
                takethis = 1;
            end
        elseif pairtype == 3, %crossarea
            if ~strcmp(brainarea(x), brainarea(y)),
                takethis = 1;
            end
        elseif pairtype == 4, %byarea
            if strcmpi(brainarea(x), brainarea(y)),
                takethis = 1;
            end
        elseif pairtype == 5, %crosschannelbyarea
            if channel(x) ~= channel(y) && strcmp(brainarea(x), brainarea(y)),
                takethis = 1;
            end
        end
        if takethis,
            count = count + 1;
            n1(count) = neuronlabels(x);
            n2(count) = neuronlabels(y);
            indx1(count) = x;
            indx2(count) = y;
            n1Area(count) = brainarea(x);
            n2Area(count) = brainarea(y);
            chan1(count) = channel(x);
            chan2(count) = channel(y);
            if ~isempty(Xpos) && strcmpi(brainarea(x), brainarea(y)),
                n1n2Distance(count) = sqrt((Xpos(x)-Xpos(y))^2 + (Ypos(x)-Ypos(y))^2 + (Zpos(x) - Zpos(y))^2);
            end
        end
    end
end

n1 = n1(1:count);
n2 = n2(1:count);
indx1 = indx1(1:count);
indx2 = indx2(1:count);
n1Area = n1Area(1:count);
n2Area = n2Area(1:count);
n1n2Distance = n1n2Distance(1:count);
chan1 = chan1(1:count);
chan2 = chan2(1:count);

%get unique LFP combinations that also fit criteria (using only LFP chans
%with recorded neurons).
p = [chan1 chan2];
p = unique(p, 'rows');
p = p(p(:, 1) ~= p(:, 2), :);

lfpchan1 = p(:, 1);
lfpchan2 = p(:, 2);

lfpnames = fieldnames(NEURO.LFP);
nlfp = length(lfpnames);
lfpchans = zeros(nlfp, 1);
for i = 1:nlfp,
    lfpchans(i) = NEURO.LFP.(lfpnames{i}).Channel;
end
highestchan = max(lfpchans);
slottedLFPnames = cell(highestchan, 1); %cannot assume that list of LFP channels (lfpchans) easily lines up with lfpchan1 or lfpchan2.
slottedLFPnames(1:highestchan) = {'Empty'}; %seeing this in the output would indicate no such LFP signal exists on that channel
slottedLFPnames(lfpchans) = lfpnames;

lfp1 = slottedLFPnames(lfpchan1); %now lfpchan1 and lfpchan2 directly index into the named LFP signals on those channels
lfp2 = slottedLFPnames(lfpchan2);





