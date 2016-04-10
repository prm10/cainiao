create database cainiao;
---------------------------------------------
---------------------------------------------
create table item_feature(
	ds	text	comment '日期',
	item_id	text	comment '商品ID',
	cate_id	text	comment '叶子类目ID',
	cate_level_id	text	comment '大类目ID',
	brand_id	text	comment '品牌ID',
	supplier_id	text	comment '供应商ID',
	pv_ipv	double	comment '浏览次数',
	pv_uv	double	comment '流量UV',
	cart_ipv	double	comment '被加购次数',
	cart_uv	double	comment '加购人次',
	collect_uv	double	comment '收藏夹人次',
	num_gmv	double	comment '拍下笔数',
	amt_gmv	double	comment '拍下金额',
	qty_gmv	double	comment '拍下件数',
	unum_gmv	double	comment '拍下UV',
	amt_alipay	double	comment '成交金额',
	num_alipay	double	comment '成交笔数',
	qty_alipay	double	comment '成交件数',
	unum_alipay	double	comment '成交人次',
	ztc_pv_ipv	double	comment '直通车引导浏览次数',
	tbk_pv_ipv	double	comment '淘宝客引导浏览次数',
	ss_pv_ipv	double	comment '搜索引导浏览次数',
	jhs_pv_ipv	double	comment '聚划算引导浏览次数',
	ztc_pv_uv	double	comment '直通车引导浏览人次',
	tbk_pv_uv	double	comment '淘宝客引导浏览人次',
	ss_pv_uv	double	comment '搜索引导浏览人次',
	jhs_pv_uv	double	comment '聚划算引导浏览人次',
	num_alipay_njhs	double	comment '非聚划算支付笔数',
	amt_alipay_njhs	double	comment '非聚划算支付金额',
	qty_alipay_njhs	double	comment '非聚划算支付件数',
	unum_alipay_njhs	double	comment '非聚划算支付人次'
)DEFAULT CHARSET=utf8;

create table item_store_feature(
	ds	text	comment '日期',
	item_id	text	comment '商品ID',
	store_code	text	comment '仓库CODE',
	cate_id	text	comment '叶子类目ID',
	cate_level_id	text	comment '大类目ID',
	brand_id	text	comment '品牌ID',
	supplier_id	text	comment '供应商ID',
	pv_ipv	double	comment '浏览次数',
	pv_uv	double	comment '流量UV',
	cart_ipv	double	comment '被加购次数',
	cart_uv	double	comment '加购人次',
	collect_uv	double	comment '收藏夹人次',
	num_gmv	double	comment '拍下笔数',
	amt_gmv	double	comment '拍下金额',
	qty_gmv	double	comment '拍下件数',
	unum_gmv	double	comment '拍下UV',
	amt_alipay	double	comment '成交金额',
	num_alipay	double	comment '成交笔数',
	qty_alipay	double	comment '成交件数',
	unum_alipay	double	comment '成交人次',
	ztc_pv_ipv	double	comment '直通车引导浏览次数',
	tbk_pv_ipv	double	comment '淘宝客引导浏览次数',
	ss_pv_ipv	double	comment '搜索引导浏览次数',
	jhs_pv_ipv	double	comment '聚划算引导浏览次数',
	ztc_pv_uv	double	comment '直通车引导浏览人次',
	tbk_pv_uv	double	comment '淘宝客引导浏览人次',
	ss_pv_uv	double	comment '搜索引导浏览人次',
	jhs_pv_uv	double	comment '聚划算引导浏览人次',
	num_alipay_njhs	double	comment '非聚划算支付笔数',
	amt_alipay_njhs	double	comment '非聚划算支付金额',
	qty_alipay_njhs	double	comment '非聚划算支付件数',
	unum_alipay_njhs	double	comment '非聚划算支付人次'
)DEFAULT CHARSET=utf8;


create table config(
	item_id	text	comment '商品ID',
	store_code	text	comment '仓库CODE, 注意如果是全国成本，这一列是all',
	a_b	text	comment '商品补少补多cost，用"_"联接起来。前一个数是补少的成本，后一个是补多的成本'
)DEFAULT CHARSET=utf8;
---------------------------------------------
---------------------------------------------
--import data
load data local infile 'E:/github/cainiao/data/item_feature1.csv' into table item_feature fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
(ds,item_id,cate_id,cate_level_id,brand_id,supplier_id,pv_ipv,pv_uv,cart_ipv,cart_uv,collect_uv,num_gmv,amt_gmv,qty_gmv,unum_gmv,amt_alipay,num_alipay,qty_alipay,unum_alipay,ztc_pv_ipv,tbk_pv_ipv,ss_pv_ipv,jhs_pv_ipv,ztc_pv_uv,tbk_pv_uv,ss_pv_uv,jhs_pv_uv,num_alipay_njhs,amt_alipay_njhs,qty_alipay_njhs,unum_alipay_njhs)
;

load data local infile 'E:/github/cainiao/data/item_store_feature1.csv' into table item_store_feature fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
(ds,item_id,store_code,cate_id,cate_level_id,brand_id,supplier_id,pv_ipv,pv_uv,cart_ipv,cart_uv,collect_uv,num_gmv,amt_gmv,qty_gmv,unum_gmv,amt_alipay,num_alipay,qty_alipay,unum_alipay,ztc_pv_ipv,tbk_pv_ipv,ss_pv_ipv,jhs_pv_ipv,ztc_pv_uv,tbk_pv_uv,ss_pv_uv,jhs_pv_uv,num_alipay_njhs,amt_alipay_njhs,qty_alipay_njhs,unum_alipay_njhs)
;

load data local infile 'E:/github/cainiao/data/config1.csv' into table config fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
(item_id,store_code,a_b)
;

--result 
item_feature	232621			item_store_feature	960122			config	6000
--查看comment
show full columns from item_feature
---------------------------------------------
---------------------------------------------


