%% online data
clc;close all;clear;
load('data/cainiao.mat');
% item_info=zeros(4,1000);% cate_id,cate_level_id,brand_id,supplier_id
% item_data=zeros(444,25,6,1000);% ds,feature,store_id+1,item_id
%目标值的缩放规模
scale=1e4;
%取前top_k个item来分析
top_k=400;
%目标值
target_flow=squeeze(item_data(:,24,:,:));%% 训练集
%时间序号
x_idx_train=431:437;
y_idx_train=438:444;
%选取的数据长度
len_train=length(x_idx_train);
%时间段内的和
x_train=squeeze(sum(target_flow(x_idx_train,:,:),1));
y_train=squeeze(sum(target_flow(y_idx_train,:,:),1));
% 预测值减去baseline
target_train=(y_train-x_train)/len_train;
%% 测试集
%时间序号
x_idx_test=431:444;
% y_idx_test=0;
%选取的数据长度
len_test=length(x_idx_test);
%时间段内的和
x_test=squeeze(sum(target_flow(x_idx_test,:,:),1));
% y_test=squeeze(sum(target_flow(y_idx_test,:,:),1));
% 预测值减去baseline
% target_test=(y_test-x_test)/len_test;
%% 特征工程 训练集
f_train=cell(0);
now=1;
% 最后len_train天的25个特征均值
for idx_f=1:25
    f_train{now,1}=squeeze(mean(item_data(x_idx_train,idx_f,:,1:top_k),1));
    now=now+1;
end
% 排名
for idx_info=1:4
    for idx_f=1:25
        temp=zeros(6,top_k);
        score=squeeze(mean(item_data(x_idx_train,idx_f,:,1:top_k),1));
        info=item_info(idx_info,1:top_k);
        for i1=1:max(info)
            ind=info==i1;
            [~,r]=sort(score(:,ind),2,'descend');
            temp(:,ind)=r;
        end
        f_train{now,1}=temp;
        now=now+1;
    end
end
% 双11双12占近一个月总销量比例
f_train{now,1}=(...
    squeeze(item_data(398,24,:,1:top_k))+...
    squeeze(item_data(429,24,:,1:top_k))...
    )./...
    squeeze(sum(item_data(380:max(x_idx_train),24,:,1:top_k),1));
now=now+1;
% item的基本信息
for i1=1:4
    f_train{now,1}=repmat(item_info(i1,1:top_k),6,1);
	now=now+1;
end
% 合成特征矩阵和目标矩阵
feature_mat_train=zeros(6*top_k,size(f_train,1));
for i1=1:size(f_train,1)
    feature_mat_train(:,i1)=f_train{i1}(:);
end
target_mat_train=target_train(:,1:top_k);
target_mat_train=target_mat_train(:);
%% 特征工程 测试集
f_test=cell(0);
now=1;
% 最后len_test天的25个特征均值
for idx_f=1:25
    f_test{now,1}=squeeze(mean(item_data(x_idx_test,idx_f,:,1:top_k),1));
    now=now+1;
end
% 排名
for idx_info=1:4
    for idx_f=1:25
        temp=zeros(6,top_k);
        score=squeeze(mean(item_data(x_idx_test,idx_f,:,1:top_k),1));
        info=item_info(idx_info,1:top_k);
        for i1=1:max(info)
            ind=info==i1;
            [~,r]=sort(score(:,ind),2,'descend');
            temp(:,ind)=r;
        end
        f_test{now,1}=temp;
        now=now+1;
    end
end
% 双11双12占近一个月总销量比例
f_test{now,1}=(...
    squeeze(item_data(398,24,:,1:top_k))+...
    squeeze(item_data(429,24,:,1:top_k))...
    )./...
    squeeze(sum(item_data(380:max(x_idx_test),24,:,1:top_k),1));
now=now+1;
% item的基本信息
for i1=1:4
    f_test{now,1}=repmat(item_info(i1,1:top_k),6,1);
	now=now+1;
end
% 合成特征矩阵和目标矩阵
feature_mat_test=zeros(6*top_k,size(f_test,1));
for i1=1:size(f_test,1)
    feature_mat_test(:,i1)=f_test{i1}(:);
end
% target_mat_test=target_test(:,1:top_k);
% target_mat_test=target_mat_test(:);
target_mat_test=zeros(size(target_mat_train));
save('data/regression_input_online.mat','feature_mat_train','target_mat_train','feature_mat_test','target_mat_test');
