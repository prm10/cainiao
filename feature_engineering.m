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
% first time
begin_ds=zeros(1000,1);
for i1=1:1000
    begin_ds(i1,1)=find(target_flow(:,1,i1)>0,1);
end
% rank on time
rank_data=zeros(size(item_data));
for item_id=1:1000
    for store_id=1:6
        for feature_id=1:25
            [~,index]=sort(item_data(begin_ds(item_id):end,feature_id,store_id,item_id));
            rank_data(begin_ds(item_id)-1+index,feature_id,store_id,item_id)=(1:length(index))/length(index);
        end
    end
end
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
target_train=target_train(:,1:top_k);
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
target_test=target_test(:,1:top_k);
%% �������� ѵ����
% for idx_f=1:25
    f_train=repmat(x_idx_train(end)-begin_ds(1:top_k)',6,1);
    f_test=repmat(x_idx_test(end)-begin_ds(1:top_k)',6,1);
    %% ���ֲ�
    figure;
    plot(f_train(:),target_train(:),'b.',f_test(:),target_test(:),'g.',[0,max(f_test(:))],[0,0],'r--');
    legend('train','test');
% end

% 4��ѵ���������7����Լ�����Ĺ�ϵ
% figure;
% plot(target_train(:),target_test(:),'.');