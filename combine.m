function n = combine(varargin)
% combines struct field values into single struct

for i = 1:length(varargin)
    fields{i} = fieldnames(varargin{i});
end

n = varargin{1};

i = 1;
while i < size(fields, 2)
    for j = 1:length(fields{i})
        field = fields{i};
        n.(field{j}) = cat(1, n.(field{j}), varargin{i+1}.(field{j}));
    end
    i = i + 1;
end

end