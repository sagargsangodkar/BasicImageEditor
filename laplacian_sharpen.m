function output = laplacian_sharpen(input)
input = double(input);
kernel = [-1 -1 -1; -1 8 -1; -1 -1 -1];

output = zeros(size(input));
gradient2 = zeros(size(input)); % 2nd order gradient
input_padded = padarray(input,[1 1]);

for i = 1:size(input,1)
    for j = 1:size(input,2)
        temp = double(input_padded(i:i+2,j:j+2));
        temp = sum(temp.*kernel);
        gradient2(i,j) = sum(temp(:));
    end
end
output = input + gradient2;
output = uint8(output);

end
