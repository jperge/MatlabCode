function output = batchgui(varargin)
% To be launched from the "monkeywrench" menu.
%
% Created by WA  6/7/2011
% Last Modified 5/9/2013 -WA (to allow for multiple output variables from the batched function)
%
% See also: batch, getbatchresult, editsource, monkeywrench

bgui = findobj('tag', 'MonkeyWrenchBatchGUI');
MLdir = getpref('MonkeyLogic', 'Directories');

if isempty(bgui),
    bgui = figure;
    bgcol = [.95 .95 .95];
    set(bgui, 'position', [400 300 700 380], 'color', bgcol, 'numbertitle', 'off', 'name', 'MonkeyWrench Batch Analysis', 'menubar', 'none', 'resize', 'off', 'tag', 'MonkeyWrenchBatchGUI');

    %select analysis function
    uicontrol('style', 'text', 'position', [25 350 270 20], 'string', 'Analysis Function:', 'backgroundcolor', bgcol, 'fontsize', 11, 'horizontalalignment', 'center');
    uicontrol('style', 'pushbutton', 'position', [20 328 270 25], 'string', 'Select', 'tag', 'AnalysisFunction', 'callback', 'batchgui');
    
    %output variables
    uicontrol('style', 'text', 'position', [325 90 160 20], 'string', 'Output Variables:', 'backgroundcolor', bgcol, 'fontsize', 10, 'horizontalalignment', 'center');
    uicontrol('style', 'listbox', 'position', [325 15 160 75], 'backgroundcolor', [1 1 1], 'tag', 'OutputVariables');
    
    %output MATfile text box
    uicontrol('style', 'text', 'position', [300 315 300 35], 'string', '', 'tag', 'MATfile', 'backgroundcolor', bgcol, 'fontsize', 10, 'horizontalalignment', 'left');
    
    %BHV file list
    bhvfiles = bhvlist;
    for i = 1:length(bhvfiles),
        bhvtxt(i) = bhvfiles(i);
        [~, fname] = fileparts(bhvtxt{i});
        nexfile = [MLdir.ExperimentDirectory fname '.nex'];
        if exist(nexfile, 'file'),
            bhvtxt{i} = [bhvfiles{i} '  (+nex)'];
        end
    end
    uicontrol('style', 'text', 'position', [15 287 300 17], 'string', 'BHV files', 'backgroundcolor', bgcol, 'fontsize', 10);
    uicontrol('style', 'listbox', 'position', [15 15 300 270], 'tag', 'FileList', 'backgroundcolor', [1 1 1], 'max', 100000, 'string', bhvtxt, 'userdata', bhvfiles);
    
    %Ancillary data field list
    adata = loadancillarydata('AncillaryData');
    if ~isempty(adata),
        fn = fieldnames(adata);
        fn = fn(3:end);
    else
        fn = '';
    end
    uicontrol('style', 'text', 'position', [325 287 160 17], 'string', 'Ancillary Data Fields', 'backgroundcolor', bgcol, 'fontsize', 10);
    uicontrol('style', 'listbox', 'position', [325 115 160 170], 'tag', 'AncillaryDataFields', 'backgroundcolor', [1 1 1], 'max', 100000, 'string', fn);
    
    %Iterate by parameter
    h = uibuttongroup('position', [.71 .3 .27 .45], 'tag', 'IterateParameterGroup', 'backgroundcolor', bgcol);
    uicontrol('style', 'text', 'position', [510 250 165 20], 'string', 'Iterate function by:', 'backgroundcolor', bgcol, 'fontsize', 10, 'backgroundcolor', bgcol);
    uicontrol('style', 'radio', 'parent', h, 'position', [55 100 100 20], 'string', 'Neuron', 'tag', 'Neuron', 'fontsize', 10, 'backgroundcolor', bgcol);
    uicontrol('style', 'radio', 'parent', h, 'position', [55 60 100 20], 'string', 'LFP', 'tag', 'LFP', 'fontsize', 10, 'backgroundcolor', bgcol);
    uicontrol('style', 'radio', 'parent', h, 'position', [55 20 100 20], 'string', 'File', 'tag', 'File', 'fontsize', 10, 'backgroundcolor', bgcol);

    %Select all BHV files, Execute & Stop buttons
    uicontrol('style', 'pushbutton', 'position', [500 80 190 30], 'string', 'Select all BHV files', 'tag', 'SelectAllFiles', 'callback', 'batchgui');
    uicontrol('style', 'pushbutton', 'position', [500 40 190 40], 'string', 'Execute', 'tag', 'Execute', 'callback', 'batchgui');
    uicontrol('style', 'togglebutton', 'position', [500 10 190 30], 'string', 'Stop', 'tag', 'StopButton', 'enable', 'off', 'callback', 'batchgui');
    
