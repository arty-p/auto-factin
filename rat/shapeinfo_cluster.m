% shape info clustering
allclear;
%% human-human consistency
% 0 - Mushroom; 1 - Stubby; 2 - Thin; 3 - Forked
d = dir('.\xls\class*.xlsx');
obslabel = NaN(1056,length(d));
for did = 1:length(d)
    [~,xx] = xlsread(['.\xls\' d(did).name]);
    for xid = 1:size(obslabel,1)
        switch xx{xid}
            case {'M','m'}; 
                obslabel(xid,did) = 0;
            case {'S','s'}
                obslabel(xid,did) = 1;
            case {'T','t'}
                obslabel(xid,did) = 2;
            case {'F','f'}
                obslabel(xid,did) = 3;
        end
    end
end

qtake = [];
takelabel = [];
for i = 1:size(obslabel,1)
    hc = histcounts(obslabel(i,:),0:4);
    q = find(hc>=3);
    if ~isempty(q)
        qtake = [qtake;i];
        takelabel = [takelabel; q-1];
    end
end

% remove forked spines as they are very few in number
qf = find(takelabel == 3);
takelabel(qf) = [];
qtake(qf) = [];

obslabel = obslabel(qtake,:);
for sid1 = 1:size(obslabel,2)
    for sid2 = 1:size(obslabel,2)
        ch(sid1,sid2) = sum(obslabel(:,sid1)==obslabel(:,sid2))/size(obslabel,1);
    end
end
figure, imagesc(ch); axis square; colorbar;

% return; 

feat = xlsread('.\xls\shape_info.xlsx'); 
feat = feat(qtake,7:end);
featnames = {'Area','Area Convex Hull','Perimeter','Perimeter Convex Hull','Feret','Min Feret',...
    'Max inscribed circle diameter','Area equivalent circle diameter','Long Side Length MBR',...
    'Short Side Length MBR','Aspect Ratio','Area/Perimeter','Circulatiy','Elongation','Convexity',...
    'Solidity','Number of Holes','Thinnes Ratio','Contour Temperature','Orientation','Fractal Dimension','Fractal Dimension Goodness'};

ndims = 5;
[coeff,score,latent] = pca(zscore(feat));
feat = score(:,1:ndims);

% linear classifier
cv = cvpartition(takelabel,'kFold',4);
cost = 1 - eye(3);
obj = fitcecoc(feat,takelabel,'CVPartition',cv,'Coding','onevsall');
predlabel = kfoldPredict(obj);
acc = sum(predlabel==takelabel)./length(takelabel);

%%
ix = find(takelabel==0); fprintf('acc (M): %f (%d examples)\n',sum(predlabel(ix)==takelabel(ix))./length(ix),length(ix));
ix = find(takelabel==1); fprintf('acc (S): %f (%d examples)\n',sum(predlabel(ix)==takelabel(ix))./length(ix),length(ix));
ix = find(takelabel==2); fprintf('acc (T): %f (%d examples)\n',sum(predlabel(ix)==takelabel(ix))./length(ix),length(ix));

%%
figure,
ix = find(takelabel==0); plot(feat(ix,1),feat(ix,2),'ro'); hold on;
ix = find(takelabel==1); plot(feat(ix,1),feat(ix,2),'b+');
ix = find(takelabel==2); plot(feat(ix,1),feat(ix,2),'gs');
axis square; xlabel('PC1'); ylabel('PC2'); legend('Mushroom','Stubby','Thin');
title('WT');

