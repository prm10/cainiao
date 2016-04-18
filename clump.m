function y=clump(x,max_x)
c=ones(size(x));
y=min(c*max_x,max(-c*max_x,x));

