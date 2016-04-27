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

x_test=item_data(x_idx_test(end-len+1:end),:,:,:);
top_k=400;
% figure;
% hist(target(4,1:top_k),100);

% 预测值除以baseline，除以缩放系数
% scale_base=max(y_train,ones(size(y_train)));
% target=y_test./scale_base/scale_regress;
% target=min(target,ones(size(target)));
% target=target(:,1:top_k);
% 预测值减去baseline
target=y_test-y_train;
target=target(:,1:top_k);
%% 看分布
%
for idx_f=1:25
%最后7天的某一特征总和
%     f1=squeeze(mean(x_test(end-len+1:end,idx_f,:,1:top_k),1));
%某一特征总和
%     f1=squeeze(sum(x_test(:,idx_f,:,1:top_k),1));
%最后7天的多项式拟合系数
%     f1=zeros(6,top_k);
%     for store_id=1:6
%         for item_id=1:top_k
%             x=x_test(end-len+1:end,idx_f,store_id,item_id);%/scale_base(store_id,item_id);
%             [p,S]=polyfit(1:length(x),x',1);
%             f1(store_id,item_id)=p(2);
%         end
%     end
%最后7天的某一特征的排名（总的）
%     [~,f1]=sort(squeeze(mean(x_test(end-len+1:end,idx_f,:,1:top_k),1)),2,'descend');
%最后7天的某一特征的排名（类目内的）
%     f1=zeros(6,top_k);
%     score=squeeze(mean(x_test(end,idx_f,:,1:top_k),1));
%     info=item_info(1,1:top_k);
%     for i1=1:max(info)
%         ind=info==i1;
%         [~,r]=sort(score(:,ind),2,'descend');
%         f1(:,ind)=r;
%     end
% 双11双12销量与近7天销量均值的比例
%     sum_recent=squeeze(mean(x_test(end-len+1:end,idx_f,:,1:top_k),1));
% %     shuang11=squeeze(item_data(398,idx_f,:,1:top_k));
% %     f1=shuang11./max(sum_recent,ones(size(sum_recent)));
%     shuang12=squeeze(item_data(429,idx_f,:,1:top_k));
%     f1=shuang12./max(sum_recent,ones(size(sum_recent)));
% 双12之前销量与近7天销量均值的比例
%     sum_recent=squeeze(mean(x_test(end-len+1:end,idx_f,:,1:top_k),1));
%     sum_before=squeeze(mean(item_data(420:422,idx_f,:,1:top_k),1));
%     f1=sum_before./max(sum_recent,ones(size(sum_recent)));
% 与双11之后8~14天的相似程度
%     sum_8=squeeze(mean(item_data(406:412,idx_f,:,1:top_k),1));
%     sum_1=squeeze(mean(item_data(399:405,idx_f,:,1:top_k),1));
%     f1=sum_8-sum_1;
% 累积引导量
    figure;
    plot(f1(:),target(:),'.',[0,max(f1(:))],[0,0],'--');
    title(num2str(idx_f));
    ylabel('target');xlabel('feature');
end
%}
%% 分析趋势和相关性
%{
item_id=22;
store_id=1;
feature_id=2;
data=item_data(:,:,store_id,item_id);
figure;
subplot(211);
plot(1:444,data(:,end-1));title('目标24');
subplot(212);
plot(1:444,log(1+data(:,feature_id)));title(num2str(feature_id));
%
% range1=400:437;
% range2=y_idx_test;
% figure;
% plot(range1,data(range1,feature_id),'--b*',range2,data(range2,feature_id),'ro');
% title(num2str(scale_regress*target(store_id,item_id)));
% x=data(433:437,feature_id)/scale_base(store_id,item_id);
% [p,S]=polyfit(1:length(x),x',1);
%}
%% 长度为14的均值滑窗
%{
filter_window=7; %中位数滤波窗口
item_id=3; %样本点
store_id=1; %仓库
remove_len=floor((filter_window-1)/2);
data1=target_flow(:,store_id,item_id);
data2=smooth(data1,filter_window);
% data2=log(1+data2(1:end-remove_len));
data2=log(1+data1);
figure;
subplot(211);
plot(1:length(data1),data1,'--*');
subplot(212);
plot(1:length(data2),data2,'--*');
%}
