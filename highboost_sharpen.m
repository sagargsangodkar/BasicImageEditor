function output = highboost_sharpen(input,sharpness)
input = double(input);
sigma = 2;
blurred = double(gaussianblur(input,sigma));
sharpness_mask = input - blurred;

output = input + sharpness * sharpness_mask;
output = uint8(output);

end
