function N = select_neurons(varargin)
% 'InfoFile'
% 'Area'
% 'FileName'
% 'FileNameContains'
% 'Position'
% 'Depth'
% 'RestrictBlocks'

numargs = length(varargin);
if isempty(varargin) || mod(numargs, 2),
    error('Function "select_neurons" requires arguments to come in parameter/value pairs')
end

P.infofile = '';
P.area = 'All';
P.filename = 'All';
P.filenamecontains = '';
P.position = 'All';
P.depth = 'All';
P.restrictblocks = 'No';

params = varargin(1:2:numargs);
vals = varargin{2:2:numargs};
numpairs = length(params);

for i = 1:numpairs,
    par = lower(params{(2*i)-1});
    val = vals{2*i};
    P.(par) = val;
end

if isempty(P.infofile),
    error('Must specify a value for "InfoFile"')
end
[pname fname] = fileparts(P.infofile);
PREF = getpref('MonkeyLogic');
expdir = PREF.Directories.ExperimentDirectory;
if isempty(pname),
    pname = expdir;
end
ext = '.mat';
P.infofile = [pname fname ext];
if ~exist(P.infofile, 'file'),
    error('Specified "InfoFile" not found - expected to be a ".mat" file created by "process_neuro_txt_file"');
end
load(P.infofile); %loads "M" structure

% File - Cell - Area - Position (AP, DV) - Depth(mm) - UseBlocks - NeuronType
if iscell(P.area) || ~strcmpi(P.area, 'all'),
    if ~iscell(P.area),
        P.area = {P.area};
    end
    for i = 1:length(P.area),
        f{i} = strmatch(lower(P.area{i}), lower({M.Area}));
    end
    C.Area = cat(1, f{:});
else
    C.area = 1:length(M);
end



