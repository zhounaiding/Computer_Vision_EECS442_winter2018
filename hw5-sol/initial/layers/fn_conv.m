% ----------------------------------------------------------------------
% input: in_height x in_width x num_channels x batch_size
% output: out_height x out_width x num_filters x batch_size
% hyper parameters: (stride, padding for further work)
% params.W: filter_height x filter_width x filter_depth x num_filters
% params.b: num_filters x 1
% dv_output: same as output
% dv_input: same as input
% grad.W: same as params.W
% grad.b: same as params.b
% ----------------------------------------------------------------------

function [output, dv_input, grad] = fn_conv(input, params, hyper_params, backprop, dv_output)

[~,~,num_channels,batch_size] = size(input);
[~,~,filter_depth,num_filters] = size(params.W);
assert(filter_depth == num_channels, 'Filter depth does not match number of input channels');

out_height = size(input,1) - size(params.W,1) + 1;
out_width = size(input,2) - size(params.W,2) + 1;
output = zeros(out_height, out_width, num_filters, batch_size);
% TODO: FORWARD CODE

for filterNum = 1:num_filters
    for channelNum = 1 : num_channels
        output(:, :, filterNum, :) = output(:, :, filterNum, :) + ... 
            convn(input(:, :, channelNum, :), params.W(:, :, channelNum, filterNum), 'valid');
    end
    output(:, :, filterNum, :) = output(:, :, filterNum, :) + params.b(filterNum);
end

dv_input = [];
grad = struct('W',[],'b',[]);

if backprop
	dv_input = zeros(size(input));
	grad.W = zeros(size(params.W));
	grad.b = zeros(size(params.b));
	% TODO: BACKPROP CODE

    for channelNum = 1:num_channels
        for filterNum = 1:num_filters
            dv_input(:, :, channelNum, :) = dv_input(:, :, channelNum, :) + ... 
                convn(dv_output(:, :, filterNum, :), rot90(rot90(params.W(:, :, channelNum, filterNum))), 'full');
        end
    end

    for channelNum = 1:num_filters
        for batchNum = 1:batch_size
            grad.W(:, :, :, channelNum) = grad.W(:, :, :, channelNum) + ... 
                convn(rot90(rot90(input(:, :, :, batchNum))), dv_output(:, :, channelNum, batchNum), 'valid');
        end
    end
    
    grad.b = reshape(sum(sum(sum(dv_output, 4), 1), 2), [num_filters 1]);

    grad.W = grad.W ./ batch_size;
    grad.b = grad.b ./ batch_size;
    
end
