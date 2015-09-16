function D = opendatafile(varargin)
%SYNTAX: 
%        D = opendatafile(filename)
%
%The input argument 'filename' is optional; if not specified, a dialog box
%will prompt the user for a data file.
%
%The data file may be either a bhv or a nex file.  That file will load
%along with the corresponding nex or bhv file (file names must be
%identical).  
%
%Must call this function before calling nexgetspike or nexgetlfp.
%
%If there exists a text file named "AncillaryData.txt" in the experiment
%directory, this will be opened and the data appended to NEURO.Neuron, with
%the field names determined by the header for each column.  The first
%column is expected to contain a filename, and the second is expected to
%contain a neuron label (e.g., 'sig003b').  These are used to match the
%data in the remaining columns to the appropriate record.  Each item in the
%resulting array is matched to the corresponding signal in order.
%
%Created by WA, June, 2008
%Last modified 6/8/2011  -WA

D = [];
verify = 0;

BHV = [];
NEURO = struct;
NEURO.File = '';
NEURO.RecordingDurationInSeconds = [];
NEURO.Neuron = struct;
NEURO.NeuronInfo = [];
NEURO.NeuronWaveForm = [];
NEURO.LFP = struct;
NEURO.CodeTimes = [];
NEURO.CodeNumbers = [];

foundneuro = 0; %has a neurophysiology data file been found; right now, only supports nex files...

monkeywrench('ProgressBar', 0);

if ~ispref('MonkeyLogic', 'Directories'),
    success = set_ml_preferences;
    if ~success,
        return
    end
end
MLPrefs.Directories = getpref('MonkeyLogic', 'Directories');
MLPrefs.Directories.ExperimentDirectory = [fileparts(MLPrefs.Directories.ExperimentDirectory) filesep]; %eliminates extra trailing backslash

if ~ispref('MonkeyLogic', 'UserPreferences'),
    success = monkeywrench_config;
    if ~success, return; end
end
MLPrefs.UserPrefs = getpref('MonkeyLogic', 'UserPreferences');
readLFP = MLPrefs.UserPrefs.LoadLFP;
if readLFP > 0,
    disp('... Warning: Pre-loading all LFP data into memory not currently supported ...')
    readLFP = 0;
end

if isempty(varargin),
    [fname pname] = uigetfile([MLPrefs.Directories.ExperimentDirectory '*.bhv; *.nex'], 'Choose data file...');
    if ~fname,
        return
    end
    NEURO.File = [pname fname];
    verify = 1;
else
    if length(varargin) == 1
        [pname fname ext] = fileparts(varargin{1});
        if isempty(pname),
            pname = MLPrefs.Directories.ExperimentDirectory;
        end
        if isempty(ext),
            ext = '.nex';
        end
        NEURO.File = [pname fname ext];
    else
        NEURO.File = varargin{1};
    end
end

setpref('MonkeyLogic', 'Directories', MLPrefs.Directories);

knownfiles = {'nex'};
VarNames.BehavioralCodes = 'Strobed';
VarNames.Neurons = 'Sig';
VarNames.LFP = 'AD';
VarNames.EyeX = 'EyeX';
VarNames.EyeY = 'EyeY';
VarNames.JoyX = 'JoyX';
VarNames.JoyY = 'JoyY';
AncillaryDataFileName = 'AncillaryData.txt';

% start_trial_code = MLPrefs.UserPrefs.StartTrialCode;
% end_trial_code = MLPrefs.UserPrefs.EndTrialCode;
start_trial_code = 1;
end_trial_code = 2; %%these two lines are the only deviations from opendatafile.m

[pname fname ext] = fileparts(NEURO.File);
filetype = [];
if strcmpi(ext, '.bhv'),
    bhvfile = NEURO.File;
    for i = 1:length(knownfiles),
        testfile = strrep(NEURO.File, '.bhv', ['.' knownfiles{i}]);
        if exist(testfile, 'file'),
            filetype = knownfiles{i};
            NEURO.File = testfile;
            break
        end
    end
else
    bhvfile = strrep(NEURO.File, '.nex', '.bhv');
    filetype = ext;
end

if exist(bhvfile, 'file'),
    monkeywrench('Message', 'Reading BHV file...');
    BHV = bhv_read(bhvfile);
    monkeywrench('ProgressBar', 1/10);
end

