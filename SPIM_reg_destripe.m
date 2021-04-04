function [xabs, yabs, xrel, yrel, err] = SPIM_reg_destripe( doreg, dodestripe, filename, upscl, maxoffsetx, maxoffsety, maxiter, psi )
% SPIM_reg_destripe
% subpixel translation offsets through stack
% (Small amounts of translation in sample caused by gel movement)
% &
% destriping using VSNR
% (shadows seen in single sided SPIM)

% doreg and dodestripe -> logical flags to perform reg and destripe
% filename ->  full path and filename
% upscl -> upscale amount for offset resolution, 1/upscl
% maxoffsetx, maxoffsety
% maxiter -> max iterations of destripe
% psi -> gabor function image for destriping

err = 0;

%% Open tif, get details, setup outputs
tif_info = imfinfo(filename);
width = tif_info(1).Width;
height = tif_info(1).Height;
zn = size(tif_info,1);

xabs = zeros(zn-1,1,'single');  %  here abs means absolute from zero
yabs = zeros(zn-1,1,'single');  %  and relative means relative to previous
xrel = zeros(zn-1,1,'single');
yrel = zeros(zn-1,1,'single');


%%  setup output tif file
[pathstr, name, ext] = fileparts(filename);
outfilename = strrep(filename,ext,'');
if (doreg & dodestripe)  %  if both
    outfilename = strcat(outfilename,'_regds',ext);
elseif (doreg)  %  just reg
    outfilename = strcat(outfilename,'_reg',ext);
elseif (dodestripe)  %  or just destripe
    outfilename = strcat(outfilename,'_ds',ext);
else
    err = 1;
    return
end

outtif = Tiff(outfilename,'w');

tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.ImageLength = height;
tagstruct.ImageWidth = width;
tagstruct.RowsPerStrip = height;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.SamplesPerPixel = 1;
tagstruct.Compression = Tiff.Compression.None;
tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
tagstruct.BitsPerSample = 16;
tagstruct.ResolutionUnit = Tiff.ResolutionUnit.Centimeter;
tagstruct.XResolution = 15625;
tagstruct.YResolution = 15625;


%%  using z1 create variables/matricies for interpolate functions
img1 = imread(filename,1);
[M N] = size(img1);
[xx yy] = meshgrid(1:N,1:M);


%%  write z1 to output file; this is our reference point
outtif.setTag(tagstruct);
if (dodestripe)
    img1 = VSNR_Destripe(single(img1), psi, maxiter);
end
outtif.write(uint16(img1));
outtif.writeDirectory();


%%  setup circular matrix for loop
zThree = zeros(M,N,3,'single');
zThree(:,:,1) = img1;
str = sprintf([name '  z %d'],1);
disp(str);
if (dodestripe)
    imgt2 = imread(filename,2);
    imgt3 = imread(filename,3);
    img2 = VSNR_Destripe(single(imgt2), psi, maxiter);
    img3 = VSNR_Destripe(single(imgt3), psi, maxiter);
    zThree(:,:,2) = img2;
    zThree(:,:,3) = img3;
else
    zThree(:,:,2) = imread(filename,2);
    zThree(:,:,3) = imread(filename,3);
end

%%  phase correlate (pc) the first pair prior to loop
if (doreg)
    try
        pc_out = dftregistration(fft2(zThree(:,:,1)),fft2(zThree(:,:,2)),upscl);
    catch me
        %# report error
        estr = sprintf([str 'dftreg error'],me.message);
        disp(estr);
    end
    
    % dftregistration(referenceImage, imageToRegister, scalingFactor);
    xrel(1) = pc_out(4);
    if (abs(xrel(1)) > maxoffsetx)  % only consider small offsets  -  use maxoffset value in pixels
        xrel(1) = 0;  %  if it's too big we assume it must be wrong, so we don't change  
    end
    yrel(1) = pc_out(3);
    if (abs(yrel(1)) > maxoffsety)  % repeat for y axis offsets  -  note independent axes
        yrel(1) = 0;  
    end

    xabs(1) = xrel(1);
    yabs(1) = yrel(1);
end
% TODO - check if interp2 needed here...  shift 2 to 1 before moving on to
% compare to 3...?


%%  run loop for all z 
for zi = 2:(zn-1)
    str = sprintf([name '  z %d'],zi);
    disp(str);
    % Manuel Guizar - Dec 13, 2007   -  select dftregistration, right click
    % and view for further details
    if (doreg)
        try
            pc_out = dftregistration(fft2(zThree(:,:,2)),fft2(zThree(:,:,3)),upscl); % pc:n_n+1
        catch me
            %# report error
            estr = sprintf([str 'dftreg error'],me.message);
            disp(estr);
        end
        
        % add results to relative and absolute outputs
        xrel(zi) = pc_out(4);
        yrel(zi) = pc_out(3);
        if (abs(xrel(zi)) > maxoffsetx); xrel(zi) = 0; end
        if (abs(yrel(zi)) > maxoffsety); yrel(zi) = 0; end

        xabs(zi) = xabs(zi-1) + xrel(zi);
        yabs(zi) = yabs(zi-1) + yrel(zi);
        % shift with subpixel interpolation
        xs = xx - xabs(zi-1);
        ys = yy - yabs(zi-1);
        imgshft = interp2(xx,yy,zThree(:,:,2),xs,ys);
        
        % save to tif
        outtif.setTag(tagstruct);
        outtif.write(uint16(imgshft));
    else
        outtif.setTag(tagstruct);
        outtif.write(uint16(zThree(:,:,2)));
    end
    % circshift -1 in z
    zThree = circshift(zThree,-1,3);
    % check bounds % add n+1 to z3(:,:,3)
    if zi<(zn-1)
        if (dodestripe)
            imgt3 = imread(filename,zi+2);
            img3 = VSNR_Destripe(single(imgt3), psi, maxiter);
            zThree(:,:,3) = img3;
        else
            zThree(:,:,3) = imread(filename,zi+2);
        end
        outtif.writeDirectory();
    end
    
end
outtif.close();


end

