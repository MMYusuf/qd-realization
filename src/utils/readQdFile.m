function out = readQdFile(path,sortBy)
%READQDFILE Function that extracts the QD file from the 
% output file, as described by the documentation).
%
% INPUTS:
% - path: file path. This could be either and absolute path, or a relative
% path, starting at least from the Output/ folder.
% - sortBy: Optional. If required, ray characteristics are first imported
% into a table, sorted by 'sortBy', then translated into structs. If
% sorting is not required, either omit or use []. The variable sortBy can
% be and empty set (to disable ordering), or anything the 'sortrows'
% function accepts as 'vars' in the case 'tblB = sortrows(tblA,vars)'.
% Valid columns are the ones described in 'out', except for 'numRays'.
%
% OUTPUTS:
% - out: struct. Each index corresponds to a timeframe. Each timeframe
% contains:
%    - numRays: number of rays between TX and RX. The following vectors
%    will have size [1, numRays]
%    - delay: absolute delay of each ray [s]
%    - pathGain: path gain of each ray [dB]
%    - phaseOffset: phase offset of each ray [rad]
%    - aodEl: elevation of the angle of departure of each ray [deg]
%    - aodAz: azimuth of the angle of departure of each ray [deg]
%    - aoaEl: elevation of the angle of arrival of each ray [deg]
%    - aoaAz: azimuth of the angle of arrival of each ray [deg]
%
% SEE ALSO: ISQDFILE
%
% TODO license

if ~exist('sortBy','var')
    sortBy = [];
end

fid = fopen(path,'r');
assert(fid ~= -1,...
    'File path ''%s'' not valid', path)

i = 1;
out = initOut();
while ~feof(fid)
    % From documentation:
    % (a) number of rays occupies the first row
    line = fgetl(fid);
    numRays = sscanf(line,'%d');
    
    if numRays == 0
        % skip
        continue
    end
    
    out(i) = importRays(fid,numRays,sortBy);
    out(i).numRays = numRays;
    
    i = i+1;
end

fclose(fid);

end

%% Utils
function out = initOut()
out.delay=[];
out.pathGain=[];
out.phaseOffset=[];
out.aodEl=[];
out.aodAz=[];
out.aoaEl=[];
out.aoaAz=[];
out.numRays=[];
end

function out = importRays(fid,numRays,sortBy)
if isempty(sortBy)
    out = importRaysUnordered(fid,numRays);
else
    out = importRaysOrdered(fid,numRays,sortBy);
end

end

function out = importRaysUnordered(fid,numRays)
% (b) Delay of each ray is stored in the second row
out.delay = getNextRowFloats(fid, numRays);

% (c) pathGain of each ray is stored in third row
out.pathGain = getNextRowFloats(fid, numRays);

% (d) phase offset of each ray is stored in fourth row
out.phaseOffset = getNextRowFloats(fid, numRays);

% (e) Angle of Departure, Elevation of each ray is stored in fifth row
out.aodEl = getNextRowFloats(fid, numRays);

% (f) Angle of Departure, Azimuth of each ray is stored in sixth row
out.aodAz = getNextRowFloats(fid, numRays);

% (g) Angle of Arrival, Elevation of each ray is stored in seventh row
out.aoaEl = getNextRowFloats(fid, numRays);

% (h) Angle of Arrival, Azimuth of each ray is stored in eighth row
out.aoaAz = getNextRowFloats(fid, numRays);

% placeholder
out.numRays = [];
end

function out = importRaysOrdered(fid,numRays,sortBy)
% Import data in table
tab = table();
tab.delay = getNextRowFloats(fid, numRays).';
tab.pathGain = getNextRowFloats(fid, numRays).';
tab.phaseOffset = getNextRowFloats(fid, numRays).';
tab.aodEl = getNextRowFloats(fid, numRays).';
tab.aodAz = getNextRowFloats(fid, numRays).';
tab.aoaEl = getNextRowFloats(fid, numRays).';
tab.aoaAz = getNextRowFloats(fid, numRays).';

tab = sortrows(tab,sortBy);

% export to struct
varNames = tab.Properties.VariableNames;
for i = 1:length(varNames)
    out.(varNames{i}) = tab.(varNames{i}).';
end

% placeholder
out.numRays = [];

end

function out = getNextRowFloats(fid,numRays)
line = fgetl(fid);
out = sscanf(line,'%g,',[1,numRays]);
end