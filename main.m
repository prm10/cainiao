clc;close all;clear;
d=load('data/item_store_feature.mat');
item_store_feature=d.item_store_feature;
d=load('data/item_feature.mat');
item_feature=d.item_feature;
d=load('data/config.mat');
config=d.config;
%% standarlize config and target
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
%% inspect data
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
%% body
train_x_idx=1:430;
train_y_idx=431:437;
test_x_idx=8:437;
test_y_idx=438:444;

x_train=item_dt_target(:,train_x_idx,:);
train_y=squeeze(sum(item_dt_target(:,train_y_idx,:),2));
test_x=item_dt_target(:,test_x_idx,:);
test_y=squeeze(sum(item_dt_target(:,test_y_idx,:),2));
scatter=1e4;
%% first time
begin_train_idx=zeros(1000,1);
for i1=1:1000
    begin_train_idx(i1,1)=find(item_dt_target(i1,:,1)>0,1);
end
begin_test_idx=max(ones(size(begin_train_idx)),begin_train_idx-length(train_y_idx));
% figure;
% % hist(begin_idx,100);
% plot(begin_idx,'.');
%% simple strategy
%{
% 之前的中位数*14作为预测
train_predict=squeeze(median(item_dt_target(:,train_x_idx,:),2))*length(train_y_idx);
train_score1=calculate_score(train_predict,train_y,config_a,config_b)/scatter;

test_predict=squeeze(median(item_dt_target(:,test_x_idx,:),2))*length(test_y_idx);
test_score1=calculate_score(test_predict,test_y,config_a,config_b)/scatter;
%}
%% 最近k天销量的中位数*14作为预测
%
%{
method           train    test    days
median(10 days)  99.83    96.32    8
mean(7 days)     276      95.66    7
%}
%中位数
last_k=5:20;
score_train2=zeros(length(last_k),1);
score_test2=zeros(length(last_k),1);
for i1=1:length(last_k)
    predict_train=squeeze(median(item_dt_target(:,train_x_idx(end-last_k(i1)+1:end),:),2))*length(train_y_idx);
    score_train2(i1,1)=calculate_score(predict_train,train_y,config_a,config_b)/scatter;
    test_predict=squeeze(median(item_dt_target(:,test_x_idx(end-last_k(i1)+1:end),:),2))*length(test_y_idx);
    score_test2(i1,1)=calculate_score(test_predict,test_y,config_a,config_b)/scatter;
end

%均值
% last_k=1:50;
% train_score2=zeros(length(last_k),1);
% test_score2=zeros(length(last_k),1);
% for i1=1:length(last_k)
%     train_predict=squeeze(mean(item_dt_target(:,train_x_idx(end-last_k(i1)+1:end),:),2))*length(train_y_idx);
%     train_score2(i1,1)=calculate_score(train_predict,train_y,config_a,config_b)/scatter;
%     test_predict=squeeze(mean(item_dt_target(:,test_x_idx(end-last_k(i1)+1:end),:),2))*length(test_y_idx);
%     test_score2(i1,1)=calculate_score(test_predict,test_y,config_a,config_b)/scatter;
% end
figure;
subplot(211);
plot(last_k,score_train2,'--*');
title('train');xlabel('last k day');ylabel('cost');grid;
subplot(212);
plot(last_k,score_test2,'--*');
title('test');xlabel('last k day');ylabel('cost');grid;
%}
%% 一年前的今天乘以一定的比例系数作为今天的预测（适用的item有限）
%% 尝试 median filter
%
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
%
filter_window=3; %中位数滤波窗口
m=20; % 模型阶次
i1=1000; %样本点
store_idx=1; %仓库

train_x_mf=medfilt1(x_train,filter_window,size(x_train,2),2);
y=train_x_mf(i1,:,store_idx)';
y=y(begin_train_idx(i1):end);
n=length(train_y_idx);
[theta,bias,~,L]=my_arma(y,m,n);
p=my_predict(theta,bias,n,y(end-m+1:end));
figure;plot(L);
figure;
% 真实值
% plot(train_x_idx,train_x(i1,:,store_idx),train_y_idx,item_dt_target(i1,train_y_idx,store_idx),train_y_idx,p);
% 滤波后的值
plot(train_x_idx(begin_train_idx(i1):end),y,train_y_idx,item_dt_target(i1,train_y_idx,store_idx),train_y_idx,p);
legend('x','y','predict');

test_x_mf=medfilt1(test_x,filter_window,size(test_x,2),2);
y=test_x_mf(i1,:,store_idx)';
y=y(begin_test_idx(i1):end);%
n=length(test_y_idx);
[theta,bias,S,L]=my_arma(y,m,n);
p=my_predict(theta,bias,n,y(end-m+1:end));
figure;
% 真实值
% plot(test_x_idx,test_x(i1,:,store_idx),test_y_idx,item_dt_target(i1,test_y_idx,store_idx),test_y_idx,p);
% 滤波后的值
plot(test_x_idx(begin_test_idx(i1):end),y,test_y_idx,item_dt_target(i1,test_y_idx,store_idx),test_y_idx,p);
legend('x','y','predict');
%}
%% 比较不同模型在各个维度上的预测误差：item、begin_time、store_id、brand、supplier
% 前8天中值滤波
last_k=8;
train_predict_median=squeeze(median(x_train(:,end-last_k+1:end,:),2))*length(train_y_idx);
test_predict_median=squeeze(median(test_x(:,end-last_k+1:end,:),2))*length(test_y_idx);
% calculate_score(test_predict,test_y,config_a,config_b)/scatter;

% 先中值滤波，再对最近m天销量自回归，n步预测值求和作为预测
train_predict_arma=zeros(1000,6);
test_predict_arma=zeros(1000,6);
filter_window=3; %中位数滤波窗口
m=20; % 模型阶次
n=length(train_y_idx); % n步预测
train_x_mf=medfilt1(x_train,filter_window,size(x_train,2),2);
test_x_mf=medfilt1(test_x,filter_window,size(test_x,2),2);
wb=waitbar(0,'进度: 0%');
tic;
for i1=1:1000 %样本点
    waitbar(i1/1000,wb,strcat('进度: ',num2str(i1/10),'%'));
    for store_idx=1:6 %仓库
        %train
        y=train_x_mf(i1,:,store_idx)';
        y=y(begin_train_idx(i1):end);% start from nonzero index
        if(length(y)>m+n)
            [theta,bias,~,~]=my_arma(y,m,n);
            p=my_predict(theta,bias,n,y(end-m+1:end));
            train_predict_arma(i1,store_idx)=sum(p);
        else
            if ~isempty(y)
                train_predict_arma(i1,store_idx)=median(y);
            else
                train_predict_arma(i1,store_idx)=0;
            end
        end
        %test
        y=test_x_mf(i1,:,store_idx)';
        y=y(begin_test_idx(i1):end);% start from nonzero index
        if(length(y)>m+n)
            [theta,bias,~,~]=my_arma(y,m,n);
            p=my_predict(theta,bias,n,y(end-m+1:end));
            test_predict_arma(i1,store_idx)=sum(p);
        else
            if ~isempty(y)
                test_predict_arma(i1,store_idx)=median(y);
            else
                test_predict_arma(i1,store_idx)=0;
            end
        end
    end
end
toc;
close(wb);
score_train_arma=calculate_score(train_predict_arma,train_y,config_a,config_b)/scatter;
score_test_arma=calculate_score(test_predict_arma,test_y,config_a,config_b)/scatter;

error_train_arma=train_y-train_predict_arma;
error_test_arma=test_y-test_predict_arma;


