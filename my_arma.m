function [theta,bias,S,L]=my_arma(y,m,n)
%{
���룺
N y�ĳ���
m ģ�ͽ״�
n Ԥ�ⳤ��
����y�ĵ�1~m��Ԥ���m+1~m+n����
������õ�N-n-m+1~N-n����Ԥ��N-n+1~N
ģ�ͽ״�Ϊm+1��theta+bias����
�����
theta bias ģ�Ͳ���
S �õ�N-n-m+1~N-n����Ԥ��N-n+1~N��n��Ԥ��ֵ
L ÿ��ѭ����ģ����� 
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