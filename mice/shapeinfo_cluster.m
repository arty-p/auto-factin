% shape info clustering
allclear;
%% human-human consistency
% 0 - Mushroom; 1 - Stubby; 2 - Thin; 3 - Forked
d = dir('.\xls\class*.xlsx');
nspines = 248;
obslabel = NaN(nspines,length(d));
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

feat = xlsread('.\xls\shape_info_mice.xlsx'); 
feat = feat(qtake,6:end);
featnames = {'Area','Area Convex Hull','Perimeter','Perimeter Convex Hull','Feret','Min Feret',...
    'Max inscribed circle diameter','Area equivalent circle diameter','Long Side Length MBR',...
    'Short Side Length MBR','Aspect Ratio','Area/Perimeter','Circulatiy','Elongation','Convexity',...
    'Solidity','Number of Holes','Thinnes Ratio','Contour Temperature','Orientation','Fractal Dimension','Fractal Dimension Goodness'};

%% linear classifier for WT data
wtix = find(qtake<125);
tgix = find(qtake>=125);

featwt = feat(wtix,:); takelabelwt = takelabel(wtix);
ndims = 5;
[coeff,score,latent] = pca(zscore(featwt));
featwt = score(:,1:ndims);

% linear classifier
cv = cvpartition(takelabelwt,'kFold',4);
cost = 1-eye(3);
obj = fitcecoc(featwt,takelabelwt,'CVPartition',cv,'Coding','onevsall','Cost',cost,'Prior', 'Empirical');
predlabelwt = kfoldPredict(obj);
acc = sum(predlabelwt==takelabelwt)./length(takelabelwt);

%%
ix = find(takelabelwt==0); fprintf('acc (M): %f (%d examples)\n',sum(predlabelwt(ix)==takelabelwt(ix))./length(ix),length(ix));
ix = find(takelabelwt==1); fprintf('acc (S): %f (%d examples)\n',sum(predlabelwt(ix)==takelabelwt(ix))./length(ix),length(ix));
ix = find(takelabelwt==2); fprintf('acc (T): %f (%d examples)\n',sum(predlabelwt(ix)==takelabelwt(ix))./length(ix),length(ix));

%% classifying TG data
% get a single WT classifier
classifierobj = fitcecoc(featwt,takelabelwt,'Coding','onevsall','Cost',cost,'Prior','Uniform');

feattg = feat(tgix,:); takelabeltg = takelabel(tgix);
feattg = zscore(feattg);
feattg = feattg*coeff;
feattg = feattg(:,1:ndims);
predlabeltg = predict(classifierobj,feattg);
acctg = sum(predlabeltg==takelabeltg)./length(takelabeltg);

%%
ix = find(takelabeltg==0); fprintf('acc (M): %f (%d examples)\n',sum(predlabeltg(ix)==takelabeltg(ix))./length(ix),length(ix));
ix = find(takelabeltg==1); fprintf('acc (S): %f (%d examples)\n',sum(predlabeltg(ix)==takelabeltg(ix))./length(ix),length(ix));
ix = find(takelabeltg==2); fprintf('acc (T): %f (%d examples)\n',sum(predlabeltg(ix)==takelabeltg(ix))./length(ix),length(ix));

%%
figure,
ix = find(takelabelwt==0); plot(featwt(ix,1),featwt(ix,2),'ro'); hold on;
ix = find(takelabelwt==1); plot(featwt(ix,1),featwt(ix,2),'b+');
ix = find(takelabelwt==2); plot(featwt(ix,1),featwt(ix,2),'gs');
axis square; xlabel('PC1'); ylabel('PC2'); legend('Mushroom','Stubby','Thin');
title('WT');

%%
figure,
ix = find(takelabelwt==0); plot(featwt(ix,1),featwt(ix,2),'ro'); hold on;
ix = find(takelabelwt==1); plot(featwt(ix,1),featwt(ix,2),'b+');
ix = find(takelabelwt==2); plot(featwt(ix,1),featwt(ix,2),'gs');
ix = find(predlabeltg==0); plot(feattg(ix,1),feattg(ix,2),'mo'); 
ix = find(predlabeltg==1); plot(feattg(ix,1),feattg(ix,2),'c+');
ix = find(predlabelwt==2); plot(featwt(ix,1),featwt(ix,2),'ys');
axis square; xlabel('PC1'); ylabel('PC2'); legend('WT-Mushroom','WT-Stubby','WT-Thin','APP/PS1-Mushroom','APP/PS1-Stubby','APP/PS1-Thin');

return;
%% Combined classifier
takelabel = [takelabelwt;takelabeltg];
cv = cvpartition(takelabel,'kFold',2);
objc = fitcecoc([featwt;feattg],takelabel,'CVPartition',cv,'Coding','onevsall','Cost',cost,'Prior', 'Empirical');
predlabel = kfoldPredict(objc);
accc = sum(predlabel==takelabel)./length(takelabel);
