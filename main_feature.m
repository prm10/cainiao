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
% first time
begin_ds=zeros(1000,1);
for i1=1:1000
    begin_ds(i1,1)=find(target_flow(:,1,i1)>0,1);
end
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
%% 看分布
%{
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
% 长时间范围内平滑后的趋势(多项式拟合)
    
    figure;
    plot(f1(:),target_test(:),'.',[0,max(f1(:))],[0,0],'--');
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

%% 特征工程 训练集
f_train=cell(0);
now=1;
% 最后len_train天的25个特征均值
for feature_id=[17,21,24,25]
    f_train{now,1}=squeeze(mean(item_data(x_idx_train,feature_id,:,1:top_k),1));
    now=now+1;
end
%
% 排名
for idx_info=1:4
    for feature_id=1:25
        temp=zeros(6,top_k);
        score=squeeze(mean(item_data(x_idx_train,feature_id,:,1:top_k),1));
        info=item_info(idx_info,1:top_k);
        for i1=1:max(info)
            ind=info==i1;
            temp2=zeros(6,sum(ind));
            for store_id=1:6
                [~,r]=sort(score(store_id,ind),2);
                temp2(store_id,r)=(1:length(r))/length(r);
            end
            temp(:,ind)=temp2;
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
% 商品上市时间
f_train{now,1}=repmat(x_idx_train(end)-begin_ds(1:top_k)',6,1);
now=now+1;
%}
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
for feature_id=[17,21,24,25]
    f_test{now,1}=squeeze(mean(item_data(x_idx_test,feature_id,:,1:top_k),1));
    now=now+1;
end
%
% 排名
for idx_info=1:4
    for feature_id=1:25
        temp=zeros(6,top_k);
        score=squeeze(mean(item_data(x_idx_test,feature_id,:,1:top_k),1));
        info=item_info(idx_info,1:top_k);
        for i1=1:max(info)
            ind=info==i1;
            temp2=zeros(6,sum(ind));
            for store_id=1:6
                [~,r]=sort(score(store_id,ind),2);
                temp2(store_id,r)=(1:length(r))/length(r);
            end
            temp(:,ind)=temp2;
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
% 商品上市时间
f_test{now,1}=repmat(x_idx_test(end)-begin_ds(1:top_k)',6,1);
now=now+1;
%}
% 合成特征矩阵和目标矩阵
feature_mat_test=zeros(6*top_k,size(f_test,1));
for i1=1:size(f_test,1)
    feature_mat_test(:,i1)=f_test{i1}(:);
end
target_mat_test=target_test(:,1:top_k);
target_mat_test=target_mat_test(:);
save('data/regression_input.mat','feature_mat_train','target_mat_train','feature_mat_test','target_mat_test');


