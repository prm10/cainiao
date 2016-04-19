clc;close all;clear;
d=load('data/item_store_feature.mat');
item_store_feature=d.item_store_feature;
d=load('data/item_feature.mat');
item_feature=d.item_feature;
d=load('data/config.mat');
config=d.config;
% standarlize config and target
config_a=zeros(1000,6);
config_b=zeros(1000,6);
for i1=0:5
    idx=find(config(:,2)==i1);
    for i2=idx'
        info=config(i2,:);
        config_a(info(1),i1+1)=info(3);
        config_b(info(1),i1+1)=info(4);
    end
end
item_dt_target=zeros(1000,444,6);
for i1=1:size(item_feature,1)
    x2=item_feature(i1,1);
    x1=item_feature(i1,2);
%     if(item_dt_target(x1,x2)~=0)% 看有没有重复累加记录
%         disp(strcat(num2str(x2,',',x1)));
%     end
    item_dt_target(x1,x2,1)=item_dt_target(x1,x2,1)+item_feature(i1,end-1);
end
for i1=1:size(item_store_feature,1)
    x2=item_store_feature(i1,1);
    x1=item_store_feature(i1,2);
    x3=item_store_feature(i1,3)+1;
    item_dt_target(x1,x2,x3)=item_dt_target(x1,x2,x3)+item_store_feature(i1,end-1);
end
% 建立训练集和测试集
x_idx_train=1:430;
y_idx_train=431:444;
x_idx_test=15:444;
y_idx_test=445:444+14;

x_train=item_dt_target(:,x_idx_train,:);
y_train=squeeze(sum(item_dt_target(:,y_idx_train,:),2));
x_test=item_dt_target(:,x_idx_test,:);
% y_test=squeeze(sum(item_dt_target(:,y_idx_test,:),2));
scatter=1e4;
% first time
begin_idx_train=zeros(1000,1);
for i1=1:1000
    begin_idx_train(i1,1)=find(item_dt_target(i1,:,1)>0,1);
end
begin_idx_test=max(ones(size(begin_idx_train)),begin_idx_train-length(y_idx_train));
% figure;
% % hist(begin_idx,100);
% plot(begin_idx,'.');
%% 最近k天销量的中位数*14作为预测
%
%{
method           train    test    days
median(10 days)  99.83    96.32    8
mean(7 days)     276      95.66    7
%}
%中位数
last_k=5:20;
score_median_k_train=zeros(length(last_k),1);
score_median_k_test=zeros(length(last_k),1);
for i1=1:length(last_k)
    predict_train=squeeze(median(item_dt_target(:,x_idx_train(end-last_k(i1)+1:end),:),2))*length(y_idx_train);
    score_median_k_train(i1,1)=calculate_score(predict_train,y_train,config_a,config_b)/scatter;
    predict_test=squeeze(median(item_dt_target(:,x_idx_test(end-last_k(i1)+1:end),:),2))*length(y_idx_test);
%     score_median_k_test(i1,1)=calculate_score(predict_test,y_test,config_a,config_b)/scatter;
end

%均值
% last_k=1:50;
% score_median_k_train=zeros(length(last_k),1);
% score_median_k_test=zeros(length(last_k),1);
% for i1=1:length(last_k)
%     predict_train=squeeze(mean(item_dt_target(:,x_idx_train(end-last_k(i1)+1:end),:),2))*length(y_idx_train);
%     score_median_k_train(i1,1)=calculate_score(predict_train,y_train,config_a,config_b)/scatter;
%     predict_test=squeeze(mean(item_dt_target(:,x_idx_test(end-last_k(i1)+1:end),:),2))*length(y_idx_test);
%     score_median_k_test(i1,1)=calculate_score(predict_test,y_test,config_a,config_b)/scatter;
% end
figure;
subplot(211);
plot(last_k,score_median_k_train,'--*');
title('train');xlabel('last k day');ylabel('cost');grid;
subplot(212);
plot(last_k,score_median_k_test,'--*');
title('test');xlabel('last k day');ylabel('cost');grid;
%}
%% 先中值滤波，再对最近m天销量自回归，n步预测值求和作为预测
%{
filter_window=3; %中位数滤波窗口
m=20; % 模型阶次
i1=100; %样本点
store_idx=1; %仓库

x_mf_train=medfilt1(x_train,filter_window,size(x_train,2),2);
y=x_mf_train(i1,:,store_idx)';
y=y(begin_idx_train(i1):end);
n=length(y_idx_train);
[theta,bias,~,L]=my_arma(y,m,n);
p=my_predict(theta,bias,n,y(end-m+1:end));
figure;plot(L);
figure;
% 真实值
% plot(train_x_idx,train_x(i1,:,store_idx),train_y_idx,item_dt_target(i1,train_y_idx,store_idx),train_y_idx,p);
% 滤波后的值
plot(x_idx_train(begin_idx_train(i1):end),y,y_idx_train,item_dt_target(i1,y_idx_train,store_idx),y_idx_train,p);
legend('x','y','predict');

% x_mf_test=medfilt1(x_test,filter_window,size(x_test,2),2);
% y=x_mf_test(i1,:,store_idx)';
% y=y(begin_idx_test(i1):end);%
% n=length(y_idx_test);
% [theta,bias,S,L]=my_arma(y,m,n);
% p=my_predict(theta,bias,n,y(end-m+1:end));
% figure;
% % 真实值
% % plot(test_x_idx,test_x(i1,:,store_idx),test_y_idx,item_dt_target(i1,test_y_idx,store_idx),test_y_idx,p);
% % 滤波后的值
% plot(x_idx_test(begin_idx_test(i1):end),y,y_idx_test,item_dt_target(i1,y_idx_test,store_idx),y_idx_test,p);
% legend('x','y','predict');
%}
%% on-line predict
last_k=15;
predict=squeeze(median(item_dt_target(:,end-last_k+1:end,:),2))*14;
save('data/predict.mat','predict');
