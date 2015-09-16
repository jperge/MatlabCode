function [NexFileHeader, NexVarHeader, NexData] = nex_read(varargin)
%SYNTAX:
%			[NexFileHeader, NexVariableHeaders, NexData] = nex_read(filename, LFP)
%
% If 'filename' is omitted, you will be prompted for a file to be read.  LFP is an optional
% argument which will cause this function to read analog data from the NEX file (1=yes),
% even if the "Load LFP" option is not set in the SpikeTools configuration window.  If
% omitted, continuous data is read from the nex file according to that configuration option.
%
% Created 5/23/99  -WA
% modified 10/16/2000 to read NEX file versions up to 104 and to read analog channels. -WA
% modified 02/08/2004 to read multiple continuous data (Type=5) fragments. -WA
% corrected 06/25/2006 to fix bug in reading NEX filenames (line 28).

if ~ispref('MonkeyLogic', 'UserPreferences'),
    monkeylogic_config;
end
if ~ispref('MonkeyLogic', 'Directories'),
    monkeylogic_directories;
end
MLPref = getpref('MonkeyLogic', 'UserPreferences');
MLDir = getpref('MonkeyLogic', 'Directories');

dir_nex = strcat(MLDir.ExperimentDirectory, '*.nex');

if isempty(varargin),
    [filename pathname] = uigetfile(dir_nex, '*.nex');
    fid = fopen([pathname filename]);
else
    file = varargin{1};
    [pname fname ext] = fileparts(file);
    if isempty(ext),
        ext = '.nex';
    end
    if isempty(pname),
        pname = dir_nex;
    end
    nex_file = [pname filesep fname ext];
    fid = fopen(nex_file);
    if length(varargin) > 1,
        if varargin{2} == 1,
            MLPref.LoadLFP = 1; %will load continuous data blocks (Type = 5) even if not set in config window.
        end
    end
end

%Read File Header
NexFileHeader.MagicNumber = fread(fid, 1, 'int32');
NexFileHeader.Version = fread(fid, 1, 'int32');
NexFileHeader.Comment = fread(fid, 256, 'char');
NexFileHeader.Frequency = fread(fid, 1, 'double');
NexFileHeader.Beg = fread(fid, 1, 'int32');
NexFileHeader.End = fread(fid, 1, 'int32');
NexFileHeader.NumVars = fread(fid, 1, 'int32');
NexFileHeader.NextFileHeader = fread(fid, 1, 'int32');
NexFileHeader.Padding = fread(fid, 256, 'char');

if NexFileHeader.Version == 102,
    error('***** Error: No support for Beta NEX file version 102 *****');
end

%Read Variable Headers
% totalsteps = 2 * NexFileHeader.NumVars;
NexVarHeader(1:NexFileHeader.NumVars) = struct;
for i = 1:NexFileHeader.NumVars,
    NexVarHeader(i).Type = fread(fid, 1, 'int32'); %0 = neuron, 1 = event, 2 = interval, 3 = waveform, 4 = pop.vector 5 = LFP, 6 = marker
    NexVarHeader(i).Version = fread(fid, 1, 'int32');
    NexVarHeader(i).Name = deblank(char(fread(fid, 64, 'char')'));
    NexVarHeader(i).DataOffset = fread(fid, 1, 'int32');
    NexVarHeader(i).Count = fread(fid, 1, 'int32');
    NexVarHeader(i).WireNumber = fread(fid, 1, 'int32');
    NexVarHeader(i).UnitNumber = fread(fid, 1, 'int32');
    NexVarHeader(i).Gain = fread(fid, 1, 'int32');
    NexVarHeader(i).Filter = fread(fid, 1, 'int32');
    NexVarHeader(i).Xpos = fread(fid, 1, 'double');
    NexVarHeader(i).Ypos = fread(fid, 1, 'double');
    NexVarHeader(i).WFrequency = fread(fid, 1, 'double');
    NexVarHeader(i).ADtoMV = fread(fid, 1, 'double');
    NexVarHeader(i).NPointsWave = fread(fid, 1, 'int32');
    NexVarHeader(i).NMarkers = fread(fid, 1, 'int32'); % how many values are associated with each marker
    NexVarHeader(i).MarkerLength = fread(fid, 1, 'int32'); % how many characters are in each marker value
    NexVarHeader(i).MVOffset = fread(fid, 1, 'double'); % coeff to shift AD values in Millivolts: mv = raw*ADtoMV+MVOfffset (versions 104 and up)
    NexVarHeader(i).Padding = fread(fid, 60, 'char');    
    
    if strcmpi(NexVarHeader(i).Name(1:3), 'sig') && NexVarHeader(i).Type == 3,
        NexVarHeader(i).Name = ['wf_' NexVarHeader(i).Name]; %to avoid confusion with actual spike variables (these are average waveforms)
    end

end

%Read Variable Data
freq = NexFileHeader.Frequency;
NexData = cell(1, NexFileHeader.NumVars);
for i = 1:NexFileHeader.NumVars,
    numbytes = NexVarHeader(i).Count;
    dataoffset = NexVarHeader(i).DataOffset;
    type = NexVarHeader(i).Type;
    data = [];

    fstat = fseek(fid, dataoffset, -1);
    if fstat ~= 0,
        error('***** I/O error while reading NEX file *****');
        return
    end

    if type == 3, %need to read more data for waveforms
        numpoints = NexVarHeader(i).NPointsWave;
        timestamps = fread(fid, numbytes, 'int32')/freq;
        data = fread(fid, numbytes*numpoints, 'int16');
        data = data*NexVarHeader(i).ADtoMV + NexVarHeader(i).MVOffset;
    elseif type == 5, %Analog Data
        NexVarHeader(i).FragmentTimeStamps = fread(fid, numbytes, 'int32')/freq;
        NexVarHeader(i).FragmentIndex = fread(fid, numbytes, 'int32');
        numpoints = NexVarHeader(i).NPointsWave;
        if MLPref.LoadLFP == 1,
            data = fread(fid, numpoints, 'int16');
            data = data*NexVarHeader(i).ADtoMV + NexVarHeader(i).MVOffset;
        else
            data.Offset = ftell(fid); %to be used by nexgetlfp - everything it needs to find the right data sequence
            data.StartTime = NexVarHeader(i).FragmentTimeStamps;
            data.FragIndx = NexVarHeader(i).FragmentIndex;
            data.Frequency = NexVarHeader(i).WFrequency;
            data.NumPoints = numpoints;
            data.ADtoMV = NexVarHeader(i).ADtoMV;
            data.MVOffset = NexVarHeader(i).MVOffset;
        end               
    elseif type == 6 && NexFileHeader.Version >= 103, %need to check for marker fields
        data = fread(fid, numbytes, 'int32')/freq;
        for ii = 1:NexVarHeader(i).NMarkers,
            tempname = fread(fid, 64, 'char');
            tempname = tempname(find(tempname));
            NexVarHeader(i).MarkerName{ii} = char(tempname)';
            markerlength = NexVarHeader(i).MarkerLength;
            nummarkers = NexVarHeader(i).Count;
            markerchars = fread(fid, markerlength*nummarkers, 'char');
            markervalues = str2num(deblank(char(reshape(markerchars, markerlength, nummarkers)')));
            NexVarHeader(i).MarkerValues{ii} = markervalues;
        end
    else
        data = fread(fid, numbytes, 'int32')/freq;
    end
    NexData{i} = data;

end

fclose(fid);