function n = timeSplice(varargin)
% combines struct field values into single struct

len = [];
for i = 1:length(varargin)
    len(i) = length(varargin{i}.ET);
end

n = varargin{1};
pos = len(2) + 1;

i = 2;
while i < length(len)
    n.ET(pos:end) = n.ET(pos:end) + varargin{i+1}.ET(2) + varargin{i}.ET(end);
    pos = pos + len(i+1);
    i = i + 1;
end

end