else
    figure(bgui);
end

if ~isempty(varargin), %called with argument
    callerfxn = varargin{1};
    if length(varargin) > 1,
        callerarg = varargin{2};
    else
        callerarg = [];
    end
    if strcmpi(callerfxn, 'placeholder'),

    elseif strcmpi(callerfxn, 'placeholder'),

    end
elseif ~isempty(gcbo) && ismember(gcbo, get(bgui, 'children')),
    callerhandle = gcbo;
    callertag = get(callerhandle, 'tag');
    switch callertag
        case 'AnalysisFunction',
            if isfield(MLdir, 'AnalysisDirectory'),
                pname = MLdir.AnalysisDirectory;
            else
                pname = MLdir.ExperimentDirectory;
            end
            [fname pname] = uigetfile([pname '*.m'], 'Choose matlab function');
            if ~isfield(MLdir, 'AnalysisDirectory'),
                MLdir.AnalysisDirectory = pname;
                setpref('MonkeyLogic', 'Directories', MLdir);
            end
            if isempty(fname) || isnumeric(fname),
                return
            end
            if nargin(fname) > 1 || nargin(fname) < 1,
                error('Analysis function should expect exactly one input argument');
            end
            if nargout(fname) < 1,
                error('Analysis function should produce at least one output variable');
            end
            set(callerhandle, 'string', fname, 'userdata', fname);

            fxn = [pname fname];
            vars = getfxndefvars(fxn);
            set(findobj(gcf, 'tag', 'OutputVariables'), 'string', vars);

        case 'SelectAllFiles',
            h = findobj(bgui, 'tag', 'FileList');
            n = length(get(h, 'userdata'));
            set(h, 'value', 1:n);
            
        case 'Execute',
            if isempty(get(findobj('tag', 'AnalysisFunction'), 'userdata')),
                disp('Please select an analysis function to batch.');
                return
            end
            set(findobj(bgui, 'tag', 'MATfile'), 'string', '');
            str = get(findobj('tag', 'AnalysisFunction'), 'string');
            [~, analysisfunction] = fileparts(str);
            h = findobj(bgui, 'tag', 'FileList');
            v = get(h, 'value');
            flist = get(h, 'userdata');
            bhvfiles = flist(v);
            h = findobj(bgui, 'tag', 'IterateParameterGroup');
            iterateparameter = get(get(h, 'SelectedObject'), 'tag');
            set(findobj(bgui, 'tag', 'StopButton'), 'enable', 'on');
            [output MATfile] = batch(analysisfunction, bhvfiles, iterateparameter);
            set(findobj(bgui, 'tag', 'StopButton'), 'enable', 'off');
            set(findobj(bgui, 'tag', 'MATfile'), 'string', ['Created ' MATfile]);
            monkeywrench('Message', ['Created ' MATfile]);
            figure(bgui);
        case 'StopButton',
            set(findobj('tag', 'MonkeyWrenchBatchGUI'), 'userdata', 'StopExecution');
    end
end