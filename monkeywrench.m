function monkeywrench(varargin)
%
% Created by WA  6/7/2011
% Last modified 5/15/2012  --WA

mwh = findobj('tag', 'MonkeyWrenchMainWindow');
if ~ispref('MonkeyLogic', 'Directories'),
    success = monkeylogic_directories;
    if ~success,
        error('Could not set directories');
    end
end
MLdir = getpref('MonkeyLogic', 'Directories');
%UserPref = getpref('MonkeyLogic', 'UserPreferences');

if isempty(mwh),
    mwh = figure;
    bgcol = [.93 .93 .93];
    set(mwh, 'position', [250 400 800 400], 'color', bgcol, 'numbertitle', 'off', 'name', 'MonkeyWrench', 'menubar', 'none', 'resize', 'off', 'tag', 'MonkeyWrenchMainWindow');
    uicontrol('style', 'pushbutton', 'position', [25 131 100 30], 'string', 'Load Data', 'tag', 'LoadData', 'callback', 'monkeywrench');
    uicontrol('style', 'pushbutton', 'position', [25 95 100 30], 'string', 'Batch Analysis', 'tag', 'BatchAnalysis', 'callback', 'monkeywrench');
    
    %Current Directory Frame
    x = 135; y = 95;
    uicontrol('style', 'frame', 'position', [x y 340 65], 'backgroundcolor', bgcol);
    uicontrol('style', 'pushbutton', 'position', [x+86 y+33 160 25], 'string', 'Change Data Directory', 'tag', 'ChangeDataDirectory', 'callback', 'monkeywrench');
    uicontrol('style', 'frame', 'position', [x+10 y+5 322 23], 'backgroundcolor', [1 1 1]);
    uicontrol('style', 'edit', 'position', [x+11 y+6 320 21], 'string', MLdir.ExperimentDirectory, 'tag', 'ExperimentDirectoryTxt', 'backgroundcolor', [1 1 1], 'userdata', MLdir.ExperimentDirectory, 'callback', 'monkeywrench');
    
    %Active File Info
    x = 15; y = 170;
    uicontrol('style', 'text', 'position', [x+10 y+180 80 25], 'string', 'Active Data:', 'backgroundcolor', bgcol, 'fontsize', 11);
    uicontrol('style', 'text', 'position', [x+100 y+180 350 25], 'string', '', 'tag', 'ActiveDataFile', 'backgroundcolor', bgcol, 'fontsize', 11, 'horizontalalignment', 'left');
    uicontrol('style', 'text', 'position', [x+140 y+153 120 20], 'string', 'Neurons', 'tag', 'NeuronTxt', 'backgroundcolor', bgcol);
    uicontrol('style', 'listbox', 'position', [x+140 y+10 120 145], 'string', {}, 'backgroundcolor', [1 1 1], 'tag', 'NeuronList', 'callback', 'monkeywrench');
    uicontrol('style', 'text', 'position', [x+10 y+153 120 20], 'string', 'LFPs', 'tag', 'LFPTxt', 'backgroundcolor', bgcol);
    uicontrol('style', 'listbox', 'position', [x+10 y+10 120 145], 'string', {}, 'backgroundcolor', [1 1 1], 'tag', 'LFPList', 'callback', 'monkeywrench');
    uicontrol('style', 'text', 'position', [x+595 y+153 168 20], 'string', 'Info', 'backgroundcolor', bgcol, 'tag', 'InfoTxt');
    uicontrol('style', 'listbox', 'position', [x+595 y+10 168 145], 'string', {}, 'backgroundcolor', [1 1 1], 'tag', 'InfoList');
    uicontrol('style', 'text', 'position', [x+290 y+156 120 17], 'string', '', 'backgroundcolor', bgcol, 'tag', 'SpikeRateTxt');
    
    %Neuron ISI & Waveform plots
    axes('position', [.36 .45 .18 .36])
    h = bar(1:100, zeros(1, 100), 1);
    set(h, 'tag', 'ISI', 'facecolor', [.3 .3 .3], 'barwidth', 1, 'linestyle', 'none');
    set(gca, 'xtick', [], 'ytick', [], 'box', 'on', 'tag', 'AxisISI', 'xlim', [0 100]);

    axes('position', [.56 .45 .18 .36]);
    h = plot(0, 0);
    set(h, 'tag', 'WaveForm', 'color', [.3 .3 .3], 'linewidth', 2.5);
    set(gca, 'xtick', [], 'ytick', [], 'box', 'on', 'tag', 'AxisWaveForm');

    %Message Text Box
    uicontrol('style', 'text', 'position', [10 5 780 25], 'backgroundcolor', bgcol, 'tag', 'MessageBox', 'string', '', 'fontsize', 11);

    %PROGRESS BARS
    shadestep = 0.05;
    
    %ProgressBar 1 (background + foreground)
    axes('position', [.03 .16 .94 .05]);
    col = [1 1 1];
    count = 0;
    for j = 0:shadestep:(1-shadestep),
        count = count + 1;
        thiscol = col * (1-abs(0.5 - j));
        h = patch([0 1 1 0], [j j j+shadestep j+shadestep], thiscol);
        set(h, 'edgecolor', 'none', 'tag', 'ProgressBar');
    end
    h(1) = line([0 0], [0 1]); h(2) = line([1 1], [0 1]); set(h, 'linewidth', 1, 'color', [.5 .5 .5]);
    set(gca, 'box', 'on', 'xtick', [], 'ytick', [], 'xlim', [0 1], 'ylim', [0 1], 'handlevisibility', 'off');

    axes('position', [.03 .16 .94 .05]);
    col = [1 0 0];
    count = 0;
    for j = 0:shadestep:(1-shadestep),
        count = count + 1;
        thiscol = col * (1-abs(0.5 - j));
        h = patch([0 0 0 0], [j j j+shadestep j+shadestep], thiscol);
        set(h, 'edgecolor', 'none', 'tag', 'ProgressBar');
    end
    set(gca, 'box', 'on', 'xtick', [], 'ytick', [], 'xlim', [0 1], 'ylim', [0 1]);
    axis('off');

    %ProgressBar 2 (background + foreground)
    axes('position', [.03 .09 .94 .05]);
    col = [1 1 1];
    count = 0;
    for j = 0:shadestep:(1-shadestep),
        count = count + 1;
        thiscol = col * (1-abs(0.5 - j));
        h = patch([0 1 1 0], [j j j+shadestep j+shadestep], thiscol);
        set(h, 'edgecolor', 'none', 'tag', 'ProgressBar2');
    end
    h(1) = line([0 0], [0 1]); h(2) = line([1 1], [0 1]); set(h, 'linewidth', 1, 'color', [.5 .5 .5]);
    set(gca, 'box', 'on', 'xtick', [], 'ytick', [], 'xlim', [0 1], 'ylim', [0 1], 'handlevisibility', 'off');

    axes('position', [.03 .09 .94 .05]);
    col = [1 0 0];
    count = 0;
    for j = 0:shadestep:(1-shadestep),
        count = count + 1;
        thiscol = col * (1-abs(0.5 - j));
        h = patch([0 0 0 0], [j j j+shadestep j+shadestep], thiscol);
        set(h, 'edgecolor', 'none', 'tag', 'ProgressBar2');
    end
    set(gca, 'box', 'on', 'xtick', [], 'ytick', [], 'xlim', [0 1], 'ylim', [0 1]);
    axis('off')
    
    %Plotting
    uicontrol('style', 'pushbutton', 'position', [486 131 140 30], 'string', 'Spike Rate Histogram', 'tag', 'SpikeRateHistogram', 'callback', 'monkeywrench');
    uicontrol('style', 'pushbutton', 'position', [486 95 140 30], 'string', 'LFP Spectrogram', 'tag', 'LFPSpectrogram', 'callback', 'monkeywrench', 'callback', 'monkeywrench');
    
    setactivedatainfo(mwh);
