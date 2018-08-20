function [output,T] = hist_equalise(input)
im = input;
T = zeros(1,256);
p = size(im,1);
q = size(im,2);
pixels = size(im,1)*size(im,2);
im = double(im);
input_distribution = zeros(1,256);
for k = 1:256
    for i = 1:p
        for j = 1:q
            if(im(i,j)==k-1)
                input_distribution(k) = input_distribution(k) + 1;
            end
        end
    end
end

cdf = zeros(1,256);
for k = 1:256
    for dummy = 1:k
        cdf(k) = cdf(k) + input_distribution(dummy);
    end
end

for i = 1:p
    for j = 1:q
        output(i,j) = 255 * cdf(im(i,j)+1) / pixels;
    end
end
output = uint8(output);

for r = 1:256
    T(r) = 255 * cdf(r) / pixels;
end


