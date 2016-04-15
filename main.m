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
%
s=sum(item_dt_target(:,:,1),2);
figure;
plot(s);
all_vs_branch=sum(sum((item_dt_target(:,:,1)-sum(item_dt_target(:,:,2:end),3)).^2));
figure;
plot(item_dt_target(7,:,1));
%}
%% body
train_x_idx=1:399;
train_y_idx=400:413;
test_x_idx=32:430;
test_y_idx=431:444;

train_y=squeeze(sum(item_dt_target(:,train_y,:),2));
test_y=squeeze(sum(item_dt_target(:,test_y_idx,:),2));

