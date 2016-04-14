# -*- coding: utf-8 -*-
__author__ = 'prm14'

import csv
import datetime
import numpy
import scipy.io as sio
from pretreatment import encode


def date_idx(str1):
	date1 = datetime.datetime.strptime(str1, "%Y%m%d")
	date2 = datetime.datetime.strptime('20141010', "%Y%m%d")
	return (date1 - date2).days


def get_config_mat(ec):
	config = numpy.zeros([6000, 4], dtype=numpy.double)
	reader = csv.reader(open("data/config1.csv"))
	i = 0
	for item_id, store_code, a_b in reader:  # 0~30: 0~5 and 6~30
		config[i, 0] = ec.item_dict[item_id] + 1
		if store_code == 'all':
			config[i, 1] = 0
		else:
			config[i, 1] = ec.store_dict[store_code] + 1
		cost = a_b.split("_")
		config[i, 2] = float(cost[0])
		config[i, 3] = float(cost[1])
		i += 1
	sio.savemat('data/config.mat', {'config': config})
	print('save config done.')


def get_item_feature_mat(ec):
	item_feature = numpy.zeros([230355, 31], dtype=numpy.double)
	reader = csv.reader(open("data/item_feature1.csv"))
	i = 0
	for record in reader:  # 0~30: 0~5 and 6~30
		item_feature[i, 0] = date_idx(record[0]) + 1
		item_feature[i, 1] = ec.item_dict[record[1]] + 1
		item_feature[i, 2] = ec.cate_dict[record[2]] + 1
		item_feature[i, 3] = ec.cate1_dict[record[3]] + 1
		item_feature[i, 4] = ec.brand_dict[record[4]] + 1
		item_feature[i, 5] = ec.supplier_dict[record[5]] + 1
		item_feature[i, 6:31] = numpy.array(map(float, record[6:31]))
		i += 1
	sio.savemat('data/item_feature.mat', {'item_feature': item_feature})
	print('save item_feature done.')


def get_item_store_feature_mat(ec):
	item_store_feature = numpy.zeros([950120, 32], dtype=numpy.double)
	reader = csv.reader(open("data/item_store_feature1.csv"))
	i = 0
	for record in reader:  # 0~31: 0~6 and 7~31
		item_store_feature[i, 0] = date_idx(record[0]) + 1
		item_store_feature[i, 1] = ec.item_dict[record[1]] + 1
		item_store_feature[i, 2] = ec.store_dict[record[2]] + 1
		item_store_feature[i, 3] = ec.cate_dict[record[3]] + 1
		item_store_feature[i, 4] = ec.cate1_dict[record[4]] + 1
		item_store_feature[i, 5] = ec.brand_dict[record[5]] + 1
		item_store_feature[i, 6] = ec.supplier_dict[record[6]] + 1
		item_store_feature[i, 7:32] = numpy.array(map(float, record[7:32]))
		i += 1
	sio.savemat('data/item_store_feature.mat', {'item_store_feature': item_store_feature})
	print('save item_store_feature done.')


class ItemClass:
	def __init__(self):
		self.song_artist_dict = {}
		self.artist_song_dict = {}
		self.info_loader()

	def info_loader(self):
		ec = encode.EncodeClass()
		ec.load_all()
		data0 = numpy.zeros([], dtype=numpy.int64)
		reader = csv.reader(open("data/item_store_feature1.csv"))
		for record in reader:  # 0~31
			ds = date_idx(record[0])
			item_id = record[1]
			store_id = record[2]
			cate_id = record[3]
			cate1_id = record[4]
			brand_id = record[5]
			supplier_id = record[6]
			v = float(record[7:32])  # 7~31->0~24
		print len(self.artist_song_dict), ' artists recorded'
		print len(self.song_artist_dict), ' songs recorded'
