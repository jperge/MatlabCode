function [output groupnames fnames] = sortconditems(taskobjects, varargin)
%SYNTAX:
%        [output groupnames fnames] = sortconditems(taskobject, sortfield)
%
% If sortfield is not set or does not match a non-empty field of TaskObject
% then output will return empty, but fnames will still contain only the 
% used (i.e., nonempty) fields from taskobjects.
%
% Create 6/9/11  -WA

if ~iscell(taskobjects) || size(taskobjects, 2) > 1,
    error('Input to "sortconditems" should be a single column from the cell array "BHV.TaskObject"');
end

numobjects = length(taskobjects);
TaskObject(1:numobjects) = struct('Type', '', 'Name', '', 'RawText', '', 'FunctionName', '', 'Xpos', [], 'Ypos', [], 'XYpos', [], 'Xsize', [], 'Ysize', [], 'XYsize', [], 'Color', [], 'FillFlag', [], 'WaveForm', [], 'Freq', [], 'NBits', [], 'OutputPort', []);
for obnum = 1:numobjects,
    object = taskobjects{obnum};
    object = object(object ~= '"'); %remove quotes that might have been added by Excel
    obtype = lower(object(1:3));
    TaskObject(obnum).Type = obtype;
    TaskObject(obnum).RawText = object;
    op = find(object == '(');
    cp = find(object == ')');
    attributes = parse_object(object(op+1:cp-1), double(','));
    numatt = length(attributes);
    if strcmp(obtype, 'fix'), %fixation target - syntax: fix(xpos, ypos)
        
        TaskObject(obnum).Xpos = str2double(attributes{1});
        TaskObject(obnum).Ypos = str2double(attributes{2});
        TaskObject(obnum).XYpos = [TaskObject(obnum).Xpos TaskObject(obnum).Ypos];

    elseif strcmp(obtype, 'pic'), %image file - syntax: pic(picname, xpos, ypos)

        TaskObject(obnum).Name = attributes{1};
        TaskObject(obnum).Xpos = str2double(attributes{2});
        TaskObject(obnum).Ypos = str2double(attributes{3});
        TaskObject(obnum).XYpos = [TaskObject(obnum).Xpos TaskObject(obnum).Ypos];

    elseif strcmp(obtype, 'gen'),

        funcname = lower(attributes{1});
        TaskObject(obnum).FunctionName = funcname;

        if numatt > 1,
            TaskObject(obnum).Xpos = str2double(attributes{2});
            TaskObject(obnum).Ypos = str2double(attributes{3});
        else
            TaskObject(obnum).Xpos = NaN;
            TaskObject(obnum).Ypos = NaN;
        end
        TaskObject(obnum).XYpos = [TaskObject(obnum).Xpos TaskObject(obnum).Ypos];

    elseif strcmp(obtype, 'snd'), %sound (can be generated sine-wave or read from .mat or .wav file) - syntax: snd(sndfile) or snd("sin", duration, frequency, nbits)

        sndfile = attributes{1};
        if numatt > 1,

            if strcmpi(sndfile, 'sin'),
                dur = str2double(attributes{2});
                cps = str2double(attributes{3});
                if numatt == 4,
                    nbits = str2double(attributes{4});
                else
                    nbits = 16;
                end
                fs = 44100;
                sampsine = fs/cps;
                totcycles = dur * cps;
                y = sin(0:(2*pi)/sampsine:(totcycles*2*pi));

                %check to see if identical sine wave already exists
                %(for naming purposes)

                if isempty(sinebank),
                    sinebank(1, 1:2) = [dur cps];
                    snum = 1;
                else
                    snum = find((sinebank(:, 1) == dur) & (sinebank(:, 2) == cps));
                    if isempty(snum),
                        snum = size(sinebank, 1) + 1;
                        sinebank(snum, 1:2) = [dur cps];
                    end
                end
                sndfile = ['sin' num2str(snum)];
            end
        end

        TaskObject(obnum).Name = sndfile;
        TaskObject(obnum).WaveForm = y;
        TaskObject(obnum).Freq = fs;
        TaskObject(obnum).NBits = nbits;

    elseif strcmp(obtype, 'mov'), %movie

        TaskObject(obnum).Name = attributes{1};
        TaskObject(obnum).Xpos = str2double(attributes{2});
        TaskObject(obnum).Ypos = str2double(attributes{3});
        TaskObject(obnum).XYpos = [TaskObject(obnum).Xpos TaskObject(obnum).Ypos];

    elseif strcmp(obtype, 'crc'), %circle - syntax: crc(diameter, rgb, fillflag, xpos, ypos)

        TaskObject(obnum).Radius = str2double(attributes{1});
        TaskObject(obnum).Color = eval(attributes{2});
        TaskObject(obnum).FillFlag = str2double(attributes{3});
        TaskObject(obnum).Xpos = str2double(attributes{4});
        TaskObject(obnum).Ypos = str2double(attributes{5});
        TaskObject(obnum).Name = 'Circle';
        TaskObject(obnum).XYpos = [TaskObject(obnum).Xpos TaskObject(obnum).Ypos];

    elseif strcmp(obtype, 'sqr'), %sqaure - syntax: sqr(size, rgb, fillflag, xpos, ypos)

        sz = eval(attributes{1});
        if length(sz) == 1,
            xsize = sz;
            ysize = sz;
        else
            xsize = sz(1);
            ysize = sz(2);
        end
        TaskObject(obnum).Xsize = xsize;
        TaskObject(obnum).Ysize = ysize;
        TaskObject(obnum).Color = eval(attributes{2});
        TaskObject(obnum).FillFlag = str2double(attributes{3});
        TaskObject(obnum).Xpos = str2double(attributes{4});
        TaskObject(obnum).Ypos = str2double(attributes{5});
        TaskObject(obnum).Name = 'Square';
        TaskObject(obnum).XYpos = [TaskObject(obnum).Xpos TaskObject(obnum).Ypos];
        TaskObject(obnum).XYsize = [TaskObject(obnum).Xsize TaskObject(obnum).Ysize];

    elseif strcmp(obtype, 'stm'), %stimulation - syntax: (outputport, datasource)

        TaskObject(obnum).OutputPort = str2double(attributes{1});
        TaskObject(obnum).Name = attributes{2};

    elseif strcmp(obtype, 'ttl'), %TTL pulse - syntax: ttl(outputport)

        TaskObject(obnum).OutputPort = str2double(attributes{1});
        TaskObject(obnum).Name = sprintf('TTL%i', ch);

    end
