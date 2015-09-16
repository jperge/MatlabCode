function [chosentrials P] = trialselector(varargin)
%
% Parameters:          Values:                            Default:
% 'StartTime'          absolute time in ms (scalar)       0 ms
% 'EndTime'            absolute time in ms (scalar)       end of last trial
% 'StartCode'          start code (scalar)                start_trial
% 'StartOffset'        start offset (scalar)              0 ms
% 'Duration'           duration in ms (scalar)            5000 ms
%
% In addition:
% Parameters can be any field of the BHV file, so long as that field is a
% vector containing one value for each trial.  Examples include:
%
% 'TrialNumber'        trials to include (vector)         all trials
% 'TrialError'         trial-errors to include (vector)   all trial errors
% 'Condition'          conditions to include (vector)     all conditions
% 'BlockNumber'        blocks to include (vector)         all blocks
% 'BlockIndex'         blocks (ordinal number) (vector)   all blocks
%
% Note that the field-names do not need to match exactly because
% capitalization, plurals, and the suffix "number" are ignored (e.g.,
% 'Trials' == 'trial' == 'TrialNumbers').  Note that this could lead to
% ambiguity and the use of the wrong variable if care is not taken to call
% parameters appropriately (e.g., 'Block' could refer to 'BlockNumber' or
% 'BlockIndex', so the full parameter name should be used).
%
% Created by WA, June, 2008


if iscell(varargin{1}), %input variables passed from nexgetspike
    v = varargin{1};
    if isempty(v),
        varargin = {};
    else
        for i = 1:length(v),
            varargin(i) = v(i);
        end
    end
end

if ~ispref('MonkeyLogic', 'UserPreferences'),
    s = monkeylogic_config;
    if ~s, error('Unable to set MonkeyLogic User Preferences'); end
end
userpref = getpref('MonkeyLogic', 'UserPreferences');

[BHV NEURO] = getactivedata;

totaltrials = length(BHV.TrialError);
P.trial = 1:totaltrials;
P.trialerror = unique(BHV.TrialError);
P.condition = unique(BHV.ConditionNumber);
P.block = unique(BHV.BlockNumber);
P.startcode = userpref.DefaultStartCode;
P.startoffset = userpref.DefaultStartOffset;
P.duration = userpref.DefaultDuration;
P.starttime = 0;
P.endtime = max(NEURO.CodeTimes) + 1;

%create "BlockIndex", if it doesn't already exist,
if ~isfield(BHV, 'BlockIndex'),
    bnum = BHV.BlockNumber;
    dblock = find(diff(bnum)) + 1;
    dblock(2:length(dblock)+1) = dblock;
    dblock(1) = 1;
    dblock(length(dblock)+1) = totaltrials+1;
    BHV.BlockIndex = zeros(totaltrials, 1);
    for i = 1:length(dblock)-1,
        x1 = dblock(i);
        x2 = dblock(i+1)-1;
        BHV.BlockIndex(x1:x2) = i;
    end
end
P.blockindex = unique(BHV.BlockIndex);

if ~isempty(varargin),
    vlength = length(varargin);
    if isstruct(varargin{1}),
        if vlength > 1,
            error('Arguments must come in parameter / value pairs, or as a single structure');
        end
        crit = varargin{1};
        param = fieldnames(crit);
        for i = 1:length(param),
            n1 = param{i};
            n2 = fixname(n1);
            P.(n2) = crit.(n1); %so as not to overwrite entire structure, P
        end
    else
        if mod(vlength, 2),
            error('Arguments must come in parameter / value pairs, or as a single structure');
        end
        for i = 1:2:vlength,
            n2 = fixname(varargin{i});
            arg = varargin{i+1};
            P.(n2) = arg;
        end
    end
    if length(P.startcode) > 1 || length(P.startoffset) > 1 || length(P.duration) > 1,
        error('May specify only one start code, one start offset, and one duration');
    end
end

fn = fieldnames(BHV);
for i = 1:length(fn),
    n1 = fn{i};
    n2 = fixname(n1);
    B.(n2) = BHV.(n1);
end
fn = fieldnames(P);
m = zeros(totaltrials, length(fn));
count = 0;
for i = 1:length(fn),
    n = fn{i};
    if isfield(B, n) && ~strcmp(n, 'starttime'),
        count = count + 1;
        m(:, count) = ismember(B.(n), P.(n));
    end
end
chosentrials = (sum(m, 2) == count);

%chosentrials = (ismember(BHV.TrialNumber, P.trial) & ismember(BHV.ConditionNumber, P.condition) & ismember(BHV.BlockNumber, P.block) & ismember(BHV.TrialError, P.trialerror) & ismember(BHV.BlockIndex, P.blockindex));
chosentrials = find(chosentrials & NEURO.TrialTimes > P.starttime & (NEURO.TrialTimes + NEURO.TrialDurations) < P.endtime);

findcode = nexgetcodetime(chosentrials, P.startcode);
chosentrials = chosentrials(~isnan(findcode));

%%
function output = fixname(input)
% remove trailing "s" and/or "number" in parameter names

output = lower(input);
if strcmp(output(length(output)), 's'),
    output = output(1:length(output)-1);
end
f = strfind(output, 'number');
if ~isempty(f) && f > 1,
    output = output(1:f-1);
end


