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
%% ���ֲ�
%{
for idx_f=1:25
%���7���ĳһ�����ܺ�
%     f1=squeeze(mean(x_test(end-len+1:end,idx_f,:,1:top_k),1));
%ĳһ�����ܺ�
%     f1=squeeze(sum(x_test(:,idx_f,:,1:top_k),1));
%���7��Ķ���ʽ���ϵ��
%     f1=zeros(6,top_k);
%     for store_id=1:6
%         for item_id=1:top_k
%             x=x_test(end-len+1:end,idx_f,store_id,item_id);%/scale_base(store_id,item_id);
%             [p,S]=polyfit(1:length(x),x',1);
%             f1(store_id,item_id)=p(2);
%         end
%     end
%���7���ĳһ�������������ܵģ�
%     [~,f1]=sort(squeeze(mean(x_test(end-len+1:end,idx_f,:,1:top_k),1)),2,'descend');
%���7���ĳһ��������������Ŀ�ڵģ�
%     f1=zeros(6,top_k);
%     score=squeeze(mean(x_test(end,idx_f,:,1:top_k),1));
%     info=item_info(1,1:top_k);
%     for i1=1:max(info)
%         ind=info==i1;
%         [~,r]=sort(score(:,ind),2,'descend');
%         f1(:,ind)=r;
%     end
% ˫11˫12�������7��������ֵ�ı���
%     sum_recent=squeeze(mean(x_test(end-len+1:end,idx_f,:,1:top_k),1));
% %     shuang11=squeeze(item_data(398,idx_f,:,1:top_k));
% %     f1=shuang11./max(sum_recent,ones(size(sum_recent)));
%     shuang12=squeeze(item_data(429,idx_f,:,1:top_k));
%     f1=shuang12./max(sum_recent,ones(size(sum_recent)));
% ˫12֮ǰ�������7��������ֵ�ı���
%     sum_recent=squeeze(mean(x_test(end-len+1:end,idx_f,:,1:top_k),1));
%     sum_before=squeeze(mean(item_data(420:422,idx_f,:,1:top_k),1));
%     f1=sum_before./max(sum_recent,ones(size(sum_recent)));
% ��˫11֮��8~14������Ƴ̶�
%     sum_8=squeeze(mean(item_data(406:412,idx_f,:,1:top_k),1));
%     sum_1=squeeze(mean(item_data(399:405,idx_f,:,1:top_k),1));
%     f1=sum_8-sum_1;
% ��ʱ�䷶Χ��ƽ���������(����ʽ���)
    
    figure;
    plot(f1(:),target_test(:),'.',[0,max(f1(:))],[0,0],'--');
    title(num2str(idx_f));
    ylabel('target');xlabel('feature');
end
%}
%% �������ƺ������
%{
item_id=22;
store_id=1;
feature_id=2;
data=item_data(:,:,store_id,item_id);
figure;
subplot(211);
plot(1:444,data(:,end-1));title('Ŀ��24');
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
%% ����Ϊ14�ľ�ֵ����
%{
filter_window=7; %��λ���˲�����
item_id=3; %������
store_id=1; %�ֿ�
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

%% �������� ѵ����
f_train=cell(0);
now=1;
% ���len_train���25��������ֵ
for feature_id=[17,21,24,25]
    f_train{now,1}=squeeze(mean(item_data(x_idx_train,feature_id,:,1:top_k),1));
    now=now+1;
end
%
% ����
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
% ˫11˫12ռ��һ��������������
f_train{now,1}=(...
    squeeze(item_data(398,24,:,1:top_k))+...
    squeeze(item_data(429,24,:,1:top_k))...
    )./...
    squeeze(sum(item_data(380:max(x_idx_train),24,:,1:top_k),1));
now=now+1;
% item�Ļ�����Ϣ
for i1=1:4
    f_train{now,1}=repmat(item_info(i1,1:top_k),6,1);
	now=now+1;
end
% ��Ʒ����ʱ��
f_train{now,1}=repmat(x_idx_train(end)-begin_ds(1:top_k)',6,1);
now=now+1;
%}
% �ϳ����������Ŀ�����
feature_mat_train=zeros(6*top_k,size(f_train,1));
for i1=1:size(f_train,1)
    feature_mat_train(:,i1)=f_train{i1}(:);
end
target_mat_train=target_train(:,1:top_k);
target_mat_train=target_mat_train(:);
%% �������� ���Լ�
f_test=cell(0);
now=1;
% ���len_test���25��������ֵ
for feature_id=[17,21,24,25]
    f_test{now,1}=squeeze(mean(item_data(x_idx_test,feature_id,:,1:top_k),1));
    now=now+1;
end
%
% ����
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
% ˫11˫12ռ��һ��������������
f_test{now,1}=(...
    squeeze(item_data(398,24,:,1:top_k))+...
    squeeze(item_data(429,24,:,1:top_k))...
    )./...
    squeeze(sum(item_data(380:max(x_idx_test),24,:,1:top_k),1));
now=now+1;
% item�Ļ�����Ϣ
for i1=1:4
    f_test{now,1}=repmat(item_info(i1,1:top_k),6,1);
	now=now+1;
end
% ��Ʒ����ʱ��
f_test{now,1}=repmat(x_idx_test(end)-begin_ds(1:top_k)',6,1);
now=now+1;
%}
% �ϳ����������Ŀ�����
feature_mat_test=zeros(6*top_k,size(f_test,1));
for i1=1:size(f_test,1)
    feature_mat_test(:,i1)=f_test{i1}(:);
end
target_mat_test=target_test(:,1:top_k);
target_mat_test=target_mat_test(:);
save('data/regression_input.mat','feature_mat_train','target_mat_train','feature_mat_test','target_mat_test');


