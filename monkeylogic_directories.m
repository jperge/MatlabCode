function success = monkeylogic_directories
%To be called when ~ispref('MonkeyLogic', 'Directories'), or by
%monkeywrench main menu
%
%Last modified 6/2011  -WA

if ispref('MonkeyLogic', 'Directories'),
    MLdir = getpref('MonkeyLogic', 'Directories');
else
    MLdir = [];
end

success = 0;
d = which('monkeylogic');
if isempty(d),
    if ~isempty(MLdir),
        startpath = MLdir.BaseDirectory;
    else
        startpath = '';
    end
    pname = uigetdir(startpath, 'Please indicate the location of the MonkeyLogic files...');
    if pname(1) == 0,
        return
    end
    addpath(pname);
else
    pname = fileparts(d);
end
monkeylogicdir = [pname filesep];

success = 0;
d = which('monkeylogic');
if isempty(d),
    if ~isempty(MLdir),
        startpath = MLdir.MonkeyWrenchDirectory;
    else
        startpath = '';
    end
    pname = uigetdir(startpath, 'Please indicate the location of the MonkeyWrench program files...');
    if pname(1) == 0,
        return
    end
    addpath(pname);
else
    pname = fileparts(d);
end
monkeywrenchdir = [pname filesep];

if ~isempty(MLdir),
    startpath = MLdir.ExperimentDirectory;
else
    startpath = '';
end
pname = uigetdir(startpath, 'Please select the directory for MonkeyLogic Experimental Data files...');
if pname(1) == 0,
    return
end
datadir = [pname filesep];

Directories.BaseDirectory = monkeylogicdir;
Directories.MonkeyWrenchDirectory = monkeywrenchdir;
Directories.ExperimentDirectory = datadir;
setpref('MonkeyLogic', 'Directories', Directories);
if ispref('MonkeyLogic', 'Directories'),
    success = 1;
else
    disp('*** Unable to set directory preferences ***')
end

