function result = consecutive(vector, element, howmany)
% SYNTAX:
% result = consecutive(vector, element, #occ)
%
% This function returns the index of the first portion of the input
% vector which has #occ consecutive occurences of element.  If there
% is no such segment, zero is returned.
%
% created Fall, 1997  --WA

lv = length(vector);
pvector = zeros(lv+2, 1);
pvector(lv + 2) = element + 1;
pvector(2:lv+1) = vector;
pvector(1) = element + 1;
f = find(pvector ~= element);
fdiff = diff(f);
candidates = find(fdiff > howmany);
if isempty(candidates),
   result = 0;
   return
end
result = sum(fdiff(1:min(candidates)-1)) + 1;