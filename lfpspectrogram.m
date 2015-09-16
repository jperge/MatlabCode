function lfpspectrogram(varargin)
%
% Called from the MonkeyWrench main menu
%
% Note that the Conditions Grouping Function is expected to be a function
% that takes no input arguments, and that produces one (cell array of
% conditions grouped as desired, one group per cell) or two (cell array of
% conditions groupings plus cell array of group names) outputs.
%
%
% Created by Max Ladow 6/2012
% Updated 7/30/2012 ML
% Modified 8/24/12 WA

%takes in activedata and Monkey Logic user preferences
[BHV NEURO] = getactivedata;
if ~ispref('MonkeyLogic', 'Directories'),
    monkeylogic_directories;
end
MLdir = getpref('MonkeyLogic', 'Directories');
if ~ispref('MonkeyLogic', 'UserPreferences'),
    [cfg f] = monkeywrench_config; drawnow;
    waitfor(gcf);
end
UserPref = getpref('MonkeyLogic', 'UserPreferences');
if ~isfield(UserPref, 'LFPSpectrogram'),
    [cfg f] = monkeywrench_config; drawnow;
    waitfor(gcf);
end
UserPref = getpref('MonkeyLogic', 'UserPreferences');
LFPConfig = UserPref.LFPSpectrogram;

%if ls varargin was full takes in value, else gets hand and tag of ls
callertag = [];
iscallback = 0;
tag = 'LFPSpectFig';
if ~isempty(varargin),
    signame = varargin{1};
end
if ~isempty(gcbo),
    ls = get(gcbo, 'parent');
    iscallback = strcmp(get(ls, 'tag'), tag);
    
    if ~iscallback && strcmp(get(gcbo, 'tag'), tag); %could be the figure itself being deleted (called by "closerequestfcn")
        iscallback = 1;
        callertag = tag;
    end
end

%used to minimize redundant graphing
singlecheck = 1;
averagecheck = 1;

