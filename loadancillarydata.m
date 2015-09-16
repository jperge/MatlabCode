function adata = loadancillarydata(file)
%
% Created by WA  6/7/2011

adata = {};
if ~exist(file, 'file'),
    [pname fname ext] = fileparts(file);
    if isempty(ext),
        ext = '.txt';
    end
    if isempty(pname),
        MLdir = getpref('MonkeyLogic', 'Directories');
        file = [MLdir.ExperimentDirectory fname ext];
        if ~exist(file, 'file'),
            disp('Ancillary data file not found');
        end
    else
        disp('Ancillary data file not found');
        return
    end
end

data = struct;
firstdatacol = 3;
fid = fopen(file);
if fid < 0,
    error('Cannot open %s', file);
end
labels = fgetl(fid); %assumes first row is the label for each data column
labels = cellstr(parse(labels));
datatypes = fgetl(fid); %assumes second row consists of labels describing data types for each column (e.g., "string" or "numeric")
datatypes = cellstr(parse(datatypes));
count = 0;
while ~feof(fid),
    count = count + 1;
    txt = fgetl(fid);
    txt = cellstr(parse(txt));
    [pname fname] = fileparts(txt{1});
    data(count).FileName = {fname};
    data(count).Signal = txt(2);
    n = length(txt);
    for i = firstdatacol:n,
        if strcmpi(datatypes{i}, 'string') || strcmpi(datatypes{i}, 'char'),
            data(count).(labels{i}) = txt(i);
        elseif strcmpi(datatypes{i}, 'numeric') || strcmpi(datatypes{i}, 'double'),
            val = str2double(txt{i});
            data(count).(labels{i}) = {val};
        else
            fclose(fid);
            error('Unknown data type "%s" specified in file %s; Must be "string" or "numeric"', datatypes{i}, file)
        end
    end
end
fclose(fid);

fn = fieldnames(data);
for i = 1:length(fn),
    adata.(fn{i}) = cat(1, data.(fn{i}));
end

