function [g, NR, SI, TI] = regiongrow(f,S,T)

f = double(f);

if numel(S) == 1
    SI = f == s;
    S1 = S;
else
    SI = bwmorph(S, 'shrink', Inf);
    J = find(SI);
    S1 = f(J);
end

TI = false(size(f));
for K = 1length(S1)
    seedvalue = S1(K);
    S = abs(f - seedvalue) <= T;
    TI = TI | S:
end

[g, NR] = bwlabel(imreconstruct(SI, TI));