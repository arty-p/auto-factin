%% test for the spine head/neck lengths
allclear;
% fname = '.\spines\WT\';
fname = '.\spines\TG\';

ff = dir([fname '*.tif']);
for i = 1:length(ff)
    allfiles{i,1} = ff(i).name;
end
allfiles = sort_nat(allfiles);

load wt_tg_spinelabel.mat;
wtix = qtake(qtake<125);
tgix = qtake(qtake>=125)-124;

% label = takelabel(1:length(wtix)); % label = predlabelwt;
% label = takelabel(length(wtix)+1:end); 
label = predlabeltg;

allfiles = allfiles(tgix);
ix = find(label==0);
allfiles = allfiles(ix);
nfiles = length(allfiles);

plotfigure = 0;

mask_chid = 1;
homer_chid = 2;
factin_chid = 3;
for fid = 1:nfiles
    close all;
    clearvars -except plotfigure fname allfiles nfiles fid necklen headlen mask_chid homer_chid factin_chid spinelongdim;
    imgpath = [fname allfiles{fid}];
    tocomplement = 0;
    
    %% get the blob
    blob = im2bw(imread(imgpath,mask_chid));
    if tocomplement, blob = imcomplement(blob); end;
    
    img = imfill(blob,'holes');
    
    % find the bounding box dimensions
    bbimg = removezeros(img);    
    
    img = bwmorph(img,'skel',Inf);
    B = bwmorph(img, 'branchpoints');
    E = bwmorph(img, 'endpoints');
    [ye,xe] = find(E);
    B_loc = find(B);
    Dmask = false(size(img));
    for k = 1:numel(xe)
        D = bwdistgeodesic(img,xe(k),ye(k));
        distanceToBranchPt = min(D(B_loc));
        if distanceToBranchPt == 0,
            Dmask(D == distanceToBranchPt) = true;
        elseif distanceToBranchPt < 9
            Dmask(D < distanceToBranchPt) = true;
        end
    end
    imgD = img - Dmask;
    imgD = bwmorph(imgD,'clean');
    imgD = bwmorph(imgD,'spur');
    
    if plotfigure
        figure, subplot(121), imshow(img);
        subplot(122), imshow(imgD); hold all;
        % [y,x] = find(B); plot(x,y,'ro');
    end
    
    %% find the branchpoints & lengths of branches
    im = bwmorph(imgD,'skel');
    
    B = bwmorph(im, 'branchpoints');
    E = bwmorph(im, 'endpoints');
    [yb,xb] = find(B);
    [ye,xe] = find(E);
    
    if plotfigure
        figure, imshow(im), hold on, plot(xb,yb,'ro'); plot(xe,ye,'go');
    end
    
    % find distances between all endpoints to the branchpoints
    if ~isempty(xb)
        for k = 1:numel(xe)
            D = bwdistgeodesic(im,xe(k),ye(k));
            disttobranch(k,1) = min(D(find(B)));
        end
    else
        D = bwdistgeodesic(im,xe(1),ye(1));
        disttobranch = nanmax(D(:));
    end
    
    ix = find(disttobranch==Inf|isnan(disttobranch));
    xe(ix) = []; ye(ix) = [];
    disttobranch(ix) = [];
    
    %% figure out which is the neck by computing distance from the HOMER puncta
    homer = im2bw(imread(imgpath,homer_chid));
    if tocomplement, homer = imcomplement(homer); end
    
    % find the centroid of the homer puncta
    homerpt = regionprops(homer,'centroid');
    homerpt = homerpt.Centroid;
    xh = round(homerpt(1));  yh = round(homerpt(2));
    
    % find distance between endpoints and homer
    if ~isempty(disttobranch)
        spinelongdim(fid,1) = max(size(bbimg));
        if ~isempty(xb)
            disttohomer = sqrt(abs(xe-xh).^2 + abs(ye-yh).^2);
            [~, neckid] = nanmax(disttohomer);
            headid = setdiff(1:length(disttohomer),neckid);
            
            if plotfigure
                figure, imshow(im), hold on, plot(xe(neckid),ye(neckid),'yo'); plot(xe(headid),ye(headid),'co');
            end
            
            necklen(fid,1) = disttobranch(neckid);
        else
            neckid = 1;
            headid = [];
            
            necklen(fid,1) = disttobranch(neckid);
        end
    else
        spinelongdim(fid,1) = NaN;
        necklen(fid,1) = NaN;
        headlen(fid,1) = NaN;
    end
    
    factin = im2bw(imread(imgpath,factin_chid));
    factin = factin.*blob;
    total_factin = sum(factin(:));
    headlen(fid,1) = total_factin-necklen(fid,1);
end
