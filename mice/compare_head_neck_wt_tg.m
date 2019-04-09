% use the learned classifier on WT and TG data
allclear;
wt = load('WT_spine_headnecklen');
tg = load('TG_spine_headnecklen');

wt.headlen = 20*wt.headlen; wt.necklen = 20*wt.necklen;
tg.headlen = 20*tg.headlen; tg.necklen = 20*tg.necklen;

figure, 
subplot(131), statcomparemean(wt.necklen,tg.necklen); title('Neck'); axis square;
subplot(132), statcomparemean(wt.headlen,tg.headlen); title('Head'); axis square;
subplot(133), statcomparemean(sum([wt.necklen wt.headlen],2),sum([tg.necklen tg.headlen],2)); title('combined'); axis square;
set_fig_fonts(14);

%%
figure,
subplot(131), nhist({sum([wt.necklen wt.headlen],2),sum([tg.necklen tg.headlen],2)}); 
axis square; axis([0 14000 0 0.001]); xlabel('length (nm)'); title('combined');
subplot(132), nhist({wt.headlen,tg.headlen}); 
axis square; axis([0 14000 0 0.001]); xlabel('length (nm)'); title('head');
subplot(133), nhist({wt.necklen,tg.necklen},'binfactor',0.5); 
axis square; axis([0 4000 0 0.0025]); xlabel('length (nm)'); title('neck');
legend('WT','APP/PS1');
set_fig_fonts(14);

%% 
load obs_pred_label_wt_tg;
wtm = length(find(takelabelwt==0)); tgm = length(find(takelabeltg==0));
wts = length(find(takelabelwt==1)); tgs = length(find(takelabeltg==1));
wtt = length(find(takelabelwt==2)); tgt = length(find(takelabeltg==2));
figure,
bar([wtm wts wtt;tgm tgs tgt]); axis square; ylim([0 90]);
legend('Mushroom','Stubby','Thin');
set(gca,'XTickLabel',{'WT','APP/PS1'});
ylabel('Number of spines'); set_fig_fonts(14); 
colormap(cool);