if strfind(filetype, 'nex'),
    foundneuro = 1;
    monkeywrench('Message', 'Reading NEX file...');
    [fh vh d] = nex_read(NEURO.File, readLFP);
    
    NEURO.RecordingDurationInSeconds = (fh.End - fh.Beg)/fh.Frequency;
    monkeywrench('ProgressBar', 4/10);
    vn = cat(1, {vh.Name});
    numvars = length(vn);

    %Determine index to each variable expected in VarNames, given above
    fn = fieldnames(VarNames);
    n = length(fn);
    monkeywrench('Message', 'Sorting data file variables...');
    for i = 1:n,
        v = fn{i};
        flist = strfind(lower(vn), lower(VarNames.(v)));
        k = zeros(1, numvars);
        for ii = 1:numvars,
            if ~isempty(flist{ii}) && flist{ii} == 1,
                k(ii) = ii;
            end
        end
        k = k(logical(k));
        if ~isempty(k),
            VarIndex.(v) = k;
        else
            VarIndex.(v) = [];
        end
        monkeywrench('ProgressBar', 0.4 + (0.2*i/n));
    end
    
    %Extract behavioral codes
    monkeywrench('Message', 'Extracting behavioral codes...');
    fmarker = strmatch('Marker', {vh.Name});
    if ~isempty(fmarker) && isempty(VarIndex.BehavioralCodes), %behavioral codes stored as individual "markers",
        nmarkers = length(fmarker);
        codetimes = [];
        codenumbers = [];
        for i = 1:nmarkers,
            varnum = fmarker(i);
            markername = vh(varnum).Name;
            findus = strfind(markername, '_');
            if isempty(findus),
                error('Unknown naming convention for behavioral codes (e.g., "%s")', markername);
            end
            thiscode = str2double(markername(max(findus)+1:end));
            thesetimes = d{varnum};
            thesecodes = thiscode*ones(size(thesetimes));
            codetimes = [codetimes; thesetimes];
            codenumbers = [codenumbers; thesecodes];
        end
        [~, indx] = sort(codetimes);
        codetimes = codetimes(indx);
        codenumbers = codenumbers(indx);
        NEURO.CodeTimes = round(1000*codetimes);
        NEURO.CodeNumbers = codenumbers;
    else %behavioral codes stored as single "strobed" variable.
        NEURO.CodeTimes = round(1000*d{VarIndex.BehavioralCodes});
        NEURO.CodeNumbers = vh(VarIndex.BehavioralCodes).MarkerValues{1};
    end
    monkeywrench('ProgressBar', 7/10);

    %Extract spiketimes
    monkeywrench('Message', 'Extracting spike times...');
    fneuron = strmatch('Lead', {vh.Name});
    if ~isempty(fneuron) && isempty(VarIndex.Neurons), %neurons named according to "Lead X_XX_X'
        VarIndex.Neurons = fneuron;
    end
    
    for i = 1:length(VarIndex.Neurons), %remove spaces to make valid structure fieldnames
        varnum = VarIndex.Neurons(i);
        varname = vh(varnum).Name;
        if any(isspace(varname)),
            varname(isspace(varname)) = '_';
            vh(varnum).Name = varname;
        end
    end
    
    lasttime = 0;
    for i = 1:length(VarIndex.Neurons),
        k = VarIndex.Neurons(i);
        NEURO.Neuron.(vh(k).Name) = round(1000*d{k});
        lasttime = max([lasttime max(NEURO.Neuron.(vh(k).Name))]);
    end
    monkeywrench('ProgressBar', 8/10);

    monkeywrench('Message', 'Scanning LFP data...');
    %Placeholder for LFPs
    if VarIndex.LFP,
        for i = 1:length(VarIndex.LFP),
            k = VarIndex.LFP(i);
            NEURO.LFP.(vh(k).Name) = d{k};
        end
        %need to take into account fragment start time(s)...
    end
end

if ~foundneuro,
    error('No associated neurophysiology data file found');
end

%Extract WaveForm data:
monkeywrench('Message', 'Extracting neuronal waveforms...');
fstr = strfind({vh.Name}, 'wf_');
f = zeros(numvars, 1);
for i = 1:length(fstr),
    if ~isempty(fstr{i}),
        f(i) = 1;
    end
