%
%findPath
%
function res = findPath(subpath)

%subpath     = 'Visual Studio';
pathe       = getenv('path');
pathcells   = strsplit(pathe,';');

for i=1:length(pathcells)
    tmp = findstr(pathcells{i},subpath);
    
    if length(tmp)>0
        res= pathcells{i};
        return
    end
end
