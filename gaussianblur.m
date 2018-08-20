function output = gaussianblur(input,gaussiansigma)
f = waitbar(0,'Please wait...');
kernel = zeros(5,5); % for 5x5 kernel
normalisation_constant = 1;
gaussiansigma = ceil(gaussiansigma);
masksize = ((3*gaussiansigma)*2)+1;
kernel_center_offset = (3*gaussiansigma) + 1;
padpixels = 3*gaussiansigma;

for i = 1:masksize
    for j = 1:masksize
        sumsquare = (i-kernel_center_offset)^2 + (j-kernel_center_offset)^2;
        kernel(i,j) = exp(-1*sumsquare/(2*(gaussiansigma^2))); 
        normalisation_constant = normalisation_constant + kernel(i,j);
    end
end
kernel = kernel/normalisation_constant;
output = zeros(size(input));
input_padded = padarray(input,[padpixels padpixels]);

waitbar(.5,f,'Please wait...');

for i = 1:size(input,1)
    for j = 1:size(input,2)
        temp = double(input_padded(i:i+masksize-1,j:j+masksize-1));
        temp = sum(temp.*kernel);
        output(i,j) = sum(temp(:));
    end
end
output = uint8(output);

waitbar(1,f,'Done');
close(f)

end
