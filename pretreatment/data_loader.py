# -*- coding: utf-8 -*-
__author__ = 'prm14'

import csv
import datetime
import numpy
import scipy.io as sio


def date_diff(str1, str2):
    date1 = datetime.datetime.strptime(str1, "%Y%m%d")
    date2 = datetime.datetime.strptime(str2, "%Y%m%d")
    return (date1 - date2).days


def user_info_loader():
    reader = csv.reader(open("data/mars_tianchi_user_actions.csv"))
    for user_id, song_id, gmt_create, action_type, ds in reader:
        x = (user_id, song_id, gmt_create, action_type, ds)
        print(x)
        break


def show_result(result):
    for (artist, ds_num) in result.items():
        ds_num = sorted(ds_num.iteritems(), key=lambda d: d[0])
        for ds, num in ds_num:
            print artist, '\t', ds, '\t', num


def get_song_publish_time(song_id0):
    reader = csv.reader(open("data/mars_tianchi_songs.csv"))
    for song_id, artist_id, publish_time, song_init_plays, Language, Gender in reader:
        if song_id0 == song_id:
            return publish_time
    return None


def load_mat(filename):
    return sio.loadmat('data/' + filename + '.mat')


def song_heard(song_dict):
    # 统计歌曲次数：歌曲序号、时间序号、行为种类
    song_times = numpy.zeros([len(song_dict), date_diff('20150831', '20150301'), 3], numpy.uint16)
    reader = csv.reader(open("data/mars_tianchi_user_actions.csv"))
    for user_id, song_id, gmt_create, action_type, ds in reader:
        # if action_type == '1' and '20150301' <= ds < '20150701':
        song_times[song_dict[song_id], date_diff(ds, '20150301'), int(action_type) - 1] += 1
    sio.savemat('data/song_times.mat', {'song_times': song_times})


class SongClass:
    def __init__(self):
        self.song_artist_dict = {}
        self.artist_song_dict = {}
        self.song_info_loader()

    def song_info_loader(self):
        reader = csv.reader(open("data/mars_tianchi_songs.csv"))
        for song_id, artist_id, publish_time, song_init_plays, language, gender in reader:
            self.song_artist_dict.setdefault(song_id, set()).add(artist_id)
            self.artist_song_dict.setdefault(artist_id, set()).add(song_id)
        print len(self.artist_song_dict), ' artists recorded'
        print len(self.song_artist_dict), ' songs recorded'


class UserClass:
    def __init__(self):
        self.val_result = {}
        self.song_list = []
        self.song_dict = {}
        self.artist_list = []
        self.artist_dict = {}

    def get_validation(self, sad):
        reader = csv.reader(open("data/mars_tianchi_user_actions.csv"))
        for user_id, song_id, gmt_create, action_type, ds in reader:
            if action_type == '1' and '20150701' <= ds < '20150901':
                artists = sad[song_id]
                for artist in artists:
                    self.val_result.setdefault(artist, {}).setdefault(ds, 0)
                    self.val_result[artist][ds] += 1
        print 'records of %d artists of validation has generated.' % len(self.val_result)

    def artist_heard(self, sad, asd):
        self.artist_list = asd.keys()
        self.artist_dict = dict.fromkeys(self.artist_list, 0)
        i = 0
        for artist_id in self.artist_list:
            self.artist_dict[artist_id] = i
            i += 1

        artist_times = numpy.zeros([len(self.artist_dict), date_diff('20150701', '20150301')], numpy.uint16)
        reader = csv.reader(open("data/mars_tianchi_user_actions.csv"))
        for user_id, song_id, gmt_create, action_type, ds in reader:
            if action_type == '1' and '20150301' <= ds < '20150701':
                for artist_id in sad[song_id]:
                    artist_times[self.artist_dict[artist_id], date_diff(ds, '20150301')] += 1
        sio.savemat('data/artist_times.mat', {'artist_times': artist_times})
