function [BHV NEURO] = getactivedata
%Syntax:
%        [BHV NEURO] = getactivedata;
%
% Retrieves the BHV file header and NEX file header for the
% currently-active data files, as set by the function "opendatafile."
%
% Created by WA, June, 2008

BHV = [];
NEURO = [];

D = get(0, 'userdata');
if isempty(D) || ~isfield(D, 'BHV'),
    disp('No data files are currently active.  Call "opendatafile"  or go to MonkeyWrench >> Load Data to set.');
    return
end

BHV = D.BHV;
NEURO = D.NEURO;

