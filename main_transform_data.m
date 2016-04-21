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
%% transform
item_info=zeros(4,1000);% cate_id,cate_level_id,brand_id,supplier_id
item_data=zeros(444,25,6,1000);% ds,feature,store_id+1,item_id
for i1=1:size(item_feature,1)
    info=item_feature(i1,:);
    ds=info(1);
    item_id=info(2);
    item_info(:,item_id)=info(3:6);
    item_data(ds,:,1,item_id)=info(7:31);
end
for i1=1:size(item_store_feature,1)
    info=item_store_feature(i1,:);
    ds=info(1);
    item_id=info(2);
    store_id=info(3);
    item_data(ds,:,store_id+1,item_id)=info(8:32);
end
save('data/cainiao.mat','item_info','item_data','config_a','config_b');
