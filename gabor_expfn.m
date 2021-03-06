function gb=gabor_expfn(sigma_x, sigma_y, theta)
% editted version of gabor_fn by P Weiss
% enter sigmas directly
% input theta in degrees and conver to radians for matlab trig

% convert to radians
theta = deg2rad(theta+90);

% just input sigmas
% sigma_x = sigma/gammax;
% sigma_y = sigma/gammay;

% Bounding box
nstds = 5;
xmax = min(max(abs(nstds*sigma_x*cos(theta)),abs(nstds*sigma_y*sin(theta))),2000);
xmax = ceil(max(1,xmax));
ymax = min(max(abs(nstds*sigma_x*sin(theta)),abs(nstds*sigma_y*cos(theta))),2000);
ymax = ceil(max(1,ymax));
xmin = -xmax; ymin = -ymax;
[x,y] = meshgrid(xmin:xmax,ymin:ymax);
 
n=max(xmax,ymax);

% Rotation 
x_theta=x*cos(theta)+y*sin(theta);
y_theta=-x*sin(theta)+y*cos(theta);
 
gb= 1/(2*pi*sigma_x *sigma_y) * exp(-.5*(x_theta.^2/sigma_x^2+y_theta.^2/sigma_y^2)).*cos(2*pi/n*x_theta);