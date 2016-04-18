# -*- coding: utf-8 -*-
__author__ = 'prm14'

import scipy.io as sio
from pretreatment import encode
import csv


# 将matlab的预测结果转换为相应序号的csv
def mat2csv(ec):
	csv_file = file('data/predict.csv', 'wb')
	writer = csv.writer(csv_file)
	# ec = encode.EncodeClass()
	# ec.load_all()
	# 预测结果：1000*6的矩阵
	predict = sio.loadmat('data/predict.mat')['predict']
	result = []
	for i1 in range(1000):
		item_id = ec.item_list[i1]
		# 全国
		value = predict[i1, 0]
		result1 = (item_id, 'all', value)
		result.append(result1)
		# 分仓
		for i2 in range(5):
			store_id = ec.store_list[i2]
			value = predict[i1, i2 + 1]
			result1 = (item_id, store_id, value)
			result.append(result1)
	writer.writerows(result)
	csv_file.close()
	print('save prediction to the predict.csv')
