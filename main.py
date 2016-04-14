# -*- coding: utf-8 -*-
__author__ = 'prm14'

from pretreatment import encode
from pretreatment import data_loader

ec = encode.EncodeClass()
ec.encode()
ec.load_all()

data_loader.get_item_feature_mat(ec)
data_loader.get_item_store_feature_mat(ec)
data_loader.get_config_mat(ec)
