%% preprocess
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
% inspect data
%{
% s=sum(item_dt_target(:,:,1),2);
% figure;
% plot(s);
% all_vs_branch=sum(sum((item_dt_target(:,:,1)-sum(item_dt_target(:,:,2:end),3)).^2));
figure;
subplot(211);
plot(sum(item_dt_target(:,:,1),1));
subplot(212);
plot(item_dt_target(3,:,1));
%}
% 建立训练集和测试集
x_idx_train=1:430;
y_idx_train=431:437;
x_idx_test=8:437;
y_idx_test=438:444;

% x_idx_test=x_idx_test-5;
% y_idx_test=y_idx_test-5;

x_train=item_dt_target(:,x_idx_train,:);
y_train=squeeze(sum(item_dt_target(:,y_idx_train,:),2));
x_test=item_dt_target(:,x_idx_test,:);
y_test=squeeze(sum(item_dt_target(:,y_idx_test,:),2));
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
%% simple strategy
%% 最近k天销量的中位数*14作为预测
%{
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
    score_median_k_test(i1,1)=calculate_score(predict_test,y_test,config_a,config_b)/scatter;
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
%% 一年前的今天乘以一定的比例系数作为今天的预测（适用的item有限）



%% 尝试 median filter
%{
data1=item_dt_target(3,:,1)';
data2=medfilt1(data1,3);
figure;
subplot(211);
plot(1:size(data1,1),data1);
subplot(212);
plot(1:size(data2,1),data2);
% plot(1:size(data1,1),data1,1:size(data1,1),data2);
%}
%% 先中值滤波，再对最近m天销量自回归，n步预测值求和作为预测
%{
filter_window=3; %中位数滤波窗口
m=20; % 模型阶次
i1=13; %样本点
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

x_mf_test=medfilt1(x_test,filter_window,size(x_test,2),2);
y=x_mf_test(i1,:,store_idx)';
y=y(begin_idx_test(i1):end);%
n=length(y_idx_test);
[theta,bias,S,L]=my_arma(y,m,n);
p=my_predict(theta,bias,n,y(end-m+1:end));
figure;
% 真实值
% plot(test_x_idx,test_x(i1,:,store_idx),test_y_idx,item_dt_target(i1,test_y_idx,store_idx),test_y_idx,p);
% 滤波后的值
plot(x_idx_test(begin_idx_test(i1):end),y,y_idx_test,item_dt_target(i1,y_idx_test,store_idx),y_idx_test,p);
legend('x','y','predict');
%}
%% 比较不同模型在各个维度上的预测误差：item、begin_time、store_id、brand、supplier
% 前8天中值滤波
last_k=8;
predict_median_train=squeeze(median(x_train(:,end-last_k+1:end,:),2))*length(y_idx_train);
predict_median_test=squeeze(median(x_test(:,end-last_k+1:end,:),2))*length(y_idx_test);
score_median_train=calculate_score(predict_median_train,y_train,config_a,config_b)/scatter;
score_median_test=calculate_score(predict_median_test,y_test,config_a,config_b)/scatter;

% 先中值滤波，再对最近m天销量自回归，n步预测值求和作为预测
%{
filter_window    m    train    test
      3          20   114.36   119.69
      3          10   128.83   134.18
      1          20   153.43   159.43
      1          10   209.20   151.88
%}
top_k_arma=100;
predict_arma_train=zeros(1000,6);
predict_arma_test=zeros(1000,6);
filter_window=3; %中位数滤波窗口
m=20; % 模型阶次
n=length(y_idx_train); % n步预测
x_mf_train=medfilt1(x_train,filter_window,size(x_train,2),2);
x_mf_test=medfilt1(x_test,filter_window,size(x_test,2),2);
wb=waitbar(0,'进度: 0%');
tic;
for i1=1:top_k_arma %样本点
    waitbar(i1/top_k_arma,wb,strcat('进度: ',num2str(i1/top_k_arma*100),'%'));
    for store_idx=1:6 %仓库
        %train
        y=x_mf_train(i1,:,store_idx)';
        y=y(begin_idx_train(i1):end);% start from nonzero index
        if(length(y)>m+n)
            [theta,bias,~,~]=my_arma(y,m,n);
            p=my_predict(theta,bias,n,y(end-m+1:end));
            predict_arma_train(i1,store_idx)=sum(p);
        else
            if ~isempty(y)
                predict_arma_train(i1,store_idx)=median(y);
            else
                predict_arma_train(i1,store_idx)=0;
            end
        end
        %test
        y=x_mf_test(i1,:,store_idx)';
        y=y(begin_idx_test(i1):end);% start from nonzero index
        if(length(y)>m+n)
            [theta,bias,~,~]=my_arma(y,m,n);
            p=my_predict(theta,bias,n,y(end-m+1:end));
            predict_arma_test(i1,store_idx)=sum(p);
        else
            if ~isempty(y)
                predict_arma_test(i1,store_idx)=median(y);
            else
                predict_arma_test(i1,store_idx)=0;
            end
        end
    end
end
toc;
close(wb);
predict_arma_train(top_k_arma+1:1000,:)=predict_median_train(top_k_arma+1:1000,:);
predict_arma_test(top_k_arma+1:1000,:)=predict_median_test(top_k_arma+1:1000,:);
score_arma_train=calculate_score(predict_arma_train,y_train,config_a,config_b)/scatter;
score_arma_test=calculate_score(predict_arma_test,y_test,config_a,config_b)/scatter;
%% 融合两种结果：
lambda=0.9;
predict_esemble_train=lambda*predict_median_train+(1-lambda)*predict_arma_train;
predict_esemble_test=lambda*predict_median_test+(1-lambda)*predict_arma_test;
score_esemble_train=calculate_score(predict_esemble_train,y_train,config_a,config_b)/scatter;
score_esemble_test=calculate_score(predict_esemble_test,y_test,config_a,config_b)/scatter;
%% 比较误差
cost_median_train=calculate_score_seperate(y_train,predict_median_train,config_a,config_b);
cost_median_test=calculate_score_seperate(y_test,predict_median_test,config_a,config_b);
cost_arma_train=calculate_score_seperate(y_train,predict_arma_train,config_a,config_b);
cost_arma_test=calculate_score_seperate(y_test,predict_arma_test,config_a,config_b);

%item
idx=1:1000;
figure;
subplot(211);
plot(idx,sum(cost_median_train,2),idx,sum(cost_arma_train,2));
legend('median','arma');
title('train');xlabel('item');ylabel('cost');
subplot(212);
plot(idx,sum(cost_median_test,2),idx,sum(cost_arma_test,2));
legend('median','arma');
title('test');xlabel('item');ylabel('cost');



