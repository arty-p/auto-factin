% get cumulative f-actin length for stubby and thin spines
allclear
% load obs_pred_label_wt_tg;
% 
% fname = '.\spines\WT\';
% 
% ff = dir([fname '*.tif']);
% for i = 1:length(ff)
%     allfiles{i,1} = ff(i).name;
% end
% allfiles = sort_nat(allfiles);
% 
% load wt_tg_spinelabel.mat;
% wtix = qtake(qtake<125);
% tgix = qtake(qtake>=125)-124;
% 
% % label = takelabel(1:length(wtix)); % label = predlabelwt;
% % label = takelabel(length(wtix)+1:end); 
% label = takelabelwt;
% 
% allfiles = allfiles(wtix);
% ix = find(label==2); % 0 - mushroom, 1 - stubby, 2 - thin
% allfiles = allfiles(ix);
% nfiles = length(allfiles);
% 
% plotfigure = 0;
% 
% mask_chid = 1;
% factin_chid = 3;
% for fid = 1:nfiles
%     imgpath = [fname allfiles{fid}];
%     blob = im2bw(imread(imgpath,mask_chid));
%     factin = im2bw(imread(imgpath,factin_chid));
%     factin = factin.*blob;
%     total_factin(fid,1) = sum(factin(:));
% end
    
%% 
load wt_cumlen_stubbythin;
load tg_cumlen_stubbythin;

figure, statcomparemean(wt.stubby,tg.stubby);
figure, statcomparemean(wt.thin,tg.thin);

wt.stubby = 20*wt.stubby; tg.stubby = 20*tg.stubby;
wt.thin = 20*wt.thin; tg.thin = 20*tg.thin;

figure,
subplot(131), nhist({wt.stubby tg.stubby}); 
axis square; axis([0 10000 0 0.001]); xlabel('length (nm)'); title('Stubby');
xx = gca; xx.YAxis.Exponent = 0;
subplot(132), nhist({wt.thin,tg.thin}); 
axis square; axis([0 10000 0 0.001]); xlabel('length (nm)'); title('Thin');
legend('WT','APP/PS1');
xx = gca; xx.YAxis.Exponent = 0;
set_fig_fonts(14);


