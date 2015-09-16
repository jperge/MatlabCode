function [output outputfile] = batch(fxn, datafiles, varargin)
% SYNTAX:
%   [output MATfile] = batch(function_name, input_list, optional_argument)
%
% This function batches an analysis function ('function_name') by sending
% it the names of individual neurons, LFP channels, or simply file names.
% The function must be written so as to expect one input argument: the name
% of the signal (or file name) currently being used.  It must specify one
% output, which will be grouped into a structure-cell array with all the
% other outputs from that function operating on each input taken from the
% data files specified in 'input_list'.
%
% The second output argument, 'MATfile', is the name of the MAT file in
% which the results of the batched analysis are stored.
%
% The argument 'input_list' specifies the list of datafiles to be used.
% Here, one can use "bhvlist" (without quotes) to indicate all data files
% within the current experimental directory.  The specified files can be
% BHV files or the associated NEX files.  Specifying both should be 
% avoided, because this will cause duplication of the results.
%
% The batched analysis function can be defined as:
%
% function [output] = myanalysisroutine(signalname)
%
% or
%
% function [output] = myanalysisroutine(filename)
%
% The batch function calls "opendatafile" to set the currently-active BHV 
% and NEX files.  These headers can be retrieved by calling "getactivedata"
% from within your analysis function:
%
%        [BHV NEURO] = getactivedata;
%
% The "optional_argument" can be 'spikes' or 'neuron' to identify the
% signal to pass along to the specified function (the default), 'lfp' for
% LFP signals, or 'file' to pass only each file name rather than the
% signals contained within it (such as when analyzing only behavioral
% data).
%
% A second optional argument can be specified to identify file(s) with
% ancillary data (in addition to "AncillaryData.txt" file which, if it
% exists, will be included by default).  These data (e.g., recording area 
% or recording coordinates) will be included with each output record.
% Files containing ancillary data must be tab-delimited with the file name 
% in the first column and the signal name (e.g., 'sig003b') in the second 
% column.  The remaining columns contain user-specified data.  The first 
% line of this text file must be a header row, in which the labels of each 
% user-specified column (beyond signal name) are used to name the fields of 
% the output structure, within the Results field.  The second line
% specifies the data type ('string' or 'numeric') for each column.
%
% Example call to 'batch':
%
% output = batch('testfunction', bhvlist, 'lfp', 'RecordingLocations');
%
% The output is as the following:
%
% output = 
%
%           AnalysisFunction: 'my_analysis_function'
%       AnalysisFunctionText: {92x1 cell}
%               AnalysisTime: '18-May-2012 15:38:28'
%           AnalysisDuration: '2 hrs 1 mins 20 secs'
%                    Results: [1x795 struct]
%
% In this case, a total of 795 LFP channels were passed to the function
% "testfunction" and that returned a result for each, which has been placed
% into a cell array in output.Results.  
%
% So that there is no ambiguity about how results were generated, the field
% "AnalysisFunctionText" contains the full analysis code that was sent to
% "batch".  To view and edit this, use the "editsource" function, with the
% full output structure as the input.  So for this example,
%
% editsource(output)
%
% would open an editor window with the source function (renamed here as
% "testfunction_source.m".
%
% The field "Results" contains "Data" in which the output of the batched 
% function is stored, as well as some other descriptive fields.  The tab-
% delimited text file 'RecordingLocations' was accessed to include 
% additional data:
%
% output.Results =
%
% 1x795 struct array with fields:
%    DataFile
%    FileNumber
%    Subject
%    Data
%    Area
%    Position_AP
%    Position_DV
%    Position_Depth
%
% Here, the fields Area, Position_AP, Position_DV and Position_Depth were
% derived from columns in the "RecordingLocations" text file with the field
% names found therein as headers. Meanwhile, DataFile, FileNumber and 
% Subject are standard fields included in all batched outputs (Subject is 
% retrieved from the BHV file header).
%
% The actual results of the analysis are stored in output.Results(n).Data.
%
% Created 5/27/11 -WA
% Last Modified by WA, 5/21/12
%
% See also: getbatchresult, batchgui, editsource, monkeywrench

output = struct;
typeflag = 1; %default is iterate by neuron
batchgui = findobj('tag', 'MonkeyWrenchBatchGUI');

if ~ischar(fxn),
    error('Target function must be specified as a string');
end

if ~exist(fxn, 'file'),
    error('Cannot find analysis function "%s"', fxn);
end

if nargin(fxn) > 1 || nargin(fxn) < 1,
    error('Analysis function should expect exactly one input argument');
end
% if nargout(fxn) > 1|| nargout(fxn) < 1,
%     error('Analysis function should produce exactly one output variable');
% end

disp(' ')
disp(' ')
fprintf(1, 'Target function: %s\n', fxn);

MLdir = getpref('MonkeyLogic', 'Directories');
pname = MLdir.ExperimentDirectory; 
datadir = [pname 'MAT_Files' filesep];
if ~isdir(datadir),
    mkdir(datadir);
    addpath(datadir);
    fprintf(1, 'Created data directory %s\r', datadir);
    MLdir.MATfileDirectory = datadir;
    setpref('MonkeyLogic', 'Directories', MLdir);
end
outputfile = [datadir fxn '.mat'];

output.AnalysisFunction = fxn;
output.AnalysisFunctionText = storerawfunction(fxn);
output.AnalysisTime = datestr(now);
output.TotalAnalysisDuration = '';
output.Results.DataFile = {};
output.Results.FileNumber = {};
output.Results.DataAcquiredTime = {};
output.Results.RecordAnalysisDuration = {};
output.Results.NeuronID = {};
output.Results.LFPID = {};
output.Results.Subject = {};
output.Results.Data = {};

appendflag = 0;
if exist(outputfile, 'file'),
    opt1 = 'Append/Modify'; opt2 = 'Append Only'; opt3 = 'Overwrite';
    msg = sprintf('Output file "%s" already exists:', [fxn '.mat']);
    ButtonName = questdlg(msg, 'Append/Modify/Overwrite?', opt1, opt2, opt3, opt1);
    if strcmp(ButtonName, opt1),
        appendflag = 1;
        output = load(outputfile);
    elseif strcmp(ButtonName, opt2),
        appendflag = 2;
        output = load(outputfile);
    elseif strcmp(ButtonName, opt3),
        appendflag = 0;
    else
        fprintf(1, 'Batch Analysis Cancelled');
        return
    end
end

if ischar(datafiles),
    datafiles = cellstr(datafiles);
end
if iscell(datafiles),
    numfiles = length(datafiles);
else
    error('The input argument "files" must contain a string or cell array of strings');
end

filename = cell(numfiles, 1);
for i = 1:numfiles,
    [~, fname] = fileparts(datafiles{i});
    filename{i} = fname;
end

if ~isempty(varargin), %Specify type of info to pass to analysis function
    typestring = varargin{1};
    if strcmpi(typestring, 'lfp'),
        typeflag = 2;
    elseif strcmpi(typestring, 'file'),
        typeflag = 3;
    else
        typeflag = 1; %neuron
    end
    if length(varargin) > 1, %Specify txt files with additional data (e.g., recording areas & locations)
        txtdatafiles = varargin{2};
        if ischar(txtdatafiles),
            txtdatafiles = cellstr(txtdatafiles);
        end
        txtdatafiles = [{'AncillaryData.txt'}; txtdatafiles];
    else
        txtdatafiles = {'AncillaryData.txt'};
    end
    numtxtfiles = length(txtdatafiles);
    AncillaryData = cell(numtxtfiles, 1);
    for fnum = 1:numtxtfiles,
        AncillaryData{fnum} = loadancillarydata(txtdatafiles{fnum});
    end
end

VARS = getfxndefvars(fxn);
numoutputs = nargout(fxn);
varlist = sprintf('%s ', VARS{:});
leftsidecall = sprintf('[%s]', varlist);

ticID = tic;
t0 = toc(ticID);
monkeywrench('ProgressBar2', 0);

quitflag = 0;
fnum = 0;
while fnum < numfiles,
    fnum = fnum + 1;
    D = opendatafile(datafiles{fnum});
    subject = {D.BHV.SubjectName};
    datatime = D.BHV.StartTime;
    if typeflag == 1, %Neuron
        sigs = fieldnames(D.NEURO.Neuron);
    elseif typeflag == 2, %LFP
        sigs = fieldnames(D.NEURO.LFP);
    elseif typeflag == 3, %Filenames
        sigs = filename(fnum);
    end
    numsigs = length(sigs);
    snum = 0;
    while snum < numsigs,
        snum = snum + 1;
        recnum = [];
        foundmatchingrec = 0;
        if appendflag,
            if typeflag < 3,
                [~, recnum] = getbatchresult(output, filename{fnum}, sigs{snum});
            else
                [~, recnum] = getbatchresult(output, filename{fnum});
            end
            if ~isempty(recnum),
                foundmatchingrec = 1;
            end
        end
        if ~(foundmatchingrec && appendflag == 2), %not "append only" with matching record already present
            if isempty(recnum),
                if fnum == 1 && snum == 1 && length(output.Results) == 1, %if no records yet created or loaded...
                    recnum = 1; %to account for the pre-assigment of output.Results
                else
                    recnum = length(output.Results) + 1; %append a new record
                end
            end
            if typeflag == 1, %neuron
                monkeywrench('UpdateNeuronFigs', sigs{snum});
                output.Results(recnum).NeuronID = sigs(snum);
            elseif typeflag == 2, %LFP
                output.Results(recnum).LFPID = sigs(snum);
            end
            if foundmatchingrec,
                fprintf(1, 'Entry #%i -- File %i of %i: Signal %i of %i  [ %s ]  *Modified*\n', recnum, fnum, numfiles, snum, numsigs, sigs{snum});
            else
                fprintf(1, 'Entry #%i -- File %i of %i: Signal %i of %i  [ %s ]  *Created*\n', recnum, fnum, numfiles, snum, numsigs, sigs{snum});
            end
            output.Results(recnum).DataFile = filename(fnum);
            output.Results(recnum).FileNumber = fnum;
            output.Results(recnum).DataAcquiredTime = datatime;
            output.Results(recnum).Subject = subject;
            eval(sprintf('%s = %s(''%s'');', leftsidecall, fxn, sigs{snum})); %calls user fxn, returns "data"
            for i = 1:numoutputs,
                output.Results(recnum).Data.(VARS{i}) = eval(VARS{i});
            end
            
            for i = 1:length(AncillaryData),
                adata = matchancillarydata(AncillaryData{i}, filename{fnum}, sigs{snum});
                fn = fieldnames(adata);
                for k = 1:length(fn),
                    output.Results(recnum).(fn{k}) = adata.(fn{k});
                end
            end
            t1 = toc(ticID);
            output.Results(recnum).RecordAnalysisDuration = t1-t0;
            t0 = t1;
            monkeywrench('ProgressBar2', (fnum - 1 + (snum/numsigs))/numfiles);
        else
            fprintf(1, 'Entry #%i -- File %i of %i: Signal %i of %i  [%s ]  *Not Modified*\n', recnum, fnum, numfiles, snum, numsigs, sigs{snum});
        end
        if ~isempty(batchgui), %check for "stop" button push
            msg = get(batchgui, 'userdata');
            if strcmp(msg, 'StopExecution'),
                fprintf(1, 'Pausing Batch Analysis.\n');               
                opt1 = 'Resume'; opt2 = 'Save and Quit'; opt3 = 'Quit without Saving';
                ButtonName = questdlg('Batch Execution Halted:', 'Resume/Quit/Save?', opt1, opt2, opt3, opt1);
                if strcmp(ButtonName, opt1),
                    fprintf(1, 'Resuming Batch Analysis...\n');
                elseif strcmp(ButtonName, opt2),
                    fprintf(1, 'Saving and Quitting...\n');
                    snum = numsigs;
                    fnum = numfiles;
                elseif strcmp(ButtonName, opt3),
                    fprintf(1, 'Batch Analysis Terminated without Save\n');
                    snum = numsigs;
                    fnum = numfiles;
                    quitflag = 1;
                else
                    fprintf(1, 'Resuming Batch Analysis...\n');
                end
            end
            set(batchgui, 'userdata', []);
        end
    end
    monkeywrench('ProgressBar2', fnum/numfiles);
end

if ~quitflag,
    tt = round(sum(cat(1, output.Results.RecordAnalysisDuration)));
    str = timestring(tt);
    output.TotalAnalysisDuration = str;
    %for this to be useful, needs to reflect the total amount of time required
    %to analyze all records in the output, not just those processed during this
    %run (e.g., using an append option).  Must also ignore user-triggered
    %pauses (using the "stop" button on the batch GUI).
    
    dt = datenum(cellstr(cat(1, output.Results.DataAcquiredTime)));
    [~, indx] = sort(dt);
    output.Results = output.Results(indx); %keep files in order of date of data acquisition.
    fprintf(1, 'Records ordered according to date/time of data acquisition\n');
    
    save(outputfile, '-struct', 'output');
    fprintf(1, 'Saved %s\n', outputfile);
end
monkeywrench('ProgressBar2', 0);


%%
function output = storerawfunction(fxn)

fid = fopen([fxn '.m'], 'r');
if ~fid < 0,
    error('Unable to open %s.m', fxn);
end

count = 0;
str = cell(5000, 1);
while ~feof(fid),
    count = count + 1;
    str{count} = fgetl(fid);
end
output = str(1:count);
fclose(fid);


%%
function output = timestring(input)

hrs = floor(input/3600);
min = floor(rem(input, 3600)/60);
sec = round(rem(input, 60));
output = sprintf('%i hrs %i mins %i secs', hrs, min, sec');
