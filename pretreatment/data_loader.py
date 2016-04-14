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


class ItemClass:
	def __init__(self):
		self.song_artist_dict = {}
		self.artist_song_dict = {}
		self.info_loader()

	def info_loader(self):
		ec = encode.EncodeClass()
		ec.load_all()
		data0=numpy.zeros([len(ec.item_list),date_idx('20151227')],dtype=numpy.int64)
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
