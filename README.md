# SPIM-Matlab-Destripe-Deshake
Matlab app to destripe, using Pierre Weiss VSNR, and deshake, using Guizar-Sicairos, Thurman, and Fienup Efficient subpixel image registration algorithms

Data sets from fixed SPIM setups can often contain striping due to dense regions and changes in refractive index, especially in single sided illumination configurations.  This Matlab app uses Variational Stationary Noise Removal (VNSR) from Pierre Weiss, see https://github.com/pierre-weiss, to remove the striping after selecting and previewing the results on different sections of the data stack (see https://github.com/pierre-weiss/VSNR_2D-3D_GPU for Fiji plugin; uses CUDA 8)

The movement of gel samples through the sample in a stepped pattern can induce oscilations, or 'wibble', in the sample between frames, depending on the stage and acquistion parameters.  The 'deshake' option registers the stack using matlab functions from Manuel Guizar-Sicairos, Samuel T. Thurman, and James R. Fienup, "Efficient subpixel image registration algorithms," Opt. Lett. 33, 156-158 (2008).  See html folder in efficient_subpixel_registration folder.



