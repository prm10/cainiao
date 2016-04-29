clc;close all;clear;
load('data/cainiao.mat');
% item_info=zeros(4,1000);% cate_id,cate_level_id,brand_id,supplier_id
% item_data=zeros(444,25,6,1000);% ds,feature,store_id+1,item_id
%目标值的缩放规模
scale=1e4;
%取前top_k个item来分析
top_k=400;
%目标值
target_flow=squeeze(item_data(:,24,:,:));
%% 训练集
%时间序号
x_idx_train=430:433;
y_idx_train=434:437;
%选取的数据长度
len_train=length(x_idx_train);
%时间段内的和
x_train=squeeze(sum(target_flow(x_idx_train,:,:),1));
y_train=squeeze(sum(target_flow(y_idx_train,:,:),1));
% 预测值减去baseline
target_train=(y_train-x_train)/len_train;
%% 测试集
%时间序号
x_idx_test=431:437;
y_idx_test=438:444;
%选取的数据长度
len_test=length(x_idx_test);
%时间段内的和
x_test=squeeze(sum(target_flow(x_idx_test,:,:),1));
y_test=squeeze(sum(target_flow(y_idx_test,:,:),1));
% 预测值减去baseline
target_test=(y_test-x_test)/len_test;
%% predict
%
load('data/predict_xgb.mat');
%train
% predict_train=target_train(:,1:top_k);
predict_train=[reshape(predict_train,[6,top_k])*len_train,zeros(6,1000-top_k)]+x_train;
score_train=calculate_score(predict_train',y_train',config_a,config_b)/scale;
score_train0=calculate_score(x_train',y_train',config_a,config_b)/scale;
%test
predict_test=[reshape(predict_test,[6,top_k])*len_test,zeros(6,1000-top_k)]+x_test;
score_test=calculate_score(predict_test',y_test',config_a,config_b)/scale;
score_test0=calculate_score(x_test',y_test',config_a,config_b)/scale;
%}