else
    figure(mwh);
    mwmessage(mwh, '');
end

if ~isempty(varargin), %called with argument
    callerfxn = varargin{1};
    if length(varargin) > 1,
        callerarg = varargin{2};
    else
        callerarg = [];
    end
    if strcmpi(callerfxn, 'UpdateActiveData'),
        setactivedatainfo(mwh);
    elseif strcmpi(callerfxn, 'ProgressBar'),
        figure(mwh);
        progressfraction = callerarg;
        updateprogressbar(mwh, progressfraction, 1);
    elseif strcmpi(callerfxn, 'ProgressBar2'),
        figure(mwh);
        progressfraction = callerarg;
        updateprogressbar(mwh, progressfraction, 2);
    elseif strcmpi(callerfxn, 'UpdateNeuronFigs'),
        sig = varargin{2};
        h = findobj(gcf, 'tag', 'NeuronList');
        neurons = get(h, 'string');
        [~, where] = intersect(neurons, sig);
        set(h, 'value', where);
        figure(mwh);
        updateancillaryinfo(mwh);
        updateneuronfigs(mwh);
    elseif strcmpi(callerfxn, 'Message'),
        mwmessage(mwh, callerarg);
    end
elseif ~isempty(gcbo) && ismember(gcbo, get(mwh, 'children')),
    callerhandle = gcbo;
    callertag = get(callerhandle, 'tag');
    switch callertag
        case 'LoadData',
            set(mwh, 'pointer', 'watch'); drawnow;
            D = opendatafile; %% Needed to change this function to analyze rodent data
            %files. Wael and I needed to modify trial start codes from '8' to '1' and
            %end codes from '18' to '2'. This was in the early stages of the rodent rig, and was necessary to encounter max 16 event values (not a constraint anymore). 
            %Eventually, we could migrate back to the original event codes. Till then, the data needs to be analyzed with a modified 'opendatafile.m'
            %Janos Perge, April 8, 2015
            %D = openRodentDataFile; 
            if isempty(D),
                return
            end
            set(findobj(gcf, 'tag', 'NeuronList'), 'value', 1);
            setactivedatainfo(mwh);
            mwmessage(mwh, 'Successfully loaded new data');
            updateneuronfigs(mwh);
            updateprogressbar(mwh, 0, 1);
            set(mwh, 'pointer', 'arrow');
            
        case 'BatchAnalysis',
            batchgui;

        case 'ChangeDataDirectory',
            success = monkeylogic_directories;
            if success,
                MLdir = getpref('MonkeyLogic', 'Directories');
                set(findobj(mwh, 'tag', 'ExperimentDirectoryTxt'), 'string', MLdir.ExperimentDirectory);
                mwmessage(mwh, 'Successfully updated data directory');
            end
            
        case 'ExperimentDirectoryTxt',
            userdir = get(callerhandle, 'string');
            if isdir(userdir),
                MLdir.ExperimentDirectory = userdir;
                set(callerhandle, 'userdata', MLdir.ExperimentDirectory);
                setpref('MonkeyLogic', 'Directories', MLdir);
                mwmessage(mwh, 'Successfully updated data directory');
            else
                set(callerhandle, 'string', get(callerhandle, 'userdata'));
                mwmessage(mwh, 'Specified directory not found');
            end
            
        case 'NeuronList',
            updateancillaryinfo(mwh);
            updateneuronfigs(mwh);
            
        case 'LFPList',
            
            
        case 'SpikeRateHistogram',
            h = findobj(mwh, 'tag', 'NeuronList');
            v = get(h, 'value');
            neuronlist = get(h, 'userdata');
            signame = neuronlist{v};
            spikeratehistogram(signame);
            

        case 'LFPSpectrogram',
            h = findobj(mwh, 'tag', 'LFPList');
            v = get(h, 'value');
            lfplist = get(h, 'userdata');
            signame = lfplist{v};
            lfpspectrogram(signame);
            
    end
