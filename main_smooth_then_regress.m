clc;close all;clear;
load('data/cainiao.mat');
% item_info=zeros(4,1000);% cate_id,cate_level_id,brand_id,supplier_id
% item_data=zeros(444,25,6,1000);% ds,feature,store_id+1,item_id
%% ����ѵ�����Ͳ��Լ�
x_idx_train=1:430;
y_idx_train=431:437;
x_idx_test=8:437;
y_idx_test=438:444;
len=length(y_idx_train);
scale=1e4;
top_k=100;
target_flow=squeeze(item_data(:,24,:,:));%ds,store,item
x_train=target_flow(x_idx_train,:,:);
y_train=squeeze(sum(target_flow(y_idx_train,:,:),1))';
x_test=target_flow(x_idx_test,:,:);
y_test=squeeze(sum(target_flow(y_idx_test,:,:),1))';
%% first nonzero time
begin_idx_train=zeros(1000,1);
for item_id=1:1000
    begin_idx_train(item_id,1)=find(target_flow(:,1,item_id)>0,1);
end
begin_idx_test=max(ones(size(begin_idx_train)),begin_idx_train-len);
%% ����Ϊ14�ľ�ֵ����
%{
filter_window=7; %��λ���˲�����
item_id=3; %������
store_id=1; %�ֿ�
remove_len=floor((filter_window-1)/2);
data1=target_flow(:,store_id,item_id);
data2=smooth(data1,filter_window);
% data2=log(1+data2(1:end-remove_len));
figure;
subplot(211);
plot(1:length(data1),data1);
subplot(212);
plot(1:length(data2),data2);
%}
%% ʵ��
%
filter_window=1; %��λ���˲�����
remove_len=floor((filter_window-1)/2);
m=15; % ģ�ͽ״�
n=len; % n��Ԥ��
sample=0;%ѵ��������Χ
x_mf_train=medfilt1(x_train,filter_window,size(x_train,1),1);
x_mf_train=x_mf_train(remove_len+1:end-remove_len,:,:);
x_mf_test=medfilt1(x_test,filter_window,size(x_test,1),1);
x_mf_test=x_mf_test(remove_len+1:end-remove_len,:,:);
hege=(length(x_idx_train)+1-begin_idx_test)>=sample+m;

item_id=1;
store_id=1;
%train: Ԥ��sample+len������Ҫx����m+sample����y����len��
y=[x_mf_train(end-m-sample+1:end,store_id,item_id);target_flow(y_idx_train,store_id,item_id)];
y=log(1+y);
[theta,bias,~,L]=my_arma(y,m,1);
figure;plot(L);title('error');
%test
y=x_mf_test(end-m+1:end,store_id,item_id);
y=log(1+y);
p=my_predict(theta,bias,n,y);
p=exp(p)-1;
figure;
plot(1:size(x_mf_test,1),x_mf_test(:,store_id,item_id),'--',...
    size(x_mf_test,1)+1:size(x_mf_test,1)+n,target_flow(y_idx_test,store_id,item_id),'--',...
    size(x_mf_test,1)+1:size(x_mf_test,1)+n,p);
legend('x','y','predict');
%}
%% �Ƚϲ�ͬģ���ڸ���ά���ϵ�Ԥ����item��begin_time��store_id��brand��supplier
% ǰ8����ֵ�˲�
last_k=8;
predict_median_train=squeeze(median(x_train(end-last_k+1:end,:,:),1))'*len;
predict_median_test=squeeze(median(x_test(end-last_k+1:end,:,:),1))'*len;
score_median_train=calculate_score(predict_median_train,y_train,config_a,config_b)/scale;
score_median_test=calculate_score(predict_median_test,y_test,config_a,config_b)/scale;

% ����ֵ�˲����ٶ����m�������Իع飬n��Ԥ��ֵ�����ΪԤ��
%{
filter_window    m    train    test
      3          20   114.36   119.69
      3          10   128.83   134.18
      1          20   153.43   159.43
      1          10   209.20   151.88
%}
predict_arma_test=zeros(1000,6);
filter_window=1; %��λ���˲�����
remove_len=floor((filter_window-1)/2);
m=15; % ģ�ͽ״�
n=len; % n��Ԥ��
sample=0;%ѵ��������Χ
x_mf_train=medfilt1(x_train,filter_window,size(x_train,1),1);
x_mf_train=x_mf_train(remove_len+1:end-remove_len,:,:);
x_mf_test=medfilt1(x_test,filter_window,size(x_test,1),1);
x_mf_test=x_mf_test(remove_len+1:end-remove_len,:,:);
hege=(length(x_idx_train)+1-begin_idx_test)>=sample+m;
xiaxian=predict_median_test<10;
%
wb=waitbar(0,'����: 0%');
tic;
for item_id=1:top_k %������
    if(~hege(item_id)) 
        continue;
    end
    waitbar(item_id/top_k,wb,strcat('����: ',num2str(item_id/top_k*100),'%'));
    for store_id=1:6 %�ֿ�
        if(xiaxian(item_id,store_id))
            predict_arma_test(item_id,store_id)=predict_median_test(item_id,store_id);
            continue;
        end
        %train: Ԥ��sample+len������Ҫx����m+sample����y����len��
        y=[x_mf_train(end-m-sample+1:end,store_id,item_id);target_flow(y_idx_train,store_id,item_id)];
%         y=log(1+y);
        [theta,bias,~,L]=my_arma(y,m,1);
        if L(end)>0.1
            disp(strcat(num2str(store_id),',',num2str(item_id)));
        end
        %test
        y=x_mf_test(end-m+1:end,store_id,item_id);
%         y=log(1+y);
        p=my_predict(theta,bias,n,y);
%         p=exp(p)-1;
        predict_arma_test(item_id,store_id)=sum(p);
    end
end
toc;
close(wb);
%û����ĸ�ֵbaseline
predict_arma_test(top_k+1:1000,:)=predict_median_test(top_k+1:1000,:);
predict_arma_test(~hege,:)=predict_median_test(~hege,:);
score_arma_test=calculate_score(predict_arma_test,y_test,config_a,config_b)/scale;
%% �ں����ֽ����
lambda=0.6;
predict_esemble_test=lambda*predict_median_test+(1-lambda)*predict_arma_test;
score_esemble_test=calculate_score(predict_esemble_test,y_test,config_a,config_b)/scale;
%% �Ƚ����
cost_median_test=calculate_score_seperate(predict_median_test,y_test,config_a,config_b);
cost_arma_test=calculate_score_seperate(predict_arma_test,y_test,config_a,config_b);
%item
idx=1:1000;
figure;
plot(idx,sum(cost_median_test,2),idx,sum(cost_arma_test,2));
legend('median','arma');
title('test');xlabel('item');ylabel('cost');
%}