end

%remove empty fields
fnames = fieldnames(TaskObject);
numfields = length(fnames);
for i = 1:numfields,
    testarray = {TaskObject.(fnames{i})};
    if ischar(testarray{1}),
        testarray = unique(testarray);
        if length(testarray) == 1 && iscell(testarray),
            testarray = testarray{1};
        end
    else
        testarray = unique(cat(1, testarray{:}));
%         if length(testarray) == 1 && iscell(testarray),
%             testarray = testarray{1};
%             disp('yo')
%         end
    end
    if isempty(testarray),
        TaskObject = rmfield(TaskObject, fnames{i});
    end
end
fnames = fieldnames(TaskObject);

output = [];
groupnames = '';
if isempty(varargin),
    return
else
    sortfield = varargin{1};
end
if iscell(sortfield),
    sortfield = sortfield{:};
end
if ~ismember(sortfield, fnames),
    return
end

attribute = {TaskObject.(sortfield)};
if ischar(attribute{1}),
    [u i j] = unique(attribute);
elseif length(attribute{1}) > 1,
    [u i j] = unique(cat(1, attribute{:}), 'rows');
else
    [u i j] = unique(cat(1, attribute{:}));
end

numgroups = length(u);
output = cell(numgroups, 1);
for k = 1:numgroups,
    output{k} = find(j == k);
end

groupnames = u;
if isnumeric(groupnames),
    groupnames = cellstr(num2str(groupnames));
end