end



%%
function setactivedatainfo(mwh)

[BHV NEURO] = getactivedata;
if ~isempty(BHV),
    neuron_ids = fieldnames(NEURO.Neuron);
    lfp_ids = fieldnames(NEURO.LFP);
    numneurons = length(neuron_ids);
    numlfp = length(lfp_ids);
    
    set(findobj(mwh, 'tag', 'ActiveDataFile'), 'string', BHV.DataFileName);
    set(findobj(mwh, 'tag', 'NeuronTxt'), 'string', sprintf('Neurons (%i)', numneurons));
    set(findobj(mwh, 'tag', 'NeuronList'), 'string', neuron_ids, 'userdata', neuron_ids, 'value', 1);
    set(findobj(mwh, 'tag', 'LFPTxt'), 'string', sprintf('LFPs (%i)', numlfp));
    set(findobj(mwh, 'tag', 'LFPList'), 'string', lfp_ids, 'userdata', lfp_ids, 'value', 1);
    
    updateancillaryinfo(mwh);
    updateneuronfigs(mwh);
end

%%
function updateprogressbar(mwh, progressfraction, whichbar)

if whichbar == 1,
    progressbar = findobj(mwh, 'tag', 'ProgressBar');
elseif whichbar == 2,
    progressbar = findobj(mwh, 'tag', 'ProgressBar2');
