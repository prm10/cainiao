function [grad_theta,grad_bias,L]=my_gradient(S,T,y0,theta)
% 预测值S，真实值T，初始m个数据y0
m=size(y0,1);
n=size(S,1);
dS=zeros(n,1);
for i1=n:-1:1
%     temp=(S(i1)-T(i1))/T(i1)^2/n;% for music
    temp=(S(i1)-T(i1))/n;% for cainiao
    for i2=i1+1:min(i1+m,n)
        temp=temp+dS(i2)*theta(i2-i1);
    end
    dS(i1)=temp;
end
grad_bias=sum(dS);
grad_theta=zeros(m,1);
for i1=1:m
    if i1<n
        S_i=[y0(m-i1+1:m);S(1:n-i1)];
    else
        S_i=y0(m-i1+1:m+n-i1);
    end
    grad_theta(i1)=sum(dS.*S_i);
end
% L=mean(((S-T)./T).^2)/2;% for music
L=mean((S-T).^2)/2;% for cainiao