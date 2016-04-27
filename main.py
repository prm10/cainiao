# -*- coding: utf-8 -*-
__author__ = 'prm14'

from pretreatment import encode
from pretreatment import data_loader
from give_result import generateResult

ec = encode.EncodeClass()
# ec.encode()
ec.load_all()

# 生成mat文件
# data_loader.get_item_feature_mat(ec)
# data_loader.get_item_store_feature_mat(ec)
# data_loader.get_config_mat(ec)

#查看日期序号
# data_loader.date_idx('20151111')+1
generateResult.mat2csv(ec)
