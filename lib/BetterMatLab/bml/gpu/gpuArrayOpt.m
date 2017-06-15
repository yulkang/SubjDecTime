function in = gpuArrayOpt(in)
% Set global GL_USE_GPUARRAY = false to skip
%
% in = gpuArrayOpt(in)
global GL_USE_GPUARRAY

if isempty(GL_USE_GPUARRAY) || GL_USE_GPUARRAY
    in = gpuArray(in);
end