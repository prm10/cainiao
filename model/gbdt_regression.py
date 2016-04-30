# -*- coding: utf-8 -*-
__author__ = 'prm14'

import scipy.io as sio
import numpy
import xgboost as xgb

# data_name = ['col' + str(i+1) for i in range(32)]
# # 1:int, 4:int, 3:float ,8*3:float
# data_type = ['int' for i in range(5)] + ['float' for i in range(27)]

data_name = ['col' + str(i + 1) for i in range(81)]
# 50:int, 4:int, 3:float ,8*3:float
data_type = ['i' for i in range(50)] + ['int' for i in range(4)] + ['float' for i in range(27)]


def get_data_from_mat(online):
	if online:
		data = sio.loadmat('data/regression_input_online.mat')
	else:
		data = sio.loadmat('data/regression_input.mat')
	train_f = data['feature_mat_train']
	train_y = data['target_mat_train']
	test_f = data['feature_mat_test']
	test_y = data['target_mat_test']
	print(numpy.std(test_y))
	return xgb.DMatrix(train_f, label=train_y), \
	       xgb.DMatrix(test_f, label=test_y)


class ModelClass:
	def __init__(self,online):
		self.param = {
			'max_depth': 15,
			'eta': 0.1,
			# 'subsample': 1,
			'min_child_weight': 20,
			# 'colsample_bytree': 0.9,
			'silent': 1,
			'objective': 'reg:linear'}
		self.d_train, self.d_test = get_data_from_mat(online)
		self.eval_list = [(self.d_train, 'train'), (self.d_test, 'eval')]
		self.bst = xgb.Booster()

	def cv(self):
		result = xgb.cv(self.param, self.d_train, num_boost_round=10, nfold=3)

	def train(self):
		plst = self.param.items()
		num_round = 10
		self.bst = xgb.train(plst, self.d_train, num_round, self.eval_list)

	def predict(self):
		predict_train = self.bst.predict(self.d_train)
		predict_test = self.bst.predict(self.d_test)
		sio.savemat('data/predict_xgb.mat', {'predict_train': predict_train, 'predict_test': predict_test})

	def save_model(self):
		self.bst.save_model('model/xgb.model')

	def load_model(self):
		self.bst.load_model('model/xgb.model')

	def dump_model(self):
		self.bst.dump_model('model/xgb.txt', 'model/feature_map.txt')