%creates the figure if not yet created
if ~iscallback,
    
    %Figure
    ls = figure;
    bgcol = [.93 .93 .93];
    set(gcf, 'position', [30 150 1360 700], 'color', bgcol, 'name', sprintf('%s LFP Spectrogram', signame), 'tag', tag, 'closerequestfcn', 'lfpspectrogram');
    
    %axes
    axes('position', [.05 .36 .4358 .58]);
    set(gca, 'box', 'on', 'fontsize', 14, 'tag', 'MainAxis1', 'userdata', signame);
    axes('position', [.05 .36 .40 .56]);
    set(gca, 'box', 'on', 'fontsize', 14, 'tag', 'MainAxis2', 'userdata', signame);
    axes('position', [.55 .36 .4358 .58]);
    set(gca, 'box', 'on', 'fontsize', 14, 'tag', 'MainAxis3', 'userdata', signame);
    axes('position', [.55 .36 .40 .56]);
    set(gca, 'box', 'on', 'fontsize', 14, 'tag', 'MainAxis4', 'userdata', signame);
    
    
    %Trigger selection (makes buttons etc.
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
    x = 150; y = 15;
    uicontrol('style', 'frame', 'position', [x y 200 170], 'backgroundcolor', bgcol);
    uicontrol('style', 'text', 'position', [x+5 y+130 50 20], 'string', 'Start Code', 'backgroundcolor', bgcol, 'fontsize', 10, 'horizontalalignment', 'right');
    uicontrol('style', 'popup', 'position', [x+59 y+132 140 20], 'string', codedescrip, 'tag', 'StartCode', 'userdata', allcodes, 'value', startcodeval, 'callback', 'lfpspectrogram', 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'text', 'position', [x+5 y+95 55 23], 'string', 'Start Offset', 'backgroundcolor', bgcol, 'fontsize', 10, 'horizontalalignment', 'right');
    uicontrol('style', 'edit', 'position', [x+75 y+100 50 20], 'string', UserPref.DefaultStartOffset, 'tag', 'StartOffset', 'userdata', UserPref.DefaultStartOffset, 'callback', 'lfpspectrogram', 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'text', 'position', [x+10 y+68 40 18], 'string', 'Duration', 'backgroundcolor', bgcol, 'fontsize', 10, 'horizontalalignment', 'right');
    uicontrol('style', 'edit', 'position', [x+73 y+68 50 20], 'string', UserPref.DefaultDuration, 'tag', 'Duration', 'userdata', UserPref.DefaultDuration, 'callback', 'lfpspectrogram', 'backgroundcolor', [1 1 1]);
    
    %Trial Selection
    trials = unique(BHV.TrialNumber);
    trialval = 1;
    x=30; y =15;
    uicontrol('style', 'frame', 'position', [x y 115 170], 'backgroundcolor', bgcol);
    uicontrol('style', 'text', 'position', [x+1 y+143 113 20], 'string', 'Trial', 'backgroundcolor', bgcol);
    uicontrol('style', 'listbox', 'position', [x+25 y+6 75 140], 'string', trials, 'tag', 'Trial', 'userdata', trials, 'callback', 'lfpspectrogram', 'backgroundcolor', [1 1 1], 'value', trialval);

    %Blocks
    blocks = unique(BHV.BlockNumber);
    x = 1057; y = 15;
    uicontrol('style', 'frame', 'position', [x y 115 170], 'backgroundcolor', bgcol);
    uicontrol('style', 'text', 'position', [x+1 y+143 113 20], 'string', 'Blocks', 'backgroundcolor', bgcol);
    uicontrol('style', 'listbox', 'position', [x+25 y+5 65 140], 'string', blocks, 'tag', 'Blocks', 'userdata', blocks, 'callback', 'lfpspectrogram', 'backgroundcolor', [1 1 1], 'max', 1000000, 'value', 1:length(blocks));
    
    %Frequencies for spectrogram
    frequencies = {0:1:75};
    x = 355; y = 15;
    uicontrol('style', 'frame', 'position', [x y 160 170], 'backgroundcolor', bgcol);
    uicontrol('style', 'text', 'position', [x+15 y+135 138 20], 'string', 'Frequencies for Spectrogram', 'backgroundcolor', bgcol);
    uicontrol('style', 'text', 'position', [x+7 y+102 75 23], 'string', 'Min Frequency', 'backgroundcolor', bgcol, 'fontsize', 10, 'horizontalalignment', 'right');
    uicontrol('style', 'edit', 'position', [x+100 y+107 55 20], 'string', LFPConfig.GlobalMinFreq, 'tag', 'MinFrequency', 'userdata', LFPConfig.GlobalMinFreq, 'callback', 'lfpspectrogram', 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'text', 'position', [x+7 y+70 75 18], 'string', 'Max Frequency', 'backgroundcolor', bgcol, 'fontsize', 10, 'horizontalalignment', 'right');
    uicontrol('style', 'edit', 'position', [x+100 y+75 55 20], 'string', LFPConfig.GlobalMaxFreq, 'tag', 'MaxFrequency', 'userdata', LFPConfig.GlobalMaxFreq, 'callback', 'lfpspectrogram', 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'text', 'position', [x+20 y+38 30 18], 'string', 'Step', 'backgroundcolor', bgcol, 'fontsize', 10, 'horizontalalignment', 'right');
    uicontrol('style', 'edit', 'position', [x+100 y+43 55 20], 'string', LFPConfig.FreqStep, 'tag', 'Step', 'userdata', LFPConfig.FreqStep, 'callback', 'lfpspectrogram', 'backgroundcolor', [1 1 1]);
    
    %Gaussian Smoothing
    x = 705; y = 90;
    uicontrol('style', 'frame', 'position', [x y 166 65], 'backgroundcolor', bgcol);
    uicontrol('style', 'text', 'position', [x+1 y+31 164 30], 'string', 'Gaussian Smoothing Sigma (ms)', 'backgroundcolor', bgcol);
    uicontrol('style', 'edit', 'position', [x+40 y+10 86 20], 'string', UserPref.DefaultSmoothWindow, 'tag', 'SmoothWindow', 'userdata', UserPref.DefaultSmoothWindow, 'backgroundcolor', [1 1 1], 'callback', 'lfpspectrogram');
    
    %Trial Error
    TE = unique(BHV.TrialError);
    TEstr = cellstr(num2str(TE));
    TEstr(end+1) = {'All'};
    TE(end+1) = NaN;
    x = 705; y = 15;
    uicontrol('style', 'frame', 'position', [x y 166 65], 'backgroundcolor', bgcol);
    uicontrol('style', 'text', 'position', [x+6 y+25 154 25], 'string', 'TrialError', 'backgroundcolor', bgcol);
    uicontrol('style', 'popup', 'position', [x+40 y+5 86 25], 'string', TEstr, 'userdata', TE, 'tag', 'TrialError', 'value', 1, 'backgroundcolor', [1 1 1], 'callback', 'lfpspectrogram');
    
    %Doesn't graph the raw frequencies
    uicontrol('style', 'toggle', 'position', [705 160 166 27], 'string', 'Show/Hide Raw LFPs', 'value', 0, 'tag', 'HideRaw', 'callback', 'lfpspectrogram');
    
    %TaskObject Grouping
    numtaskobjects = size(BHV.TaskObject, 2);
    TO = 1:numtaskobjects;
    TO  = [NaN; TO'];
    TOstr = cell(numtaskobjects+1, 1);      %makes string for TO group w/ numbers
    TOstr{1} = 'All Conditions';
    for i = 1:numtaskobjects,
        TOstr{i+1} = sprintf('TaskObject #%i', i);
    end
    x = 875; y = 15;
    uicontrol('style', 'frame', 'position', [x y 175 170], 'backgroundcolor', bgcol);
    uicontrol('style', 'text', 'position', [x+15 y+135 140 25], 'string', 'Sort Conditions by TaskObject', 'backgroundcolor', bgcol);
    uicontrol('style', 'popup', 'position', [x+20 y+115 126 25], 'string', TOstr, 'userdata', TO, 'tag', 'TaskObject', 'backgroundcolor', [1 1 1], 'callback', 'lfpspectrogram');
    uicontrol('style', 'popup', 'position', [x+20 y+85 126 25], 'string', 'attribute', 'userdata', [], 'tag', 'TOFields', 'enable', 'off', 'backgroundcolor', [1 1 1], 'callback', 'lfpspectrogram');
    
    %Grouping Text File
    uicontrol('style', 'text', 'position', [x+40 y+60 100 20], 'string', '- or use -', 'backgroundcolor', bgcol);
    uicontrol('style', 'pushbutton', 'position', [x+12 y+35 154 25], 'tag', 'CondGroupButton', 'string', 'Conditions Grouping Function', 'backgroundcolor', bgcol, 'callback', 'lfpspectrogram');
    uicontrol('style', 'edit', 'position', [x+15 y+5 146 25], 'string', '', 'tag', 'CondGroupMFile', 'backgroundcolor', [1 1 1], 'callback', 'lfpspectrogram');
    
    %settings for power vs. frequency
    x = 520; y = 15;
    uicontrol('style', 'frame', 'position', [x y 180 170], 'backgroundcolor', bgcol);
    uicontrol('style', 'text', 'position', [x+1 y+135 175 25], 'string', 'Frequency Ranges', 'backgroundcolor', bgcol);
    uicontrol('style', 'text', 'position', [x+8 y+110 40 22], 'string', 'Delta', 'backgroundcolor', bgcol);
    uicontrol('style', 'text', 'position', [x+8 y+85 40 22], 'string', 'Theta', 'backgroundcolor', bgcol);
    uicontrol('style', 'text', 'position', [x+8 y+60 40 22], 'string', 'Alpha', 'backgroundcolor', bgcol);
    uicontrol('style', 'text', 'position', [x+8 y+35 40 22], 'string', 'Beta', 'backgroundcolor', bgcol);
    uicontrol('style', 'text', 'position', [x+8 y+10 40 22], 'string', 'Gamma', 'backgroundcolor', bgcol);
    uicontrol('style', 'edit', 'position', [x+60 y+115 25 20], 'string', LFPConfig.DeltaMin, 'tag', 'DeltaMin', 'userdata', LFPConfig.DeltaMin, 'backgroundcolor', [1 1 1], 'callback', 'lfpspectrogram');
    uicontrol('style', 'edit', 'position', [x+90 y+115 25 20], 'string', LFPConfig.DeltaMax, 'tag', 'DeltaMax', 'userdata', LFPConfig.DeltaMax, 'backgroundcolor', [1 1 1], 'callback', 'lfpspectrogram');
    uicontrol('style', 'edit', 'position', [x+60 y+90 25 20], 'string', LFPConfig.ThetaMin, 'tag', 'ThetaMin', 'userdata', LFPConfig.ThetaMin, 'backgroundcolor', [1 1 1], 'callback', 'lfpspectrogram');
    uicontrol('style', 'edit', 'position', [x+90 y+90 25 20], 'string', LFPConfig.ThetaMax, 'tag', 'ThetaMax', 'userdata', LFPConfig.ThetaMax, 'backgroundcolor', [1 1 1], 'callback', 'lfpspectrogram');
    uicontrol('style', 'edit', 'position', [x+60 y+65 25 20], 'string', LFPConfig.AlphaMin, 'tag', 'AlphaMin', 'userdata', LFPConfig.AlphaMin, 'backgroundcolor', [1 1 1], 'callback', 'lfpspectrogram');
    uicontrol('style', 'edit', 'position', [x+90 y+65 25 20], 'string', LFPConfig.AlphaMax, 'tag', 'AlphaMax', 'userdata', LFPConfig.AlphaMax, 'backgroundcolor', [1 1 1], 'callback', 'lfpspectrogram');
    uicontrol('style', 'edit', 'position', [x+60 y+40 25 20], 'string', LFPConfig.BetaMin, 'tag', 'BetaMin', 'userdata', LFPConfig.BetaMin, 'backgroundcolor', [1 1 1], 'callback', 'lfpspectrogram');
    uicontrol('style', 'edit', 'position', [x+90 y+40 25 20], 'string', LFPConfig.BetaMax, 'tag', 'BetaMax', 'userdata', LFPConfig.BetaMax, 'backgroundcolor', [1 1 1], 'callback', 'lfpspectrogram');
    uicontrol('style', 'edit', 'position', [x+60 y+15 25 20], 'string', LFPConfig.GammaMin, 'tag', 'GammaMin', 'userdata', LFPConfig.GammaMin, 'backgroundcolor', [1 1 1], 'callback', 'lfpspectrogram');
    uicontrol('style', 'edit', 'position', [x+90 y+15 25 20], 'string', LFPConfig.GammaMax, 'tag', 'GammaMax', 'userdata', LFPConfig.GammaMax, 'backgroundcolor', [1 1 1], 'callback', 'lfpspectrogram');
    uicontrol('style', 'checkbox', 'position', [x+130 y+115 20 20], 'tag', 'DeltaCheck', 'value', LFPConfig.DeltaUse, 'userdata', LFPConfig.DeltaUse,'backgroundcolor', [1 1 1], 'callback', 'lfpspectrogram');
    uicontrol('style', 'checkbox', 'position', [x+130 y+90 20 20],  'tag', 'ThetaCheck', 'value', LFPConfig.ThetaUse, 'userdata', LFPConfig.ThetaUse,'backgroundcolor', [1 1 1], 'callback', 'lfpspectrogram');
    uicontrol('style', 'checkbox', 'position', [x+130 y+65 20 20],  'tag', 'AlphaCheck', 'value', LFPConfig.AlphaUse, 'userdata', LFPConfig.AlphaUse,'backgroundcolor', [1 1 1], 'callback', 'lfpspectrogram');
    uicontrol('style', 'checkbox', 'position', [x+130 y+40 20 20],  'tag', 'BetaCheck', 'value', LFPConfig.BetaUse, 'userdata', LFPConfig.BetaUse,'backgroundcolor', [1 1 1], 'callback', 'lfpspectrogram');
    uicontrol('style', 'checkbox', 'position', [x+130 y+15 20 20],  'tag', 'GammaCheck', 'value', LFPConfig.GammaUse, 'userdata', LFPConfig.GammaUse,'backgroundcolor', [1 1 1], 'callback', 'lfpspectrogram');
    
    
    
    %Create or utilize local plotting preferences
    %takes in all of the user preferences or initializes defaults(respectively the else and if statements)
    
    %set values as user preference values
    set(findobj(gcf, 'tag', 'StartCode'), 'value', startcodeval);
    set(findobj(gcf, 'tag', 'StartOffset'), 'string', num2str(LFPConfig.StartOffset), 'userdata', UserPref.LFPSpectrogram.StartOffset);
    set(findobj(gcf, 'tag', 'Duration'), 'string', num2str(LFPConfig.Duration), 'userdata', UserPref.LFPSpectrogram.Duration);
    set(findobj(gcf, 'tag', 'SmoothWindow'), 'string', num2str(LFPConfig.SmoothWindow), 'userdata', UserPref.LFPSpectrogram.SmoothWindow);
    if UserPref.LFPSpectrogram.Trial > trials(1,end),
        set(findobj(gcf, 'tag', 'Trial'), 'value', (trials(1,end)));
    else
        set(findobj(gcf, 'tag', 'Trial'), 'value', trialval);
    end
    set(findobj(gcf, 'tag', 'MinFrequency'), 'string', num2str(LFPConfig.GlobalMinFreq), 'userdata', LFPConfig.GlobalMinFreq);
    set(findobj(gcf, 'tag', 'MaxFrequency'), 'string', num2str(LFPConfig.GlobalMaxFreq), 'userdata', LFPConfig.GlobalMaxFreq);
    set(findobj(gcf, 'tag', 'Step'), 'string', num2str(LFPConfig.FreqStep), 'userdata', LFPConfig.FreqStep);
    val = LFPConfig.SortOnTaskObject;
    set(findobj(gcf, 'tag', 'TaskObject'), 'value', val);
    h = findobj(ls, 'tag', 'TOFields');
    %deals with possible input from the TOField input boxes
    if val == 1,
        set(h, 'enable', 'off');
    else
        set(h, 'enable', 'on');
        to = BHV.TaskObject(:, val-1);
        [output groupnames fnames] = sortconditems(to);
        set(h, 'string', fnames, 'userdata', fnames, 'value', LFPConfig.SortOnAttribute);
    end
    selectedblocks = UserPref.LFPSpectrogram.SelectedBlocks;
    if isnan(selectedblocks),
        selectedblocks = intersect(selectedblocks, blocks);
        if isempty(selectedblocks),
            selectedblocks = blocks;
        end
        selectedblocks = find(blocks == selectedblocks);
    end
    set(findobj(gcf, 'tag', 'CondGroupMFile'), 'string', UserPref.LFPSpectrogram.ConditionsGrouping);
    set(findobj(gcf, 'tag', 'Blocks'), 'value', selectedblocks);
    set(findobj(gcf, 'tag', 'TrialError'), 'value', UserPref.LFPSpectrogram.TrialError);
    set(findobj(gcf, 'tag', 'HideRaw'), 'value', UserPref.LFPSpectrogram.HideRaw);
    set(findobj(gcf, 'tag', 'DeltaMin'), 'string', num2str(LFPConfig.DeltaMin), 'userdata', LFPConfig.DeltaMin);
    set(findobj(gcf, 'tag', 'DeltaMax'), 'string', num2str(LFPConfig.DeltaMax), 'userdata', LFPConfig.DeltaMax);
    set(findobj(gcf, 'tag', 'ThetaMin'), 'string', num2str(LFPConfig.ThetaMin), 'userdata', LFPConfig.ThetaMin);
    set(findobj(gcf, 'tag', 'ThetaMax'), 'string', num2str(LFPConfig.ThetaMax), 'userdata', LFPConfig.ThetaMax);
    set(findobj(gcf, 'tag', 'AlphaMin'), 'string', num2str(LFPConfig.AlphaMin), 'userdata', LFPConfig.AlphaMin);
    set(findobj(gcf, 'tag', 'AlphaMax'), 'string', num2str(LFPConfig.AlphaMax), 'userdata', LFPConfig.AlphaMax);
    set(findobj(gcf, 'tag', 'BetaMin'), 'string', num2str(LFPConfig.BetaMin), 'userdata', LFPConfig.BetaMin);
    set(findobj(gcf, 'tag', 'BetaMax'), 'string', num2str(LFPConfig.BetaMax), 'userdata', LFPConfig.BetaMax);
    set(findobj(gcf, 'tag', 'GammaMin'), 'string', num2str(LFPConfig.GammaMin), 'userdata', LFPConfig.GammaMin);
    set(findobj(gcf, 'tag', 'GammaMax'), 'string', num2str(LFPConfig.GammaMax), 'userdata', LFPConfig.GammaMax);
    set(findobj(gcf, 'tag', 'DeltaCheck'), 'string', num2str(LFPConfig.DeltaUse), 'userdata', LFPConfig.DeltaUse);
    set(findobj(gcf, 'tag', 'ThetaCheck'), 'string', num2str(LFPConfig.ThetaUse), 'userdata', LFPConfig.ThetaUse);
    set(findobj(gcf, 'tag', 'AlphaCheck'), 'string', num2str(LFPConfig.AlphaUse), 'userdata', LFPConfig.AlphaUse);
    set(findobj(gcf, 'tag', 'BetaCheck'), 'string', num2str(LFPConfig.BetaUse), 'userdata', LFPConfig.BetaUse);
    set(findobj(gcf, 'tag', 'GammaCheck'), 'string', num2str(LFPConfig.GammaUse), 'userdata', LFPConfig.GammaUse);
    
    
    
    updateplot(ls, signame, singlecheck, averagecheck);
    
elseif iscallback,
    
    if isempty(callertag),
        callerhandle = gcbo;
        callertag = get(gcbo, 'tag');
        signame = strtok(get(ls, 'name'), ' ');
    end
    
    
    switch callertag,
        
        case tag, %figure window is being deleted, so called by closerequestfcn
            
            
            
            delete(gcf);
            
        case 'StartCode',
            
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'StartOffset',
            caseupdate(signame, callerhandle, -1000000, 10000000);
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'Duration',
            caseupdate(signame, callerhandle, 10, 10000000);
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'MinFrequency',
            caseupdate(signame, callerhandle, 0, 400);
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'MaxFrequency',
            caseupdate(signame, callerhandle, 0, 500);
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'Step',
            caseupdate(signame, callerhandle, 0, 100);
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'TrialError',
            singlecheck = 0;
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'SmoothWindow',
            h = findobj('tag', 'LineObject');
            val = get(callerhandle, 'string');
            oldval = get(callerhandle, 'userdata');
            y = get(h, 'userdata');
            numpoints = length(y{1});
            sigma = confirmvalue(val, 'numeric', [0 numpoints/2], oldval); %if not numeric, revert to oldval, constrain val within given bounds.
            numlines = length(y);
            for i = 1:numlines,
                if sigma == 0,
                    set(h(i), 'ydata', y{i});
                else
                    set(h(i), 'ydata', smooth(y{i}, sigma, 'gaussian'));
                end
            end
            set(callerhandle, 'string', sigma, 'userdata', sigma);
            
        case 'TaskObject',
            singlecheck = 0;
            
            val = get(callerhandle, 'value');
            h = findobj(ls, 'tag', 'TOFields');
            if val == 1,
                set(h, 'enable', 'off');
            else
                set(h, 'enable', 'on');
                to = BHV.TaskObject(:, val-1);
                [output groupnames fnames] = sortconditems(to);
                set(h, 'string', fnames, 'userdata', fnames);
            end
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'TOFields',
            singlecheck = 0;
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'CondGroupButton',
            singlecheck = 0;
            fname = uigetfile([MLdir.ExperimentDirectory '*.m'], 'Choose matlab grouping function');
            if ~fname,
                set(callerhandle, 'string', 'Conditions Grouping Function', 'userdata', '');
                set(findobj(ls, 'tag', 'CondGroupMFile'), 'string', '', 'userdata', '');
                updateplot(ls, signame, singlecheck, averagecheck);
                set(findobj(ls, 'tag', 'TaskObject'), 'enable', 'on');
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
            updateplot(ls, signame, singlecheck, averagecheck);
            set(findobj(ls, 'tag', 'TaskObject'), 'enable', 'off');
            set(findobj(ls, 'tag', 'CondGroupMFile'), 'string', fname, 'userdata', fname);
            
        case 'CondGroupMFile',
            singlecheck = 0;
            fname = get(callerhandle, 'string');
            if isempty(fname),
                set(callerhandle, 'userdata', '');
                set(findobj(ls, 'tag', 'CondGroupButton'), 'string', 'Conditions Grouping Function', 'userdata', '');
                updateplot(ls, signame, singlecheck, averagecheck);
                set(findobj(ls, 'tag', 'TaskObject'), 'enable', 'on');
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
            set(findobj(ls, 'tag', 'CondGroupButton'), 'string', fname, 'userdata', G);
            updateplot(ls, signame, singlecheck, averagecheck);
            set(findobj(ls, 'tag', 'TaskObject'), 'enable', 'off');
            
        case 'Trial'
            averagecheck = 0;
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'Blocks',
            singlecheck = 0;
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'HideRaw',
            if get(callerhandle, 'value'),
                set(callerhandle, 'string', 'Show Raw LFPs');
            else
                set(callerhandle, 'string', 'Hide Raw LFPs');
            end
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'DeltaMin',
            caseupdate(signame, callerhandle, 0, 10);
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'DeltaMax',
            caseupdate(signame, callerhandle, 0, 20);
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'ThetaMin',
            caseupdate(signame, callerhandle, 0, 20);
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'ThetaMax',
            caseupdate(signame, callerhandle, 1, 30);
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'AlphaMin',
            caseupdate(signame, callerhandle, 5, 40);
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'AlphaMax',
            caseupdate(signame, callerhandle, 10, 50);
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'BetaMin',
            caseupdate(signame, callerhandle, 10, 50);
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'BetaMax',
            caseupdate(signame, callerhandle, 15, 70);
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'GammaMin',
            caseupdate(signame, callerhandle, 0, 500);
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'GammaMax',
            caseupdate(signame, callerhandle, 0, 1000);
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'DeltaCheck',
            caseupdate(signame, callerhandle, 0, 1);
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'ThetaCheck',
            caseupdate(signame, callerhandle, 0, 1);
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'AlphaCheck',
            caseupdate(signame, callerhandle, 0, 1);
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'BetaCheck',
            caseupdate(signame, callerhandle, 0, 1);
            updateplot(ls, signame, singlecheck, averagecheck);
            
        case 'GammaCheck',
            caseupdate(signame, callerhandle, 0, 1);
            updateplot(ls, signame, singlecheck, averagecheck);
            
    end
    
end
end

%%
function caseupdate(signame, callerhandle, x, y)
val = get(callerhandle, 'string');
oldval = get(callerhandle, 'userdata');
val = confirmvalue(val, 'numeric', [x y], oldval);
set(callerhandle, 'string', val, 'userdata', val);

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

end

%%
function updateplot(ls, signame, singlecheck, averagecheck)

set(ls, 'pointer', 'watch'); drawnow;
[BHV NEURO] = getactivedata;

allcodes = get(findobj(ls, 'tag', 'StartCode'), 'userdata');
startcode = allcodes(get(findobj(ls, 'tag', 'StartCode'), 'value'));
startoffset = get(findobj(ls, 'tag', 'StartOffset'), 'userdata');
duration = get(findobj(ls, 'tag', 'Duration'), 'userdata');

minfrequency = get(findobj(ls, 'tag', 'MinFrequency'), 'userdata');
maxfrequency = get(findobj(ls, 'tag', 'MaxFrequency'), 'userdata');
step = get(findobj(ls, 'tag', 'Step'), 'userdata');

sigma = get(findobj(ls, 'tag', 'SmoothWindow'), 'userdata');

TElist = get(findobj(ls, 'tag', 'TrialError'), 'userdata');
TEval = get(findobj(ls, 'tag', 'TrialError'), 'value');
if TEval == length(TElist), %selected "All"
    TE = TElist(1:end-1);
else
    TE = TElist(TEval);
end

allblocks = get(findobj(ls, 'tag', 'Blocks'), 'userdata');
blockval = get(findobj(ls, 'tag', 'Blocks'), 'value');
blocks = allblocks(blockval);

alltrial = get(findobj(ls, 'tag', 'Trial'), 'userdata');
trialval = get(findobj(ls, 'tag', 'Trial'), 'value');
trials = alltrial(trialval);
uicontrol('style', 'text', 'position', [150+10 15+28 150 18], 'string', ['Trial Error for Selected Trial: ' int2str(BHV.TrialError(trials))], 'backgroundcolor', [.93 .93 .93], 'fontsize', 10, 'horizontalalignment', 'right');
uicontrol('style', 'text', 'position', [150+10 15+7 150 18], 'string', ['Condition for Selected Trial: ' int2str(BHV.ConditionNumber(trials))], 'backgroundcolor', [.93 .93 .93], 'fontsize', 10, 'horizontalalignment', 'right');


conds = unique(BHV.ConditionNumber);

hraw = get(findobj(ls, 'tag', 'HideRaw'), 'value');

G = get(findobj(ls, 'tag', 'CondGroupButton'), 'userdata');
if ~isempty(G),
    conditiongroups = G.groups;
    groupnames = G.groupnames;
    numgroups = length(conditiongroups);
else
    TOlist = get(findobj(ls, 'tag', 'TaskObject'), 'userdata');
    TOval = get(findobj(ls, 'tag', 'TaskObject'), 'value');
    TO = TOlist(TOval);
    if isnan(TO),
        conditiongroups = {conds}; %first item is "All"
        numgroups = 1;
        groupnames = 'All Conditions';
    else
        ATTval = get(findobj(ls, 'tag', 'TOFields'), 'value');
        ATTlist = get(findobj(ls, 'tag', 'TOFields'), 'userdata');
        ATTfield = ATTlist(ATTval);
        [conditiongroups groupnames] = sortconditems(BHV.TaskObject(:, TO), ATTfield);
        numgroups = length(conditiongroups);
    end
end

deltamin = get(findobj(ls, 'tag', 'DeltaMin'), 'userdata');
deltamax = get(findobj(ls, 'tag', 'DeltaMax'), 'userdata');
thetamin = get(findobj(ls, 'tag', 'ThetaMin'), 'userdata');
thetamax = get(findobj(ls, 'tag', 'ThetaMax'), 'userdata');
alphamin = get(findobj(ls, 'tag', 'AlphaMin'), 'userdata');
alphamax = get(findobj(ls, 'tag', 'AlphaMax'), 'userdata');
betamin = get(findobj(ls, 'tag', 'BetaMin'), 'userdata');
betamax = get(findobj(ls, 'tag', 'BetaMax'), 'userdata');
gammamin = get(findobj(ls, 'tag', 'GammaMin'), 'userdata');
gammamax = get(findobj(ls, 'tag', 'GammaMax'), 'userdata');
deltacheck = get(findobj(ls, 'tag', 'DeltaCheck'), 'value');
thetacheck = get(findobj(ls, 'tag', 'ThetaCheck'), 'value');
alphacheck = get(findobj(ls, 'tag', 'AlphaCheck'), 'value');
betacheck = get(findobj(ls, 'tag', 'BetaCheck'), 'value');
gammacheck = get(findobj(ls, 'tag', 'GammaCheck'), 'value');

%graphs single-trial plots on left side of frame
if singlecheck,
    axes(findobj(ls, 'tag', 'MainAxis1'));
    colororder = get(gca, 'colororder');
    colororder = [[0 0 0]; colororder];
    cla;
    hold on;
    
    %graphs spectrogram
    s = nexgetlfp('Signal', signame, 'StartCode', startcode, 'StartOffset', startoffset-1, 'Duration', duration+1, 'Trial', trials);
    %catches trials that don't match with selected startcodes
    if isempty(s),
        ax = findobj(gcf, 'tag', 'MainAxis1');
        set(ax, 'xlim', [-1 1], 'ylim', [-1 1]);
        h = text(0,0,'Selected Trial Does not Contain the Specified Start Code');
        set(h, 'horizontalalignment', 'center', 'fontsize', 14);
        set(ls, 'pointer', 'arrow');
        return
    else
        s=1000*s;
        lfp = filter_lfp(s, (minfrequency:step:maxfrequency));
        lfp=squeeze(lfp);
        lfp=lfp';
        x=[startoffset:1:(duration)+startoffset];
        if step <= 1,
            y = minfrequency+step:step:maxfrequency;
        else
            y = minfrequency:step+(step/((maxfrequency-minfrequency)/step)):maxfrequency;
            y = round(y(1,:));
        end
        pcolor(x, y, lfp);
        shading interp;
        colorbar('location', 'eastoutside');
        
        % %adds on labels for histogram
        f = find(BHV.CodeNumbersUsed == startcode);
        if ~isempty(f),
            codetxt = BHV.CodeNamesUsed{f};
        else
            codetxt = '';
        end
        h = xlabel(sprintf('Time (ms) from "%s" (code %i)', codetxt, startcode));
        set(h, 'fontsize', 14, 'tag', 'XLabel');
        h = ylabel('Spectrogram Frequencies (Hz)');
        set(h, 'fontsize', 14, 'tag', 'YLabel');
        h = title('Single-Trial LFPs');
        set(h,'fontsize', 18, 'tag', 'Title');
        set(gca, 'ylim', [min(y) max(y)], 'xlim', [min(x) max(x)]);
        
        
        axes(findobj(ls, 'tag', 'MainAxis2'));
        colororder = get(gca, 'colororder');
        colororder = [[0 0 0]; colororder];
        numcols = size(colororder, 1);
        cla;
        hold on;
        
        maxpt=0; minpt=0;
        %graphs the histogram
        s = nexgetlfp('Signal', signame, 'StartCode', startcode, 'StartOffset', startoffset, 'Duration', duration, 'Trial', trials);
        s = 1000*s;
        x = startoffset:startoffset+duration-1;
        if ~hraw,
            ss = smooth(s, sigma, 'gaussian');
            maxpt = max([maxpt max(ss)]);
            minpt = min([minpt min(ss)]);
            h = plot(x, ss);
            set(h, 'linewidth', 2, 'tag', 'LineObject', 'userdata', s, 'color', [0 .502 .502]);
        end
        hold on;
        %graphs the filtered bands
        uicontrol('style', 'frame', 'position', [1180 15 155 170]);
        uicontrol('style', 'text', 'position', [1182 140 150 35], 'string', 'Filtered LFP Colors:', 'Fontsize', 14);
        if deltacheck,
            uicontrol('style', 'text', 'position', [1205 120 30 25], 'string', '-------', 'foreground', 'm', 'fontsize', 16);
            uicontrol('style', 'text', 'position', [1235 120 40 25], 'string', 'delta', 'fontsize', 16);
            d = filter_lfp(s, [deltamin deltamax]);
            dp=plot(x, d, 'm');
            if hraw,
                set(dp, 'linewidth', 2, 'tag', 'LineObjectd1', 'userdata', d);
            else
                set(dp, 'linewidth', 1.9, 'tag', 'LineObjectd1', 'userdata', d);
            end
            hold on;
        end
        if thetacheck,
            uicontrol('style', 'text', 'position', [1205 100 30 25], 'string', '-------', 'foreground', 'b', 'fontsize', 16);
            uicontrol('style', 'text', 'position', [1235 100 40 25], 'string', 'theta', 'fontsize', 16);
            t = filter_lfp(s, [thetamin thetamax]);
            tp=plot(x, t, 'b');
            if hraw,
                set(tp, 'linewidth', 2, 'tag', 'LineObjectt1', 'userdata', t);
            else
                set(tp, 'linewidth', 1.9, 'tag', 'LineObjectt1', 'userdata', t);
            end
            hold on;
        end
        if alphacheck,
            uicontrol('style', 'text', 'position', [1205 80 30 25], 'string', '-------', 'foreground', 'c', 'fontsize', 16);
            uicontrol('style', 'text', 'position', [1235 80 40 25], 'string', 'alpha', 'fontsize', 16);
            a = filter_lfp(s, [alphamin alphamax]);
            ap=plot(x, a, 'c');
            if hraw,
                set(ap, 'linewidth', 2, 'tag', 'LineObjecta1', 'userdata', a);
            else
                set(ap, 'linewidth', 1.9, 'tag', 'LineObjecta1', 'userdata', a);
            end
            hold on;
        end
        if betacheck,
            uicontrol('style', 'text', 'position', [1205 60 30 25], 'string', '-------', 'fontsize', 16);
            uicontrol('style', 'text', 'position', [1235 60 40 25], 'string', 'beta', 'fontsize', 16);
            b = filter_lfp(s, [betamin betamax]);
            bp=plot(x, b, 'k');
            if hraw,
                set(bp, 'linewidth', 2, 'tag', 'LineObjectb1', 'userdata', b);
            else
                set(bp, 'linewidth', 1.9, 'tag', 'LineObjectb1', 'userdata', b);
            end
            hold on;
        end
        if gammacheck,
            uicontrol('style', 'text', 'position', [1205 40 30 25], 'string', '-------', 'foreground', 'w', 'fontsize', 16);
            uicontrol('style', 'text', 'position', [1235 28 60 40], 'string', 'gamma', 'fontsize', 16);
            g = filter_lfp(s, [gammamin gammamax]);
            gp=plot(x, g, 'w');
            if hraw,
                set(gp, 'linewidth', 2, 'tag', 'LineObjectg1', 'userdata', g);
            else
                set(gp, 'linewidth', 1.9, 'tag', 'LineObjectg1', 'userdata', g);
            end
        end
        if hraw==0,
            legend('raw', 'Location', 'Best');
            legend boxoff;
        end
        set(gca, 'xlim', [min(x) max(x)]);
        axis off;
    end
end
if averagecheck,
    %%graphs second set of graphs, right side of frame
    axes(findobj(ls, 'tag', 'MainAxis3'));
    colororder = get(gca, 'colororder');
    colororder = [[0 0 0]; colororder];
    numcols = size(colororder, 1);
    
    cla;
    hold on;
    
    %graphs spectrogram
    if isempty(numgroups) || ~numgroups,
        return
    end
    avglfp = zeros(numgroups,length(minfrequency:step:maxfrequency)-1, duration+1);
    for i = 1:numgroups,
        s = nexgetlfp('Signal', signame, 'StartCode', startcode, 'StartOffset', startoffset-1, 'Duration', duration+1, 'ConditionNumber', conditiongroups{i}, 'TrialError', TE, 'BlockNumber', blocks);
        if isempty(s),
            disp(['Specified conditions (', mat2str(conditiongroups{i}), '), trial error(s), and startcode do not exist in block(s) ', mat2str(blocks)]);
        else
            s = 1000*mean(s);
            lfp = filter_lfp(s, (minfrequency:step:maxfrequency));
            lfp = squeeze(lfp);
            lfp = lfp';
            if numgroups == 1,
                lfp = reshape(lfp, 1, size(lfp, 1), size(lfp, 2));
            end
            x = startoffset:1:(duration)+startoffset;
            if step <= 1,
                y = minfrequency+step:step:maxfrequency;
            else
                y = minfrequency:step+(step/((maxfrequency-minfrequency)/step)):maxfrequency;
                y = round(y(1,:));
            end
            avglfp(i, :, :) = lfp;
            if i == numgroups(1,end),
                avglfp = mean(avglfp, 1);
                avglfp = squeeze(avglfp);
                pcolor(x, y, avglfp);
                shading interp;
                colorbar('location', 'eastoutside');
            end
        end
    end
    
    % %adds on labels for spectrogram
    f = find(BHV.CodeNumbersUsed == startcode);
    if ~isempty(f),
        codetxt = BHV.CodeNamesUsed{f};
    else
        codetxt = '';
    end
    h = xlabel(sprintf('Time (ms) from "%s" (code %i)', codetxt, startcode));
    set(h, 'fontsize', 14, 'tag', 'XLabel');
    h = ylabel('Spectrogram Frequencies (Hz)');
    set(h, 'fontsize', 14, 'tag', 'YLabel');
    h = title('Average LFP');
    set(h,'fontsize', 18, 'tag', 'Title');
    set(gca, 'ylim', [min(y) max(y)], 'xlim', [min(x) max(x)]);
    
    axes(findobj(ls, 'tag', 'MainAxis4'));
    colororder = get(gca, 'colororder');
    colororder = [[0 0 0]; colororder];
    numcols = size(colororder, 1);
    
    cla;
    hold on;
    
    maxpt=0; minpt=0; avgs = zeros(numgroups, duration); numlines=0;
    %graphs the histogram
    for i = 1:numgroups,
        s = nexgetlfp('Signal', signame, 'StartCode', startcode, 'StartOffset', startoffset, 'Duration', duration, 'ConditionNumber', conditiongroups{i}, 'TrialError', TE, 'BlockNumber', blocks);
        if ~isempty(s),         %already displayed all error messages during the creation of the spectrogram so no further error messages are necessary
            numlines = numlines + 1;
            s = 1000*mean(s);
            x = startoffset:startoffset+duration-1;
            if numel(s) > 1,
                ss = smooth(s, sigma, 'gaussian');
                maxpt = max([maxpt max(ss)]);
                minpt = min([minpt min(ss)]);
                if ~hraw, %hides raw lines
                    h = plot(x, ss);
                end
                if numgroups == 1,
                    s = {s};
                end
                thiscol = colororder(mod(i, numcols)+1, :);
                set(h, 'linewidth', 2, 'tag', 'LineObject2', 'userdata', avgs, 'color', thiscol);
            end
            hold on;
            if numgroups ~=1, avgs(i,:) = s; end
        end
    end
    %takes average of different groups
    if numgroups ~=1, s = mean(avgs(1:1:4,:)); end
    if ~isempty(s),
        if iscell(s)
            s = cell2mat(s);
        end
        if deltacheck,
            d = filter_lfp(s, [deltamin deltamax]);
            dp=plot(x, d, 'm');
            if hraw,
                set(dp, 'linewidth', 2, 'tag', 'LineObjectd2', 'userdata', d);
            else
                set(dp, 'linewidth', 1.9, 'tag', 'LineObjectd2', 'userdata', d);
            end
            hold on;
        end
        if thetacheck,
            t = filter_lfp(s, [thetamin thetamax]);
            tp=plot(x, t, 'b');
            if hraw,
                set(tp, 'linewidth', 2, 'tag', 'LineObjectt2', 'userdata', t);
            else
                set(tp, 'linewidth', 1.9, 'tag', 'LineObjectt2', 'userdata', t);
            end
            hold on;
        end
        if alphacheck,
            a = filter_lfp(s, [alphamin alphamax]);
            ap=plot(x, a, 'c');
            if hraw,
                set(ap, 'linewidth', 2, 'tag', 'LineObjecta2', 'userdata', a);
            else
                set(ap, 'linewidth', 1.9, 'tag', 'LineObjecta2', 'userdata', a);
            end
            hold on;
        end
        if betacheck,
            b = filter_lfp(s, [betamin betamax]);
            bp=plot(x, b, 'k');
            if hraw,
                set(bp, 'linewidth', 2, 'tag', 'LineObjectb2', 'userdata', b);
            else
                set(bp, 'linewidth', 1.9, 'tag', 'LineObjectb2', 'userdata', b);
            end
            hold on;
        end
        if gammacheck,
            g = filter_lfp(s, [gammamin gammamax]);
            gp=plot(x, g, 'w');
            if hraw,
                set(gp, 'linewidth', 2, 'tag', 'LineObjectg2', 'userdata', g);
            else
                set(gp, 'linewidth', 1.9, 'tag', 'LineObjectg2', 'userdata', g);
            end
        end
    end
    
    if hraw==0,
        legend(groupnames(1, 1:numlines), 'Location', 'Best');
        legend boxoff;
    end
    set(gca, 'xlim', [min(x) max(x)]);
    axis off;
end

ylim1 = get(findobj(gcf, 'tag', 'MainAxis2'), 'ylim');
ylim2 = get(findobj(gcf, 'tag', 'MainAxis4'), 'ylim');
ymin = min([ylim1 ylim2]);
ymax = max([ylim1 ylim2]);
set(findobj(gcf, 'tag', 'MainAxis2'), 'ylim', [ymin ymax]);
set(findobj(gcf, 'tag', 'MainAxis4'), 'ylim', [ymin ymax]);


%update local plotting preferences:
UserPref = getpref('MonkeyLogic', 'UserPreferences');
LFPConfig.StartCode = get(findobj(gcf, 'tag', 'StartCode'), 'value');
LFPConfig.StartOffset = str2double(get(findobj(gcf, 'tag', 'StartOffset'), 'string'));
LFPConfig.Duration = str2double(get(findobj(gcf, 'tag', 'Duration'), 'string'));
LFPConfig.SmoothWindow = str2double(get(findobj(gcf, 'tag', 'SmoothWindow'), 'string'));
LFPConfig.SortOnTaskObject = get(findobj(gcf, 'tag', 'TaskObject'), 'value');
LFPConfig.SortOnAttribute = get(findobj(gcf, 'tag', 'TOFields'), 'value');
LFPConfig.ConditionsGrouping = get(findobj(gcf, 'tag', 'CondGroupMFile'), 'string');
LFPConfig.SelectedBlocks = get(findobj(gcf, 'tag', 'Blocks'), 'value');
LFPConfig.Trial = get(findobj(gcf, 'tag', 'Trial'), 'value');
LFPConfig.TrialError = get(findobj(gcf, 'tag', 'TrialError'), 'value');
LFPConfig.HideRaw = get(findobj(gcf, 'tag', 'HideRaw'), 'value');

LFPConfig.GlobalMinFreq = get(findobj(ls, 'tag', 'MinFrequency'), 'userdata');
LFPConfig.GlobalMaxFreq = get(findobj(ls, 'tag', 'MaxFrequency'), 'userdata');
LFPConfig.FreqStep = get(findobj(ls, 'tag', 'Step'), 'userdata');
LFPConfig.DeltaMin = get(findobj(ls, 'tag', 'DeltaMin'), 'userdata');
LFPConfig.DeltaMax = get(findobj(ls, 'tag', 'DeltaMax'), 'userdata');
LFPConfig.ThetaMin = get(findobj(ls, 'tag', 'ThetaMin'), 'userdata');
LFPConfig.ThetaMax = get(findobj(ls, 'tag', 'ThetaMax'), 'userdata');
LFPConfig.AlphaMin = get(findobj(ls, 'tag', 'AlphaMin'), 'userdata');
LFPConfig.AlphaMax = get(findobj(ls, 'tag', 'AlphaMax'), 'userdata');
LFPConfig.BetaMin = get(findobj(ls, 'tag', 'BetaMin'), 'userdata');
LFPConfig.BetaMax = get(findobj(ls, 'tag', 'BetaMax'), 'userdata');
LFPConfig.GammaMin = get(findobj(ls, 'tag', 'GammaMin'), 'userdata');
LFPConfig.GammaMax = get(findobj(ls, 'tag', 'GammaMax'), 'userdata');
LFPConfig.DeltaUse = get(findobj(ls, 'tag', 'DeltaCheck'), 'value');
LFPConfig.ThetaUse = get(findobj(ls, 'tag', 'ThetaCheck'), 'value');
LFPConfig.AlphaUse = get(findobj(ls, 'tag', 'AlphaCheck'), 'value');
LFPConfig.BetaUse = get(findobj(ls, 'tag', 'BetaCheck'), 'value');
LFPConfig.GammaUse = get(findobj(ls, 'tag', 'GammaCheck'), 'value');

UserPref.LFPSpectrogram = LFPConfig;
setpref('MonkeyLogic', 'UserPreferences', UserPref);

set(ls, 'pointer', 'arrow');

end