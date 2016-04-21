function [theta,bias,S,L]=my_arma(y0,m,n)
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
% parameters:
loops=1e3;
lr=1e-1;
lambda=1e-3;  %regularization
max_g=1;
% data process
y=max(y0,ones(size(y0)));
scatter=max(1,mean(y0));
y=y/scatter;
theta=normrnd(0,0.01,[m,1]);%zeros(m+1,1);
bias=10/scatter;
N=length(y);
batch=N-n-m+1;
L=zeros(loops,1);

% theta_history=zeros(loops,m);

for i1=1:loops
%     if mod(i1,500)==0
%         lr=lr*0.9;
%     end
    i2=mod(i1,batch);
    y1=y(i2+1:i2+m);
    T=y(i2+m+1:i2+m+n);
    S=my_predict(theta,bias,n,y1);
    [grad_theta,grad_bias,L(i1)]=my_gradient(S,T,y1,theta);
    theta=theta-lr*clump((lambda*theta+grad_theta),max_g);
    bias=bias-lr*clump((lambda*bias+grad_bias),max_g);
%     theta_history(i1,:)=theta;
end
bias=bias*scatter; % scatter the parameters back
y1=y0(batch:batch-1+m);
S=my_predict(theta,bias,n,y1);

% figure;
% plot(theta_history);