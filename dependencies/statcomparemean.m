% Compare mean/median of two variables as appropriate
% Required inputs
%    x             = first set of samples
%    y             = second set of samples
% Outputs:
%    pout          = p-value of test of means or medians, as appropriate
%    pxnormal      = p-value of lillietest for normality on x
%    pynormal      = p-value of lillietest for normality on y
%    xm            = mean or median of x (as applicable)
%    ym            = mean or median of y (as applicable)
%    xe            = std or inter-quartile range of x (as applicable)
%    ye            = std or inter-quartile range of y (as applicable)

% Adapted from a code written by SP Arun, IISc.

function [pout,pxnormal,pynormal,xm,ym,xe,ye] = statcomparemean(x,y)
if(length(x)==length(y)), pairedflag = 1; else pairedflag = 0; end;
pthresh = 0.05;
warning('off','stats:adtest:OutOfRangePLow');
x = x(:); y = y(:);

xname = inputname(1); yname = inputname(2);
if(isempty(xname)),xname='x';end; if(isempty(yname)),yname='y';end;

if(pairedflag==1)
    [~,pttest] = ttest(x,y); pairstr = 'paired test';
    pranksum = signrank(x,y);
else
    [~,pttest] = ttest2(x,y); pairstr = 'unpaired test';
    pranksum = ranksum(x,y);
end

[~,pxnormal] = adtest(x); [~,pynormal] = adtest(y);
isnormal = pxnormal>pthresh & pynormal>pthresh; % 1 => both are normal :)
if(isnormal)
    fprintf('adtest for normality PASSED: %s (p=%2.2g), %s (p=%2.2g) \n',xname,pxnormal,yname,pynormal);
    fprintf('Means (t-test) : %s = %2.2g (n=%d), %s = %2.2g (n=%d), p = %2.2g, %s \n',xname,nanmean(x),length(x),yname,nanmean(y),length(y),pttest,pairstr);
    xm = nanmean(x); ym = nanmean(y); xe = nanstd(x); ye = nanstd(y);
    pout = pttest;
else
    fprintf('adtest for normality FAILED: %s (p=%2.2g), %s (p=%2.2g) \n', xname,pxnormal,yname,pynormal);
    fprintf('Medians (ranksum): %s = %2.2g (n=%d), %s = %2.2g (n=%d), p = %2.2g, %s \n',xname,nanmedian(x),length(x),yname,nanmedian(y),length(y),pranksum,pairstr);
    xm = nanmedian(x); ym = nanmedian(y); xe = iqr(x); ye = iqr(y); pout = pranksum;
end

m = [xm ym]; e = [xe ye]/sqrt(length(x));
bar(m); hold on; errorbar([1:2],m,e,'b.');
text(1.4,double(max(m)*1.1),sprintf('p = %2.2g',pout));
set(gca,'XTickLabel',{xname yname});

return