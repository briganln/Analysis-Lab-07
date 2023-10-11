fname = 'regatlases/testslice001.nii.gz';
Vtest = spm_vol(fname);
[Ytest,XYZ] = spm_read_vols(Vtest);

fname = 'atlases/atlas0012.nii.gz';
Vatlas = spm_vol(fname);
[Yatlas,XYZ] = spm_read_vols(Vatlas);

fname = 'atlases/atlas0012-seg.nii.gz';
Vseg = spm_vol(fname);
[Yseg,XYZ] = spm_read_vols(Vseg);

c = normxcorr2(Ytest,Yatlas);
surf(c)
shading flat

title('normxcorr2 for test image vs atlas')
xlabel('y shift (pixels)')
ylabel('x shift (pixels)')
zlabel('Correlation')


[ypeak,xpeak] = find(c==max(c(:)));

yoffSet = ypeak-size(Ytest,1);
xoffSet = xpeak-size(Ytest,2);


% (2.1) What is the correlation value at each point telling you? Why is
% this helpful for image registration? Record the correlation value at the
% peak point.
%The correlation value indicates the accuracy of the image registration to
%the original image, meaning how well the two match

% (2.2) Often there are multiple peaks in the correlation surface (a.k.a.
% local maxima in the parameter space). What are the implications of this?
% Multiple peaks within a correlation surface indicate some area that are
% more well aligned (matching) between the registration and original image
% when compared with other areas of the image

ymatch = yoffSet + (1:size(Ytest,1));
xmatch = xoffSet + (1:size(Ytest,2));

Ytest_regtoatlas = zeros(size(Yatlas));
Ytest_regtoatlas(ymatch,xmatch) = Ytest;
Yatlas_regtotest = Yatlas(ymatch,xmatch);
Yseg_regtotest = Yseg(ymatch,xmatch);

% (2.3) Fill out an inventory of what you have now:
%
%  Variable          Size      What is it?
%  ----------        --------  ----------------------------------------
%  Ytest             24x16       Original test image
%  Yatlas            40x50       Atlas - labeled reference model linked to structures for segmentation
%  Ytest_regtoatlas  40x50       Test image registered to atlas
%  Yatlas_regtotest  24x16       Atlas image registered to test
%  Yseg_regtotest    40x50       Seg image registered to test
%% 

figure

h = subplot(2,2,1);
imshowpair(Yatlas,Ytest,'montage','Parent',h);
title('Original images')

h = subplot(2,2,2);
imshowpair(Yatlas,Ytest,'diff','Parent',h);
title('Original images: difference')

h = subplot(2,2,3);
imshowpair(Yatlas,Ytest_regtoatlas,'montage','Parent',h);
title('Atlas and test registered to atlas');

h = subplot(2,2,4);
imshowpair(Yatlas,Ytest_regtoatlas,'diff','Parent',h);
title('Original and test registered to atlas: difference image');
snapnow
%% 

figure

subplot(1,3,1)
imshow(Ytest)
title('Test slice')

subplot(1,3,2)
imshow(Yseg_regtotest,[])
title('Registered segmentation')

subplot(1,3,3)
imshow(labeloverlay(Ytest,Yseg_regtotest,'Transparency',0.7))
title('Both combined');
snapnow

% How good or bad is the segmentation once registered to the test image? 
% The segmentation registered to the original image appears to be accuratly
% positioned but the image quality appears to have decreased on the
% segmentation image
% What changes might improve the quality of the segmentation for this test image?
% Maintaining the original image size of 24x16 may maintain the original
% imge quality


Vout = Vtest;
Vout.pinfo(1:2) = [1 0];
Vout.dt(1) = spm_type('uint8');
Vout.fname = 'example-segmentation.nii';
spm_write_vol(Vout,Yseg_regtotest);
%% Section 4


natlases = 20;
for n = 1:natlases

    atlas_fname = sprintf('atlases/atlas%04d.nii.gz',n);
    Vatlas = spm_vol(atlas_fname);
    [Yatlas,XYZ] = spm_read_vols(Vatlas);


    seg_fname = sprintf('atlases/atlas%04d-seg.nii.gz',n);
    Vseg = spm_vol(seg_fname);
    [Yseg,XYZ] = spm_read_vols(Vseg);

    out_fname = sprintf('regatlases/regatlas%04d-seg.nii',n);



    c = normxcorr2(Ytest,Yatlas);
    [ypeak,xpeak] = find(c==max(c(:)));
    yoffSet = ypeak-size(Ytest,1);
    xoffSet = xpeak-size(Ytest,2);
    ymatch = yoffSet + (1:size(Ytest,1));
    xmatch = xoffSet + (1:size(Ytest,2));
    fprintf('%04d %0.2f\n',n,max(c(:)));



    Ytest_regtoatlas = zeros(size(Yatlas));
    Ytest_regtoatlas(ymatch,xmatch) = Ytest;
    Yatlas_regtotest = Yatlas(ymatch,xmatch);
    Yseg_regtotest = Yseg(ymatch,xmatch);

    figure

    h = subplot(2,2,1);
    imshowpair(Yatlas,Ytest,'montage','Parent',h);
    title('Original images')

    h = subplot(2,2,2);
    imshowpair(Yatlas,Ytest,'diff','Parent',h);
    title('Original images: difference')

    h = subplot(2,2,3);
    imshowpair(Yatlas,Ytest_regtoatlas,'montage','Parent',h);
    title('Atlas and test registered to atlas');

    h = subplot(2,2,4);
    imshowpair(Yatlas,Ytest_regtoatlas,'diff','Parent',h);
    title('Original and test registered to atlas: difference image')

    snapnow

    Vout = Vtest;
    Vout.pinfo(1:2) = [1 0];
    Vout.dt(1) = spm_type('uint8');
    Vout.fname = out_fname;
    spm_write_vol(Vout,Yseg_regtotest);
end 

   

    %  Atlas      Peak correlation
    %  -----      ----------------
    %   0001      0.82
    %   0002      0.78
    %   0003      0.89
    %   0004      0.60 
    %   0005      0.83 
    %   0006      0.78  
    %   0007      0.83  
    %   0008      0.88  
    %   0009      0.88 
    %   0010      0.83   
    %   0011      0.89   
    %   0012      0.86  
    %   0013      0.88   
    %   0014      0.88
    %   0015      0.83
    %   0016      0.82   
    %   0017      0.60   
    %   0018      0.86   
    %   0019      0.88    
    %   0020      0.88


% (4.2) Describe the quality of the individual registrations based on your
% visual inspection of the figures. What is working well? What kinds of
% errors are being made?
% It appears some of brain is not registering in difference image either 
% because they are not perfectly aligned or possibly the segmented image
% eliminated some of the brain

% (4.3) Send me your 20 registered atlases (regatlas????-seg.nii images) in
% a single zip file by email.
%Done