clc;close all;clear;
load('data/cainiao.mat');
% item_info=zeros(4,1000);% cate_id,cate_level_id,brand_id,supplier_id
% item_data=zeros(444,25,6,1000);% ds,feature,store_id+1,item_id
%Ŀ��ֵ�����Ź�ģ
scale=1e4;
%ȡǰtop_k��item������
top_k=400;
%Ŀ��ֵ
target_flow=squeeze(item_data(:,24,:,:));
%% ѵ����
%ʱ�����
x_idx_train=430:433;
y_idx_train=434:437;
%ѡȡ�����ݳ���
len_train=length(x_idx_train);
%ʱ����ڵĺ�
x_train=squeeze(sum(target_flow(x_idx_train,:,:),1));
y_train=squeeze(sum(target_flow(y_idx_train,:,:),1));
% Ԥ��ֵ��ȥbaseline
target_train=(y_train-x_train)/len_train;
%% ���Լ�
%ʱ�����
x_idx_test=431:437;
y_idx_test=438:444;
%ѡȡ�����ݳ���
len_test=length(x_idx_test);
%ʱ����ڵĺ�
x_test=squeeze(sum(target_flow(x_idx_test,:,:),1));
y_test=squeeze(sum(target_flow(y_idx_test,:,:),1));
% Ԥ��ֵ��ȥbaseline
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

