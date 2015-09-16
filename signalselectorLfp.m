function [SigIndx] = signalselectorLfp(P)
%
% Created by WA, 5/30/2013


[~, NEURO] = getactivedata;

%neuronlabels = fieldnames(NEURO.Neuron);
neuronlabels = fieldnames(NEURO.LFP);

if isfield(P, 'signal'),
    if ischar(P.signal),
        P.signal = {P.signal};
    elseif iscell(P.signal),
        if length(P.signal) > 1 && size(P.signal, 2) > size(P.signal, 1),
            P.signal = P.signal';
        end
    else
        P.signal = neuronlabels(P.signal);
    end
elseif ~isfield(P, 'signal') && ~isfield(P, 'channel'),
    P.signal = neuronlabels;
end

if isfield(P, 'channel'),
    indx = ismember(NEURO.NeuronInfo.Channel, P.channel);
    if isempty(indx),
        error('No neurons found on specified channel(s)');
    end
    if isfield(P, 'signal'),
        P.signal = sort(unique(cat(1, P.signal, neuronlabels(indx))));
    else
        P.signal = neuronlabels(indx);
    end
end

if ~isempty(NEURO.NeuronInfo),
    infolabels = fieldnames(NEURO.NeuronInfo);
    Pfields = fieldnames(P);
    [ia ib] = ismember(lower(infolabels), lower(Pfields));
    if any(ia),
        matchindx = find(ia);
        Pmatch = Pfields(ib(logical(ib)));
        nmatch = length(matchindx);
        InfoIndx = cell(1, nmatch);
        for i = 1:nmatch,
            valuelist = NEURO.NeuronInfo.(infolabels{matchindx(i)});
            Pvalue = P.(Pmatch{i});
            if ischar(valuelist{1}),
                InfoIndx{i} = ismember(lower(valuelist), lower(Pvalue));
            elseif isnumeric(valuelist{1}),
                valuelist = cat(1, valuelist{:});
                if length(Pvalue) == 1,
                    InfoIndx{i} = (valuelist == Pvalue);
                elseif length(Pvalue) == 2,
                    InfoIndx{i} = (valuelist >= Pvalue(1) & valuelist <= Pvalue(2));
                else
                    error('*** Value for a numeric Info field must either be a single number (for an exact match) or two numbers specifying a range ***');
                end
            end
        end
        InfoIndx = cat(2, InfoIndx{:});
    else
        InfoIndx = true(size(neuronlabels));
    end
end

SigIndx = ismember(neuronlabels, P.signal);
SigIndx = cat(2, SigIndx, InfoIndx);
SigIndx = all(SigIndx, 2);

% allsignames = fieldnames(NEURO.Neuron);
% signames = allsignames(SigIndx);

