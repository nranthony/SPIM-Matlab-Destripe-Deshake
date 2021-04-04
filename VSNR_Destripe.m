function [ u ] = VSNR_Destripe( u0, psi, maxiter )
%VSNR_DESTRIPE Use VSNR with Gabor filter to destripe input image
%   u0: input image
%   psi: gabor filter image
%   |using log by default to start with| use_log: boolean option for log transform on data prior to destriping

%% take log of images to reduce noise
u0=log(u0+100);

%% Denoising and display
%Sets algorithms parameters
p=2; %(indexes of p-norms)
alpha=0.5; %data terms.
epsilon = 0; %no regularization of TV-norm
prec= 1e-16; %stopping criterion (initial dual gap multiplied by prec)
C = 1; %ball-diameter to define a restricted duality gap. 
%maxit=50; %Maximal number of iterations

% VSNR by P Weiss
%tic;
[u,Gap,Primal,Dual,EstP,EstD]=VSNR(u0,epsilon,p,psi,alpha,maxiter+1,prec,C);
%toc;
u=exp(u)-100;

end

