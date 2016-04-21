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
target_flow=squeeze(item_data(:,24,:,:));
% x_train=item_data(x_idx_train,:,:,:);
y_train=squeeze(sum(target_flow(y_idx_train,:,:),1));
% x_test=item_data(x_idx_test,:,:,:);
y_test=squeeze(sum(target_flow(y_idx_test,:,:),1));

predict_baseline_train=squeeze(sum(target_flow(y_idx_train-len,:,:),1));
score_baseline_train=calculate_score(predict_baseline_train',y_train',config_a,config_b)/scale;
predict_baseline_test=squeeze(sum(target_flow(y_idx_test-len,:,:),1));
score_baseline_test=calculate_score(predict_baseline_test',y_test',config_a,config_b)/scale;
temp=calculate_score_seperate(predict_baseline_test',y_test',config_a,config_b)/scale;
curve=tril(ones(1000),0)*sum(temp,2)/score_baseline_test;
figure;
plot(curve);xlabel('item');title('accumulate cost');grid;
%% first nonzero time
begin_idx_train=zeros(1000,1);
for i1=1:1000
    begin_idx_train(i1,1)=find(target_flow(:,1,i1)>0,1);
end
begin_idx_test=max(ones(size(begin_idx_train)),begin_idx_train-length(y_idx_train));
% 求训练集目标的中位数
med_train=zeros(6,1000);
for i1=1:1000
    ind=min(begin_idx_train(i1),length(x_idx_train));
    med_train(:,i1)=squeeze(median(target_flow(x_idx_train(ind:end),:,i1),1));
end


