function D = matchancillarydata(adata, filename, sig)
%
% Created by WA  6/7/2011

indxfile = strcmpi(adata.FileName, filename);
if strcmpi(filename, sig), %passing files instead of neuron or LFP IDs
    indxsig = indxfile;
else
    indxsig = strcmpi(adata.Signal, sig);
end
indx = (indxfile & indxsig);

adata = rmfield(adata, {'FileName', 'Signal'});
fn = fieldnames(adata);
for i = 1:length(fn),
    D.(fn{i}) = adata.(fn{i})(indx);
end
