function files = bhvlist
%SYNTAX:
%        files = bhvlist;
%
%Gets the list of all bhv files in the current ML experiment directory.
%Useful as an argument to the batch function.
%
%Created 5/27/11 -WA

MLdir = getpref('MonkeyLogic', 'Directories');
DIR = dir([MLdir.ExperimentDirectory '*.bhv']);
files = cellstr(strvcat(DIR.name));
