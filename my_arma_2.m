function [theta,bias,scale,L]=my_arma_2(y0,m,n)
%{
���룺
y0 ���ݾ���ÿ��Ԫ��y����Ϊ(m+n)*batch
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
loops=1000;
lr=1e-2;
lambda=0;  %regularization
max_g=1;
% data process
batch=size(y0,2);
scale=zeros(batch,1);
for i1=1:batch
    y=y0(:,i1);
    scale(i1,1)=max(1,mean(y));
    y0(:,i1)=y/scale(i1,1);
end
theta=normrnd(0,0.01,[m,1]);%zeros(m+1,1);
grad_theta=zeros(m,1);
bias=0.1;
grad_bias=0;
L=zeros(loops,1);

% theta_history=zeros(loops,m);

for i1=1:loops
%     if mod(i1,batch)==0
%         lr=lr*0.9;
%     end
    grad_theta=grad_theta*0;
    grad_bias=grad_bias*0;
    for i2=1:batch
%     i2=mod(i1-1,batch)+1;
        y=y0(:,i2);
        y1=y(1:m);
        T=y(m+1:m+n);
        S=my_predict(theta,bias,n,y1);
        [grad_theta1,grad_bias1,L1]=my_gradient(S,T,y1,theta);
        grad_theta=grad_theta+grad_theta1/batch;
        grad_bias=grad_bias+grad_bias1/batch;
        L(i1)=L(i1)+L1/batch;
    end
    theta=theta-lr*clump((lambda*theta+grad_theta),max_g);
    bias=bias-lr*clump((lambda*bias+grad_bias),max_g);
%     theta_history(i1,:)=theta;
end
% bias=bias*scale; % scale the parameters back

% figure;
% plot(theta_history);