end
if any(f),
    f = find(f);
    for i = 1:length(f),
        varnum = f(i);
        signame = vh(varnum).Name;
        signame = signame(4:end);
        if length(signame) > 9 && strcmp(signame(end-8:end), '_template'),
            signame = signame(1:end-9);
        end
        NEURO.NeuronWaveForm.(signame) = d{varnum};
    end
end

%Extract Trials:
monkeywrench('Message', 'Determining trial boundaries...');
if ~isempty(NEURO.CodeTimes),
    c9 = (NEURO.CodeNumbers == start_trial_code);
    c18 = (NEURO.CodeNumbers == end_trial_code);
    t9 = NEURO.CodeTimes(c9);
    t18 = NEURO.CodeTimes(c18);
    if t18(1) < t9(1),
        error('An end-of-trial code precedes the first instance of a start-of-trial code');
    elseif t9(length(t9)) > t18(length(t18)),
        disp('Warning: A start-of-trial code follows the last end-of-trial code');
        t9 = t9(1:length(t18));
    end

    count = 0;
    r9 = t9;
    while ~isempty(r9),
        count = count + 1;
        starttrial = r9(1);
        NEURO.TrialTimes(count, 1) = starttrial;
        r18 = t18(t18 > starttrial);
        endtrial = r18(1);
        NEURO.TrialDurations(count, 1) = endtrial - starttrial;
        r9 = t9(t9 > endtrial);
    end
    NEURO.NumTrials = length(NEURO.TrialTimes);
else
    NEURO.TrialTimes = [];
    NEURO.TrialDurations = [];
    NEURO.NumTrials = 0;
end
monkeywrench('ProgressBar', 9/10);

%Assign Neuron and LFP channels based upon sig000x and AD00 nomenclature...
neuronlabels = fieldnames(NEURO.Neuron);
numneurons = length(neuronlabels);
lfplabels = fieldnames(NEURO.LFP);
numlfp = length(lfplabels);
disp(sprintf('%s: Found %i neurons & %i LFP channels', NEURO.File, numneurons, numlfp))

neuronchannels = zeros(numneurons, 1);
k = length(VarNames.Neurons) + 1;
for i = 1:numneurons,
    neuronchannels(i) = str2double(neuronlabels{i}(k:end-1));
end
NEURO.NeuronInfo.Channel = neuronchannels;

lfpchannels = zeros(numlfp, 1);
k = length(VarNames.LFP) + 1;
for i = 1:numlfp,
    lfpchannels(i) = str2double(lfplabels{i}(k:end));
    NEURO.LFP.(lfplabels{i}).Channel = lfpchannels(i);
end
NEURO.LFPInfo.Channel = lfpchannels;

%load & attach ancillary data
monkeywrench('Message', 'Loading & matching ancillary data...');
ADfile = [pname filesep AncillaryDataFileName];
if exist(ADfile, 'file'),
    AData = loadancillarydata(ADfile);
    fn = fieldnames(AData);
    fn = fn(3:end); %excludes FileName and Signal fields 
    numfields = length(fn);
    for k = 1:numfields,
        NEURO.NeuronInfo.(fn{k}) = cell(numneurons, 1);
    end
    for i = 1:numneurons,
        d = matchancillarydata(AData, fname, neuronlabels(i));
        for k = 1:numfields,
            NEURO.NeuronInfo.(fn{k})(i) = d.(fn{k});
        end
    end
end
monkeywrench('ProgressBar', 10/10);

if verify,
    %cross-check trial-durations:
    bhvnumtrials = length(BHV.ConditionNumber);
    if bhvnumtrials ~= NEURO.NumTrials,
        disp(sprintf('Trial Number Mismatch: %i trials found in NEX file and %i trials found in BHV file.', NEURO.NumTrials, bhvnumtrials))
    end
    numtrials = min([bhvnumtrials NEURO.NumTrials]);
    tduration = zeros(numtrials, 1);
    for t = 1:numtrials,
        ct = BHV.CodeTimes{t};
        cn = BHV.CodeNumbers{t};
        cstart = min(ct(cn == start_trial_code));
        cend = min(ct(cn == end_trial_code));
        tduration(t) = cend - cstart;
    end

    durdiff = NEURO.TrialDurations(1:numtrials) - tduration;
    D.TrialCrossCheck = durdiff;
end

D.NEURO = NEURO;
D.BHV = BHV;
set(0, 'userdata', D);

monkeywrench('UpdateActiveData');
monkeywrench('ProgressBar', 0);


