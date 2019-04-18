% Remove any zero columns or rows at the beginning or end of an image

function X = removezeros(X)
r = any(X,2)';
c = any(X,1);

rz = find(r==0); rnz = find(r~=0);
rnzmin = min(rnz); rnzmax = max(rnz);
cz = find(c==0); cnz = find(c~=0);
cnzmin = min(cnz); cnzmax = max(cnz);

rrem = [rz(rz<rnzmin) rz(rz>rnzmax)];
crem = [cz(cz<cnzmin) cz(cz>cnzmax)];

X(rrem,:) = [];
X(:,crem) = [];
return;
