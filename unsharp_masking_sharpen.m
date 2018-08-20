function output = unsharp_masking_sharpen(input,sharpness)
input = double(input);
blurred = double(gaussianblur(input,sharpness));
sharpness_mask = input - blurred;

output = input + sharpness_mask;
output = uint8(output);

end
