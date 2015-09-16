function spikeratehistogram(varargin)
%
% Called from the MonkeyWrench main menu
%
% Note that the Conditions Grouping Function is expected to be a function
% that takes no input arguments, and that produces one (cell array of
% conditions grouped as desired, one group per cell) or two (cell array of
% conditions groupings plus cell array of group names) outputs.
%
% Created by WA 6/2011


[BHV NEURO] = getactivedata;
if ~ispref('MonkeyLogic', 'Directories'),
    monkeylogic_directories;
end
MLdir = getpref('MonkeyLogic', 'Directories');
if ~ispref('MonkeyLogic', 'UserPreferences'),
    monkeywrench_config;
end
UserPref = getpref('MonkeyLogic', 'UserPreferences');

iscallback = 0;
tag = 'SRH';
if ~isempty(varargin),
    signame = varargin{1};
end
if ~isempty(gcbo),
    srh = get(gcbo, 'parent');
    iscallback = strcmp(get(srh, 'tag'), tag);
end

if ~iscallback,
    
    srh = figure;
    bgcol = [.93 .93 .93];
    set(gcf, 'position', [300 150 800 650], 'color', bgcol, 'name', sprintf('%s Spike Rate Histogram', signame), 'tag', tag);

    %Main Axis
    axes('position', [.09 .38 .88 .56]);
    set(gca, 'box', 'on', 'fontsize', 14, 'tag', 'MainAxis', 'userdata', signame);

    %Trigger selection
    allcodes = BHV.CodeNumbersUsed;
    codestr = BHV.CodeNamesUsed;
    startcodeval = find(allcodes == UserPref.DefaultStartCode);
    if isempty(startcodeval),
        startcodeval = 1;
    end
    numcodes = length(allcodes);
    codedescrip = cell(numcodes, 1);
    for i = 1:numcodes,
        codedescrip{i} = sprintf('%i: %s', allcodes(i), codestr{i});
    end
    x = 30; y = 15;
    uicontrol('style', 'frame', 'position', [x y 240 170], 'backgroundcolor', bgcol);
    uicontrol('style', 'text', 'position', [x+10 y+110 60 18], 'string', 'Start Code', 'backgroundcolor', bgcol, 'fontsize', 10, 'horizontalalignment', 'right');
    uicontrol('style', 'popup', 'position', [x+80 y+110 140 20], 'string', codedescrip, 'tag', 'StartCode', 'userdata', allcodes, 'value', startcodeval, 'callback', 'spikeratehistogram', 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'text', 'position', [x+10 y+70 60 18], 'string', 'Start Offset', 'backgroundcolor', bgcol, 'fontsize', 10, 'horizontalalignment', 'right');
    uicontrol('style', 'edit', 'position', [x+80 y+70 50 20], 'string', UserPref.DefaultStartOffset, 'tag', 'StartOffset', 'userdata', UserPref.DefaultStartOffset, 'callback', 'spikeratehistogram', 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'text', 'position', [x+10 y+30 60 18], 'string', 'Duration', 'backgroundcolor', bgcol, 'fontsize', 10, 'horizontalalignment', 'right');
    uicontrol('style', 'edit', 'position', [x+80 y+30 50 20], 'string', UserPref.DefaultDuration, 'tag', 'Duration', 'userdata', UserPref.DefaultDuration, 'callback', 'spikeratehistogram', 'backgroundcolor', [1 1 1]);

    %TaskObject Grouping
    numtaskobjects = size(BHV.TaskObject, 2);
    TO = 1:numtaskobjects;
    TO  = [NaN; TO'];
    TOstr = cell(numtaskobjects+1, 1);
    TOstr{1} = 'All Conditions';
    for i = 1:numtaskobjects,
        TOstr{i+1} = sprintf('TaskObject #%i', i);
    end
    x = 283; y = 15;
    uicontrol('style', 'frame', 'position', [x y 186 170], 'backgroundcolor', bgcol);
    uicontrol('style', 'text', 'position', [x+1 y+135 184 25], 'string', 'Sort Conditions by TaskObject', 'backgroundcolor', bgcol);
    uicontrol('style', 'popup', 'position', [x+30 y+115 126 25], 'string', TOstr, 'userdata', TO, 'tag', 'TaskObject', 'backgroundcolor', [1 1 1], 'callback', 'spikeratehistogram');
    uicontrol('style', 'popup', 'position', [x+30 y+85 126 25], 'string', 'attribute', 'userdata', [], 'tag', 'TOFields', 'enable', 'off', 'backgroundcolor', [1 1 1], 'callback', 'spikeratehistogram');
    %Grouping Text File
    uicontrol('style', 'text', 'position', [x+1 y+60 184 20], 'string', '- or use -', 'backgroundcolor', bgcol);
    uicontrol('style', 'pushbutton', 'position', [x+16 y+35 154 25], 'tag', 'CondGroupButton', 'string', 'Conditions Grouping Function', 'backgroundcolor', bgcol, 'callback', 'spikeratehistogram');
    uicontrol('style', 'edit', 'position', [x+20 y+5 146 25], 'string', '', 'tag', 'CondGroupMFile', 'backgroundcolor', [1 1 1], 'callback', 'spikeratehistogram');

    %Blocks
    blocks = unique(BHV.BlockNumber);
    x = 483; y = 15;
    uicontrol('style', 'frame', 'position', [x y 115 170], 'backgroundcolor', bgcol);
    uicontrol('style', 'text', 'position', [x+1 y+143 113 20], 'string', 'Blocks', 'backgroundcolor', bgcol);
    uicontrol('style', 'listbox', 'position', [x+25 y+5 65 140], 'string', blocks, 'tag', 'Blocks', 'userdata', blocks, 'callback', 'spikeratehistogram', 'backgroundcolor', [1 1 1], 'max', 1000000, 'value', 1:length(blocks));
    
    %Gaussian Smoothing
    x = 610; y = 90;
    uicontrol('style', 'frame', 'position', [x y 166 65], 'backgroundcolor', bgcol);
    uicontrol('style', 'text', 'position', [x+1 y+30 164 25], 'string', 'Gaussian Smoothing Sigma (ms)', 'backgroundcolor', bgcol);
    uicontrol('style', 'edit', 'position', [x+40 y+10 86 20], 'string', UserPref.DefaultSmoothWindow, 'tag', 'SmoothWindow', 'userdata', UserPref.DefaultSmoothWindow, 'backgroundcolor', [1 1 1], 'callback', 'spikeratehistogram');
 
    %Trial Error
    TE = unique(BHV.TrialError);
    TEstr = cellstr(num2str(TE));
    TEstr(end+1) = {'All'};
    TE(end+1) = NaN;
    x = 610; y = 15;
    uicontrol('style', 'frame', 'position', [x y 166 65], 'backgroundcolor', bgcol);
    uicontrol('style', 'text', 'position', [x+6 y+25 154 25], 'string', 'TrialError', 'backgroundcolor', bgcol);
    uicontrol('style', 'popup', 'position', [x+40 y+5 86 25], 'string', TEstr, 'userdata', TE, 'tag', 'TrialError', 'value', 1, 'backgroundcolor', [1 1 1], 'callback', 'spikeratehistogram');

    %Show codes toggle
    uicontrol('style', 'toggle', 'position', [610 165 166 25], 'string', 'Show Code Times', 'value', 0, 'tag', 'ShowCodeTimes', 'callback', 'spikeratehistogram');
    
    %Create or utilize local plotting preferences
    if ~isfield(UserPref, 'SpikeRateHistogram'),
        setdefaultoptions(BHV);
    end
    updatemenuoptions(srh, BHV);
    try
        updateplot(srh, signame);
    catch
        setdefaultoptions(BHV);
        updatemenuoptions(srh, BHV);
    end
    
elseif iscallback,

    callerhandle = gcbo;
    callertag = get(gcbo, 'tag');
    signame = get(findobj(srh, 'tag', 'MainAxis'), 'userdata');
    
    switch callertag,
        
        case 'StartCode',
            updateplot(srh, signame);
            
        case 'StartOffset',
            val = get(callerhandle, 'string');
            oldval = get(callerhandle, 'userdata');
            val = confirmvalue(val, 'numeric', [-1000000 10000000], oldval);
            set(callerhandle, 'string', val, 'userdata', val);
            updateplot(srh, signame);
            
        case 'Duration',
            val = get(callerhandle, 'string');
            oldval = get(callerhandle, 'userdata');
            val = confirmvalue(val, 'numeric', [10 10000000], oldval);
            set(callerhandle, 'string', val, 'userdata', val);
            updateplot(srh, signame);
            
        case 'TrialError',
            updateplot(srh, signame);
            
        case 'SmoothWindow',
            h = findobj('tag', 'LineObject');
            val = get(callerhandle, 'string');
            oldval = get(callerhandle, 'userdata');
            y = get(h, 'userdata');
            if ~iscell(y), %occurs when only one line present
                y = {y};
            end
            numpoints = length(y{1});
            sigma = confirmvalue(val, 'numeric', [0 numpoints/2], oldval); %if not numeric, revert to oldval, constrain val within given bounds.
            numlines = length(y);
            for i = 1:length(h),
                if i <= numlines,
                    if sigma == 0,
                        set(h(i), 'ydata', y{i});
                    else
                        set(h(i), 'ydata', smooth(y{i}, sigma, 'gaussian'));
                    end
                else
                    delete(h(i));
                end
            end
            set(callerhandle, 'string', sigma, 'userdata', sigma);
            
        case 'TaskObject',
            val = get(callerhandle, 'value');
            h = findobj(srh, 'tag', 'TOFields');
            if val == 1,
                set(h, 'enable', 'off');
            else
                set(h, 'enable', 'on');
                to = BHV.TaskObject(:, val-1);
                [output groupnames fnames] = sortconditems(to);
                set(h, 'string', fnames, 'userdata', fnames);
            end
            updateplot(srh, signame);
            
        case 'TOFields',
            updateplot(srh, signame);

        case 'CondGroupButton',
            fname = uigetfile([MLdir.ExperimentDirectory '*.m'], 'Choose matlab grouping function');
            if ~fname,
                set(callerhandle, 'string', 'Conditions Grouping Function', 'userdata', '');
                set(findobj(srh, 'tag', 'CondGroupMFile'), 'string', '', 'userdata', '');
                updateplot(srh, signame);
                set(findobj(srh, 'tag', 'TaskObject'), 'enable', 'on');
                return
            end
            if exist(fname) ~= 2,
                error('Grouping function must be an m-file on the MATLAB path');
            end
            if nargin(fname) > 0,
                error('Grouping function does not expect any input arguments');
            end
            if nargout(fname) > 2|| nargout(fname) < 1,
                error('Grouping function should produce either one (cell array of groups) or two (groups & group names) output variables');
            end
            [pname fname] = fileparts(fname);
            if nargout(fname) == 1,
                evalstr = sprintf('groups = %s;', fname);
                groupnames = '';
            else
                evalstr = sprintf('[conditiongroups groupnames] = %s;', fname);
            end
            eval(evalstr);
            G.groups = conditiongroups;
            G.groupnames = groupnames;
            set(callerhandle, 'string', fname, 'userdata', G);
            updateplot(srh, signame);
            set(findobj(srh, 'tag', 'TaskObject'), 'enable', 'off');
            set(findobj(srh, 'tag', 'CondGroupMFile'), 'string', fname, 'userdata', fname);
            
        case 'CondGroupMFile',
            fname = get(callerhandle, 'string');
            if isempty(fname),
                set(callerhandle, 'userdata', '');
                set(findobj(srh, 'tag', 'CondGroupButton'), 'string', 'Conditions Grouping Function', 'userdata', '');
                updateplot(srh, signame);
                set(findobj(srh, 'tag', 'TaskObject'), 'enable', 'on');
                return
            end
            prevfname = get(callerhandle, 'userdata');
            [pname fname ext] = fileparts(fname);
            if exist(fname) ~= 2,
                set(callerhandle, 'string', prevfname);
                error('Grouping function must be an m-file on the MATLAB path');
            end
            if nargin(fname) > 0,
                set(callerhandle, 'string', prevfname);
                error('Grouping function does not expect any input arguments');
            end
            if nargout(fname) > 2|| nargout(fname) < 1,
                set(callerhandle, 'string', prevfname);
                error('Grouping function should produce either one (cell array of groups) or two (groups & group names) output variables');
            end
            if nargout(fname) == 1,
                evalstr = sprintf('groups = %s;', fname);
                groupnames = '';
            else
                evalstr = sprintf('[conditiongroups groupnames] = %s;', fname);
            end
            eval(evalstr);
            G.groups = conditiongroups;
            G.groupnames = groupnames;
            set(findobj(srh, 'tag', 'CondGroupButton'), 'string', fname, 'userdata', G);
            updateplot(srh, signame);
            set(findobj(srh, 'tag', 'TaskObject'), 'enable', 'off');
                                        
        case 'Blocks',
            updateplot(srh, signame);
            
        case 'ShowCodeTimes',
            if get(callerhandle, 'value'),
                set(callerhandle, 'string', 'Hide Code Times');
            else
                set(callerhandle, 'string', 'Show Code Times');
            end
            updateplot(srh, signame);
            
    end
    
end

%%
function val = confirmvalue(val, type, valrange, default)

if strcmpi(type, 'numeric'),
    val = str2double(val);
    if isnan(val),
        val = default;
        return
    end
    if val < min(valrange),
        val = min(valrange);
    elseif val > max(valrange),
        val = max(valrange);
    end
end



%%
function updateplot(srh, signame)

set(srh, 'pointer', 'watch');
[BHV NEURO] = getactivedata;

allcodes = get(findobj(srh, 'tag', 'StartCode'), 'userdata');
startcode = allcodes(get(findobj(srh, 'tag', 'StartCode'), 'value'));
startoffset = get(findobj(srh, 'tag', 'StartOffset'), 'userdata');
duration = get(findobj(srh, 'tag', 'Duration'), 'userdata');
sigma = get(findobj(srh, 'tag', 'SmoothWindow'), 'userdata');

TElist = get(findobj(srh, 'tag', 'TrialError'), 'userdata');
TEval = get(findobj(srh, 'tag', 'TrialError'), 'value');
if TEval == length(TElist), %selected "All"
    TE = TElist(1:end-1);
else
    TE = TElist(TEval);
end

allblocks = get(findobj(srh, 'tag', 'Blocks'), 'userdata');
blockval = get(findobj(srh, 'tag', 'Blocks'), 'value');
blocks = allblocks(blockval);

conds = unique(BHV.ConditionNumber);

G = get(findobj(srh, 'tag', 'CondGroupButton'), 'userdata');
if ~isempty(G),
    conditiongroups = G.groups;
    groupnames = G.groupnames;
    numgroups = length(conditiongroups);
else
    TOlist = get(findobj(srh, 'tag', 'TaskObject'), 'userdata');
    TOval = get(findobj(srh, 'tag', 'TaskObject'), 'value');
    TO = TOlist(TOval);
    if isnan(TO),
        conditiongroups = {conds}; %first item is "All"
        numgroups = 1;
        groupnames = {'All Conditions'};
    else
        ATTval = get(findobj(srh, 'tag', 'TOFields'), 'value');
        ATTlist = get(findobj(srh, 'tag', 'TOFields'), 'userdata');
        ATTfield = ATTlist(ATTval);
        [conditiongroups groupnames] = sortconditems(BHV.TaskObject(:, TO), ATTfield);
        numgroups = length(conditiongroups);
    end
end

axes(findobj(srh, 'tag', 'MainAxis'));
colororder = get(gca, 'colororder');
colororder = [[0 0 0]; colororder];
numcols = size(colororder, 1);

cla;
hold on;

if get(findobj(srh, 'tag', 'ShowCodeTimes'), 'value'),
    %get code-times:
    allselectedconds = [];
    for i = 1:numgroups,
        theseconds = conditiongroups{i};
        allselectedconds = cat(1, allselectedconds, theseconds(:));
    end
    chosentrials = trialselector('ConditionNumber', allselectedconds, 'TrialError', TE, 'BlockNumber', blocks);
    startcodetime = nexgetcodetime(chosentrials, startcode);
    usedcodes = BHV.CodeNumbersUsed;
    numcodes = length(usedcodes);
    linestep = 10;
    codecount = 0;
    linecount = 0;
    cthandles = zeros(10000, 1);
    for i = 1:numcodes,
        relcodetimes = nexgetcodetime(chosentrials, usedcodes(i)) - startcodetime;
        if ~isempty(~isnan(relcodetimes)) && mean(relcodetimes) > startoffset && mean(relcodetimes) < startoffset + duration,
            codecount = codecount + 1;
            mint = min(relcodetimes);
            maxt = max(relcodetimes);
            if maxt - mint > linestep,
                [n x] = hist(relcodetimes, min(relcodetimes):linestep:max(relcodetimes));
            else
                [n x] = hist(relcodetimes, 1);
            end
            for k = 1:length(x),
                linecount = linecount + 1;
                cthandles(linecount) = line([x(k) x(k)], [0 1000]);
                col = 1 - ((n(k)/max(n))*0.4);
                col = [col col col];
                set(cthandles(linecount), 'color', col, 'linewidth', 2);
            end
            meantime(codecount) = mean(relcodetimes);
            codenumber(codecount) = usedcodes(i);
        end
    end
    for i = 1:codecount,
        ctlabels(i) = text(meantime(i), 0.5, [num2str(codenumber(i)) ' ']);
        set(ctlabels(i), 'fontsize', 10, 'fontweight', 'bold', 'horizontalalignment', 'right');
    end
    cthandles = cthandles(1:linecount);
    set(cthandles, 'handlevisibility', 'off');
end

maxpt = 0;
datapresent = false(1, numgroups);
for i = 1:numgroups,
    s = nexgetspike('Signal', signame, 'StartCode', startcode, 'StartOffset', startoffset, 'Duration', duration, 'ConditionNumber', conditiongroups{i}, 'TrialError', TE, 'BlockNumber', blocks);
    s = 1000*mean(s);
    x = startoffset:startoffset+duration-1;
    if numel(s) > 1,
        ss = smooth(s, sigma, 'gaussian');
        h = plot(x, ss);
        if numgroups == 1,
            s = {s};
        end
        thiscol = colororder(mod(i, numcols)+1, :);
        set(h, 'linewidth', 2, 'tag', 'LineObject', 'userdata', s, 'color', thiscol);
        maxpt = max([maxpt max(ss)]);
        datapresent(i) = true;
    end
end
groupnames = groupnames(datapresent);

f = find(BHV.CodeNumbersUsed == startcode);
if ~isempty(f),
    codetxt = BHV.CodeNamesUsed{f};
else
    codetxt = '';
end
h = xlabel(sprintf('Time (ms) from "%s" (code %i)', codetxt, startcode));
set(h, 'fontsize', 14, 'tag', 'XLabel');
h = ylabel('Spikes / sec');
set(h, 'fontsize', 14, 'tag', 'YLabel');
ylim = [0 1.1*maxpt];
tchunk = 50;
xlim = [tchunk*floor(startoffset/tchunk) tchunk*ceil((startoffset+duration)/tchunk)];
set(gca, 'ylim', ylim, 'xlim', xlim, 'box', 'on', 'fontsize', 14, 'tag', 'MainAxis', 'userdata', signame);
legend(groupnames);
legend boxoff

if get(findobj(srh, 'tag', 'ShowCodeTimes'), 'value') && codecount > 0,
    set(cthandles, 'handlevisibility', 'on');
    set(ctlabels, 'handlevisibility', 'on');
    ypos = 0.05*maxpt;
    for i = 1:codecount,
        pos = get(ctlabels(i), 'position');
        pos(2) = ypos;
        set(ctlabels(i), 'position', pos);
    end
end

%update local plotting prefs:
UserPref = getpref('MonkeyLogic', 'UserPreferences');
UserPref.SpikeRateHistogram.StartCode = get(findobj(gcf, 'tag', 'StartCode'), 'value');
UserPref.SpikeRateHistogram.StartOffset = str2double(get(findobj(gcf, 'tag', 'StartOffset'), 'string'));
UserPref.SpikeRateHistogram.Duration = str2double(get(findobj(gcf, 'tag', 'Duration'), 'string'));
UserPref.SpikeRateHistogram.SmoothWindow = str2double(get(findobj(gcf, 'tag', 'SmoothWindow'), 'string'));
UserPref.SpikeRateHistogram.SortOnTaskObject = get(findobj(gcf, 'tag', 'TaskObject'), 'value');
UserPref.SpikeRateHistogram.SortOnAttribute = get(findobj(gcf, 'tag', 'TOFields'), 'value');
UserPref.SpikeRateHistogram.ConditionsGrouping = get(findobj(gcf, 'tag', 'CondGroupMFile'), 'string');
UserPref.SpikeRateHistogram.SelectedBlocks = get(findobj(gcf, 'tag', 'Blocks'), 'value');
UserPref.SpikeRateHistogram.TrialError = get(findobj(gcf, 'tag', 'TrialError'), 'value');
UserPref.SpikeRateHistogram.ShowCodeTimes = get(findobj(gcf, 'tag', 'ShowCodeTimes'), 'value');
setpref('MonkeyLogic', 'UserPreferences', UserPref);

set(srh, 'pointer', 'arrow'); drawnow;

%%
function setdefaultoptions(BHV)

UserPref = getpref('MonkeyLogic', 'UserPreferences');

allcodes = BHV.CodeNumbersUsed;
startcodeval = find(allcodes == UserPref.DefaultStartCode);
if isempty(startcodeval),
    startcodeval = 1;
end
SpikeRateHistogram.StartCode = startcodeval;
SpikeRateHistogram.StartOffset = UserPref.DefaultStartOffset;
SpikeRateHistogram.Duration = UserPref.DefaultDuration;
SpikeRateHistogram.SmoothWindow = UserPref.DefaultSmoothWindow;
SpikeRateHistogram.SortOnTaskObject = 1;
SpikeRateHistogram.SortOnAttribute = 1;
SpikeRateHistogram.ConditionsGrouping = '';
SpikeRateHistogram.SelectedBlocks = 1:length(unique(BHV.BlockNumber));
SpikeRateHistogram.TrialError = 1;
SpikeRateHistogram.ShowCodeTimes = 0;
UserPref.SpikeRateHistogram = SpikeRateHistogram;

setpref('MonkeyLogic', 'UserPreferences', UserPref);

%%
function updatemenuoptions(srh, BHV)

UserPref = getpref('MonkeyLogic', 'UserPreferences');

set(findobj(srh, 'tag', 'StartCode'), 'value', UserPref.SpikeRateHistogram.StartCode);
set(findobj(srh, 'tag', 'StartOffset'), 'string', num2str(UserPref.SpikeRateHistogram.StartOffset), 'userdata', UserPref.SpikeRateHistogram.StartOffset);
set(findobj(srh, 'tag', 'Duration'), 'string', num2str(UserPref.SpikeRateHistogram.Duration), 'userdata', UserPref.SpikeRateHistogram.Duration);
set(findobj(srh, 'tag', 'SmoothWindow'), 'string', num2str(UserPref.SpikeRateHistogram.SmoothWindow), 'userdata', UserPref.SpikeRateHistogram.SmoothWindow);
val = UserPref.SpikeRateHistogram.SortOnTaskObject;
set(findobj(srh, 'tag', 'TaskObject'), 'value', val);
h = findobj(srh, 'tag', 'TOFields');
if val == 1,
    set(h, 'enable', 'off');
else
    set(h, 'enable', 'on');
    to = BHV.TaskObject(:, val-1);
    [output groupnames fnames] = sortconditems(to);
    set(h, 'string', fnames, 'userdata', fnames, 'value', UserPref.SpikeRateHistogram.SortOnAttribute);
end
set(findobj(srh, 'tag', 'CondGroupMFile'), 'string', UserPref.SpikeRateHistogram.ConditionsGrouping);
set(findobj(srh, 'tag', 'Blocks'), 'value', UserPref.SpikeRateHistogram.SelectedBlocks);
set(findobj(srh, 'tag', 'TrialError'), 'value', UserPref.SpikeRateHistogram.TrialError);
set(findobj(srh, 'tag', 'ShowCodeTimes'), 'value', UserPref.SpikeRateHistogram.ShowCodeTimes);
