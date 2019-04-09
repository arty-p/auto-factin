% compare head and neck length
allclear
load spines_headnecklen.mat;
headlen = 20*headlen; % Multiplying by the pixel-to-nm conversion factor of 20
necklen = 20*necklen;

figure,
subplot(121), bar(nanmean([necklen,headlen])); axis square;
hold on; errorbar(nanmean([necklen,headlen]),nanstd([necklen,headlen]),'.k');
ylabel('F-actin length(nm)'); set(gca,'XTickLabel',{'Neck','Head'});
subplot(122), nhist({necklen,headlen}); axis square;
xlabel('F-actin length(nm)'); 
ax = gca; ax.YAxis.Exponent = 0;
set_fig_fonts(14);