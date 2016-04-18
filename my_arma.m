function [theta,bias,S,L]=my_arma(y,m,n)
%{
输入：
N y的长度
m 模型阶次
n 预测长度
利用y的第1~m，预测第m+1~m+n个；
到最后，用第N-n-m+1~N-n个，预测N-n+1~N
模型阶次为m+1（theta+bias）。
输出：
theta bias 模型参数
S 用第N-n-m+1~N-n个，预测N-n+1~N的n步预测值
L 每次循环的模型误差 
%}
y=max(y,ones(size(y)));
theta=normrnd(0,0.1,[m,1]);%zeros(m+1,1);
bias=normrnd(0,0.1,1);
loops=1e3;
lr=1e-2/mean(y);
N=length(y);
batch=N-n-m+1;
L=zeros(loops,1);
max_g=0.1;

for i1=1:loops
    i2=mod(i1,batch);
    y0=y(i2+1:i2+m);
    T=y(i2+m+1:i2+m+n);
    S=my_predict(theta,bias,n,y0);
    [grad_theta,grad_bias,L(i1)]=my_gradient(S,T,y0,theta);
    theta=theta-lr*clump(grad_theta,max_g);
    bias=bias-lr*clump(grad_bias,max_g);
%     L(i1)
end
y0=y(batch:batch-1+m);
S=my_predict(theta,bias,n,y0);