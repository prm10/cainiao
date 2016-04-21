clc;close all;clear;
load('data/cainiao.mat');
% item_info=zeros(4,1000);% cate_id,cate_level_id,brand_id,supplier_id
% item_data=zeros(444,25,6,1000);% ds,feature,store_id+1,item_id

%% 建立训练集和测试集
x_idx_train=1:430;
y_idx_train=431:437;
x_idx_test=8:437;
y_idx_test=438:444;
len=length(y_idx_train);
scale=1e4;
scale_regress=8;
target_flow=squeeze(item_data(:,24,:,:));
% x_train=item_data(x_idx_train,:,:,:);
y_train=squeeze(sum(target_flow(y_idx_train,:,:),1));
% x_test=item_data(x_idx_test,:,:,:);
y_test=squeeze(sum(target_flow(y_idx_test,:,:),1));
scale_base=max(y_train,ones(size(y_train)));
target=y_test./scale_base/scale_regress;
target=min(target,ones(size(target)));
x_test=item_data(x_idx_test(end-7+1:end),:,:,:);
top_k=400;
% figure;
% hist(target(4,1:top_k),100);
target=target(:,1:top_k);
%% 看分布
%
idx_f=24;
%     f1=squeeze(mean(x_test(end-6:end,idx_f,:,1:top_k),1));
%     f1=squeeze(sum(x_test(:,idx_f,:,1:top_k),1));
    f1=zeros(6,top_k);
    for store_id=1:6
        for item_id=1:top_k
            x=item_data(432:437,24,store_id,item_id);%/scale_base(store_id,item_id);
            [p,S]=polyfit(1:length(x),x',1);
            f1(store_id,item_id)=p(1);
        end
    end
    figure;
    plot(target(:),f1(:),'.');
    title(num2str(idx_f));
    xlabel('target');ylabel('feature');

%}
%% 分析趋势和相关性
%
item_id=4;
store_id=1;
feature_id=24;
data=item_data(:,:,store_id,item_id);
% figure;
% subplot(211);
% plot(1:444,data(:,end-1));
% subplot(212);
% plot(1:444,data(:,feature_id));

range1=400:437;
range2=y_idx_test;
figure;
plot(range1,data(range1,feature_id),'--b*',range2,data(range2,feature_id),'ro');
title(num2str(scale_regress*target(store_id,item_id)));
x=data(433:437,feature_id)/scale_base(store_id,item_id);
[p,S]=polyfit(1:length(x),x',1);
%}

