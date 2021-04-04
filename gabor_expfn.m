function gb=gabor_expfn(sigmax,sigmay)
% simplified version of gabor_fn by P Weiss
% removed periodic parameters and inverse sigma values
% kept bounding box using cos(theta) = 0 and sin(theta) = 1
% and rotation removed, x_theta -> y, and y_theta -> x

% Bounding box
nstds = 5;
xmax = min(max(abs(0),abs(nstds*sigmay)),2000);
xmax = ceil(max(1,xmax));
ymax = min(max(abs(nstds*sigmax),abs(0)),2000);
ymax = ceil(max(1,ymax));
xmin = -xmax; ymin = -ymax;
[x,y] = meshgrid(xmin:xmax,ymin:ymax);

% Simplified Gabor function
gb= 1/(2*pi*sigmax *sigmay) * exp(-.5*(y.^2/sigmax^2+x.^2/sigmay^2));