end
x = [0 progressfraction progressfraction 0];
for i = 1:length(progressbar),
    set(progressbar(i), 'xdata', x);
end
set(gca, 'xlim', [0 1], 'ylim', [0 1]);
%mwmessage(mwh, '');
drawnow;

%%
function updateancillaryinfo(mwh)

[~, NEURO] = getactivedata;
ancillary_fields = fieldnames(NEURO.NeuronInfo);
nfields = length(ancillary_fields);
for i = 1:nfields,
    lengthfn(i) = length(ancillary_fields{i});
end
maxfn = max(lengthfn);

h = findobj(mwh, 'tag', 'NeuronList');
n = get(h, 'value');
neuronlist = get(h, 'userdata');
thisneuron = neuronlist{n};

infotxt = cell(nfields, 1);
for i = 1:nfields,
    thisfield = ancillary_fields{i};
    info = NEURO.NeuronInfo.(thisfield)(n);
    if isnumeric(info),
        info = num2str(info);
    elseif iscell(info),
        info = info{1};
        if isnumeric(info),
            info = num2str(info);
        end
    end
    filler = '';
    filler(1:(maxfn-lengthfn(i))) = ' ';
    infotxt{i} = [thisfield ':    ' filler info];
end
set(findobj(mwh, 'tag', 'InfoList'), 'string', infotxt, 'value', 1);
set(findobj(mwh, 'tag', 'InfoTxt'), 'string', sprintf('Info (%s)', thisneuron));

%%
function updateneuronfigs(mwh)

[~, NEURO] = getactivedata;
h = findobj(mwh, 'tag', 'NeuronList');
n = get(h, 'value');
neuron_ids = get(h, 'userdata');
selectedneuron = neuron_ids{n};

hplot = findobj(mwh, 'tag', 'ISI');
t = NEURO.Neuron.(selectedneuron);
d = diff(t);
n = hist(d, 1:101);
set(hplot, 'ydata', n(1:100));

avgrate = length(t)/NEURO.RecordingDurationInSeconds;
set(findobj('tag', 'SpikeRateTxt'), 'string', sprintf('Average %3.1f Spikes/sec', avgrate));

if isfield(NEURO, 'NeuronWaveForm') && ~isempty(NEURO.NeuronWaveForm),
    hplot = findobj(mwh, 'tag', 'WaveForm');
    wf = NEURO.NeuronWaveForm.(selectedneuron);
    set(hplot, 'xdata', 1:length(wf), 'ydata', wf);
    set(gca, 'xlim', [0 length(wf)], 'ylim', 1.1*([min(wf) max(wf)]));
end
drawnow;

%%
function mwmessage(mwh, msgstring)

set(findobj(mwh, 'tag', 'MessageBox'), 'string', msgstring);
drawnow;

