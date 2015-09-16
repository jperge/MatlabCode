function [output, recnum] = getbatchresult(batchoutput, datafile, varargin)
% SYNTAX:
%           [output recordnumber] = getbatchresult(batchoutput, datafile)
%
%       or
%
%           [output recordnumber] = getbatchresult(batchoutput, datafile, signame)
%
% Returns the "output.Results.Data" field for the specified datafile &
% signal combination, from the "batchoutput" structure created by the
% "batch" function (that may be accessed via monkeywrench > batch GUIs).
%
% The input "signame" can be a string (char) array, or a cell array of
% strings, in which case the resulting output will have a cell for each
% matching data field.
%
% Only one datafile can be specified (allowing specification of more than
% one could result in ambiguities between file-signal assigments, without
% requiring a more complicated syntax to resolve.
%
% Created 5/15/12  --WA
% Last modified by WA  5/21/12
%
% See also: batch, batchgui, monkeywrench

if ~isempty(varargin),
    signame = varargin{1};
else
    signame = [];
end

R = batchoutput.Results;

fnames = cat(1, R.DataFile);
neurons = cat(1, R.NeuronID);
lfps = cat(1, R.LFPID);

filematch = strcmp(fnames, datafile);

if ~isempty(signame),
    if ~iscell(signame),
        signame = {signame};
    end
    numsigs = length(signame);
    output = cell(numsigs, 1);
    recnum = zeros(numsigs, 1);
    for i = 1:numsigs,
        if ~isempty(signame),
            sigmatch = strcmp(neurons, signame(i));
            if ~any(sigmatch),
                sigmatch = strcmp(lfps, signame(i));
            end
        end
        fmatch = [];
        if ~isempty(filematch) && ~isempty(sigmatch),
            fmatch = find(filematch & sigmatch);
        end
        if isempty(fmatch),
            output(i) = {NaN};
            recnum(i) = NaN;
        else
            output(i) = R(fmatch).Data;
            recnum(i) = fmatch;
        end
    end
    if all(isnan(recnum)),
        output = [];
        recnum = [];
    end
else
    [output recnum] = find(filematch);
end


