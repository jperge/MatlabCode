function vars = getfxndefvars(fxn)
%This function returns the names of the output variables of a function as
%they are defined in that function.  Used by "batch" and "batchgui."

fxn = deblank(fxn);
if ~strcmp(fxn(end-1:end), '.m'),
    fxn = [fxn '.m'];
end

fid = fopen(fxn, 'r');
if ~fid < 0,
    error('Unable to open %s.m', fxn);
end

vars = {};
breakout = 0;
while ~feof(fid) && ~breakout,
    STR = fgetl(fid);
    str = regexp(STR, 'f\w*', 'match');
    if ~isempty(str) && strcmp(str{1}, 'function'),
        [str brackets] = regexp(STR, '[[|]]', 'match');
        if isempty(str),
            vars = regexp(STR, '(?<=function )\w*(?=(\s|)=)', 'match');
            if ~isempty(vars),
                breakout = 1;
            end
        end
        if ~isempty(str),
            [str indx] = regexp(STR, '\w*', 'match');
            vars = str(indx > brackets(1) & indx < brackets(2));
            breakout = 1;
        end
    end
end
fclose(fid);

if isempty(vars),
    n = nargout(fxn);
    vars = cell(1, n);
    for i = 1:n,
        vars{i} = sprintf('VAR%i', i);
    end
end