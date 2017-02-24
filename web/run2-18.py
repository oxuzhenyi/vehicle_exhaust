# coding:utf-8

import sys
reload(sys)
sys.setdefaultencoding( "utf-8" )
from flask import *
import datetime
import MySQLdb
import MySQLdb.cursors
import warnings
warnings.filterwarnings("ignore")
from config import *
import pprint

app = Flask(__name__)
app.config.from_object(__name__)

def connectdb():
	db = MySQLdb.connect(host=HOST, user=USER, passwd=PASSWORD, db=DATABASE, port=PORT, charset=CHARSET, cursorclass = MySQLdb.cursors.DictCursor)
	db.autocommit(True)
	cursor = db.cursor()
	return (db,cursor)

# 关闭数据库
def closedb(db,cursor):
	db.close()
	cursor.close()

@app.route('/')#对应index.html
def index():
	return render_template('index.html')

@app.route('/dongtai')#对应dongtai.html
def dongtai():
	(db,cursor) = connectdb()
	cursor.execute("select rate, district, category, showtime, length from movie")
	movies = cursor.fetchall()
	temp = []
	for item in movies:
		if not item['showtime'] == 0 and not item['length'] == 0:
			temp.append(item)
	movies = temp
	movies = json.dumps({"movies": movies})
	cursor.execute("select * from rate")
	rates = cursor.fetchall()
	temp = {}
	for item in rates:
		temp[item['name']] = {}
		temp[item['name']]['categories'] = item['categories'].split(',')
		temp[item['name']]['rates'] = item['rates'].split(',')
		array = []
		for i in temp[item['name']]['rates']:
			array.append(float(i))
		temp[item['name']]['rates'] = array
	rates = temp
	pprint.pprint(rates)
	rates = json.dumps({"rates": rates})
	closedb(db,cursor)
	categories = ['剧情','喜剧','惊悚','爱情','动作','悬疑','犯罪','恐怖','科幻','冒险','奇幻','家庭','动画','战争','历史','古装','传记','音乐','同性','武侠','情色','灾难','运动','歌舞','西部','儿童','黑色电影','鬼怪','荒诞']
	districts = ['United States of America','China','Japan','South Korea','United Kingdom','France','Germany','Canada','Italy','Australia','Spain','Thailand','Russia','Belgium','Sweden','Ireland','Czech Republic','Denmark','India','Poland','Switzerland','New Zealand','Austria','Norway','Netherlands','Brazil','Hungary','Slovakia','Mexico','Iran','South Africa','Finland','Turkey','Romania','Luxembourg','Argentina','Iceland','Indonesia','Israel','United Arab Emirates','Malaysia','Georgia','Cuba','Kazakhstan','Estonia','Vietnam','Greece','Lithuania','Chile','Ukraine','Portugal','Bulgaria','Botswana','The Bahamas','Uzbekistan','Algeria','Puerto Rico','Philippines','Mauritania','Morocco','Latvia','Egypt','Myanmar','Tunisia','Peru','Colombia','Tajikistan']
	return render_template('dongtai.html',movies=movies,categories=categories,districts=districts,rates=rates)#尾气动态监控加上地点可选
	
@app.route('/PM25')#对应PM25.html
def PM25():
	return render_template('PM25.html')
	
@app.route('/rate')#对应rate.html
def rate():
	(db,cursor) = connectdb()
	cursor.execute("select rate, district, category, showtime, length from movie")
	movies = cursor.fetchall()
	temp = []
	for item in movies:
		if not item['showtime'] == 0 and not item['length'] == 0:
			temp.append(item)
	movies = temp
	movies = json.dumps({"movies": movies})
	cursor.execute("select * from rate")
	rates = cursor.fetchall()
	temp = {}
	for item in rates:
		temp[item['name']] = {}
		temp[item['name']]['categories'] = item['categories'].split(',')
		temp[item['name']]['rates'] = item['rates'].split(',')
		array = []
		for i in temp[item['name']]['rates']:
			array.append(float(i))
		temp[item['name']]['rates'] = array
	rates = temp
	pprint.pprint(rates)
	rates = json.dumps({"rates": rates})
	closedb(db,cursor)
	categories = ['剧情','喜剧','惊悚','爱情','动作','悬疑','犯罪','恐怖','科幻','冒险','奇幻','家庭','动画','战争','历史','古装','传记','音乐','同性','武侠','情色','灾难','运动','歌舞','西部','儿童','黑色电影','鬼怪','荒诞']
	districts = ['United States of America','China','Japan','South Korea','United Kingdom','France','Germany','Canada','Italy','Australia','Spain','Thailand','Russia','Belgium','Sweden','Ireland','Czech Republic','Denmark','India','Poland','Switzerland','New Zealand','Austria','Norway','Netherlands','Brazil','Hungary','Slovakia','Mexico','Iran','South Africa','Finland','Turkey','Romania','Luxembourg','Argentina','Iceland','Indonesia','Israel','United Arab Emirates','Malaysia','Georgia','Cuba','Kazakhstan','Estonia','Vietnam','Greece','Lithuania','Chile','Ukraine','Portugal','Bulgaria','Botswana','The Bahamas','Uzbekistan','Algeria','Puerto Rico','Philippines','Mauritania','Morocco','Latvia','Egypt','Myanmar','Tunisia','Peru','Colombia','Tajikistan']
	return render_template('rate.html',movies=movies,categories=categories,districts=districts,rates=rates)


    
@app.route('/map')#对应map.html
def map():
	return render_template('map.html')

@app.route('/mapmark')#对应mapmark.html
def mapmark():
	return render_template('mapmark.html')

@app.route('/login')#对应login.html
def login():
	(db,cursor) = connectdb()
	cursor.execute("select * from movie order by rate desc limit 10")
	movies = cursor.fetchall()
	closedb(db,cursor)
	return render_template('login.html',posts=movies)

@app.route('/logout')#对应logout.html
def logout():
	(db,cursor) = connectdb()
	cursor.execute("select * from movie order by rate desc limit 10")
	movies = cursor.fetchall()
	closedb(db,cursor)
	return render_template('logout.html',posts=movies)

@app.route('/pwd',methods=['POST'])#处理post请求
def pwd():
	data = request.form
	print 'pwd:',data['pwd'],'\nuser:',data['keyword']#获取用户名和密码
	(db,cursor) = connectdb()
	#print "select * from user where userID=%s and password =%s" % (data['keyword'],data['pwd'])
	#cursor.execute("select * from user where userID=%d"%(1))
	cursor.execute("select * from user where userID='%s' and password='%s'" %(data['keyword'],data['pwd']))#注意查询语句格式userID='%s' and password='%s'
	movies = cursor.fetchall()
	flag=len(movies)
	print '\n',flag,movies
	closedb(db,cursor)
	if flag==0:
		return json.dumps({"movies": movies})
	print 'rungere'
	return json.dumps({"movies": movies})


perpage=10
indexcur=1
flag0=0
totalpagenum=0
fuel=0#为0不加筛选条件
record=0#为0不加筛选条件
fueltype=['全部','汽油','柴油','天然气']
recordtype=['全部','合格','无效','超标']
timeq=0#为0不加时间筛选条件
date1='2017-1-1'
date2='2017-1-1'
@app.route('/search')#对应search.html
def search():
	(db,cursor) = connectdb()
	global indexcur
	global perpage
	global fuel,record,timeq,date1,date2
	global fueltype,recordtype
	global totalpagenum
	'''
	if fuel==0:
		cursor.execute("select count(*) from  analysis")
		totalpagenum=cursor.fetchall()[0]
		cursor.execute("select * from analysis order by ID limit %d,%d" %(indexcur-1,perpage))
	else:
		cursor.execute("select count(*) from  analysis where FuelType regexp '%s' and recordtype='%s'" % (fueltype[fuel],recordtype[record]))
		totalpagenum=cursor.fetchall()[0]
		cursor.execute("select * from analysis where FuelType regexp '%s' and recordtype='%s' order by ID limit %d,%d" %(fueltype[fuel],recordtype[record],indexcur-1,perpage))'''
	#选择条件判断
	if timeq==0:#未加时间筛选
		if fuel!=0 and record !=0:
			cursor.execute("select count(*) from  analysis where FuelType regexp '%s' and RecordStatus='%s'" % (fueltype[fuel],recordtype[record]))
			totalpagenum=cursor.fetchall()[0]
			cursor.execute("select * from analysis where FuelType regexp '%s' and RecordStatus='%s' order by ID limit %d,%d" %(fueltype[fuel],recordtype[record],indexcur-1,perpage))
		else:
			if fuel==0 and record ==0:
				cursor.execute("select count(*) from  analysis")
				totalpagenum=cursor.fetchall()[0]
				cursor.execute("select * from analysis order by ID limit %d,%d" %(indexcur-1,perpage))
			else:
				if record==0:
					cursor.execute("select count(*) from  analysis where FuelType regexp '%s'" % (fueltype[fuel]))
					totalpagenum=cursor.fetchall()[0]
					cursor.execute("select * from analysis where FuelType regexp '%s' order by ID limit %d,%d" %(fueltype[fuel],indexcur-1,perpage))
				else:
					cursor.execute("select count(*) from  analysis where RecordStatus='%s'" % (recordtype[record]))
					totalpagenum=cursor.fetchall()[0]
					cursor.execute("select * from analysis where RecordStatus='%s' order by ID limit %d,%d" %(recordtype[record],indexcur-1,perpage))
	else:#加时间筛选
		if fuel!=0 and record !=0:
			cursor.execute("select count(*) from  analysis where PassTime BETWEEN '%s' AND '%s' and FuelType regexp '%s' and RecordStatus='%s'" % (date1,date2,fueltype[fuel],recordtype[record]))
			totalpagenum=cursor.fetchall()[0]
			cursor.execute("select * from analysis where PassTime BETWEEN '%s' AND '%s' and FuelType regexp '%s' and RecordStatus='%s' order by ID limit %d,%d" %(date1,date2,fueltype[fuel],recordtype[record],indexcur-1,perpage))
		else:
			if fuel==0 and record ==0:
				cursor.execute("select count(*) from  analysis where PassTime BETWEEN '%s' AND '%s'" % (date1,date2))
				totalpagenum=cursor.fetchall()[0]
				cursor.execute("select * from analysis where PassTime BETWEEN '%s' AND '%s' order by ID limit %d,%d" %(date1,date2,indexcur-1,perpage))
			else:
				if record==0:
					cursor.execute("select count(*) from  analysis where PassTime BETWEEN '%s' AND '%s' and FuelType regexp '%s'" % (date1,date2,fueltype[fuel]))
					totalpagenum=cursor.fetchall()[0]
					cursor.execute("select * from analysis where PassTime BETWEEN '%s' AND '%s' and FuelType regexp '%s' order by ID limit %d,%d" %(date1,date2,fueltype[fuel],indexcur-1,perpage))
				else:
					cursor.execute("select count(*) from  analysis where PassTime BETWEEN '%s' AND '%s' and RecordStatus='%s'" % (date1,date2,recordtype[record]))
					totalpagenum=cursor.fetchall()[0]
					cursor.execute("select * from analysis where PassTime BETWEEN '%s' AND '%s' and RecordStatus='%s' order by ID limit %d,%d" %(date1,date2,recordtype[record],indexcur-1,perpage))
	movies = cursor.fetchall()
	closedb(db,cursor)
	print 'search-fuel=',fuel,"search-record",record,"search-date1",date1,"search-date2",date2
	#print date1.split('-')
	y1,m1,d1=date1.split('-')
	y2,m2,d2=date2.split('-')
	return render_template('search.html',movies=movies,Fuel=fuel,Record=record,Timeq=timeq,y1=y1,m1=m1,d1=d1,y2=y2,m2=m2,d2=d2,Recordnum=totalpagenum)#totalpagenum在页面中调用形式'''{{Recordnum['count(*)']}}'''

@app.route('/query1',methods=['POST'])#处理post请求
def query1():
	index = request.form
	print 'index=',index
	(db,cursor) = connectdb()
	global perpage
	global totalpagenum
	global indexcur
	global perpage
	global flag0
	global fuel,record,timeq,date1,date2
	global fueltype,recordtype
	fuel=int(index['fuel'])
	record=int(index['record'])
	timeq=int(index['timeq'])
	date1=str(index['date1'])
	date2=str(index['date2'])
	'''
	if fuel==0 or flag0==0:
		cursor.execute("select count(*) from  analysis")
		totalpagenum=cursor.fetchall()[0]
		flag0=1
	else:
		cursor.execute("select count(*) from  analysis where FuelType regexp '%s'" % fueltype[fuel])
		totalpagenum=cursor.fetchall()[0]'''


	'''
	if fuel==0:
		cursor.execute("select * from analysis order by ID limit %d,%d" %(indexcur-1,perpage))
	else:
		cursor.execute("select * from analysis where FuelType regexp '%s' order by ID limit %d,%d" %(fueltype[fuel],indexcur-1,perpage))'''
	if timeq==0:#未加时间筛选
		if fuel!=0 and record !=0:
			cursor.execute("select count(*) from  analysis where FuelType regexp '%s' and RecordStatus='%s'" % (fueltype[fuel],recordtype[record]))
			totalpagenum=cursor.fetchall()[0]
			cursor.execute("select * from analysis where FuelType regexp '%s' and RecordStatus='%s' order by ID limit %d,%d" %(fueltype[fuel],recordtype[record],indexcur-1,perpage))
		else:
			if fuel==0 and record ==0:
				cursor.execute("select count(*) from  analysis")
				totalpagenum=cursor.fetchall()[0]
				cursor.execute("select * from analysis order by ID limit %d,%d" %(indexcur-1,perpage))
			else:
				if record==0:
					cursor.execute("select count(*) from  analysis where FuelType regexp '%s'" % (fueltype[fuel]))
					totalpagenum=cursor.fetchall()[0]
					cursor.execute("select * from analysis where FuelType regexp '%s' order by ID limit %d,%d" %(fueltype[fuel],indexcur-1,perpage))
				else:
					cursor.execute("select count(*) from  analysis where RecordStatus='%s'" % (recordtype[record]))
					totalpagenum=cursor.fetchall()[0]
					cursor.execute("select * from analysis where RecordStatus='%s' order by ID limit %d,%d" %(recordtype[record],indexcur-1,perpage))
	else:#加时间筛选
		if fuel!=0 and record !=0:
			cursor.execute("select count(*) from  analysis where PassTime BETWEEN '%s' AND '%s' and FuelType regexp '%s' and RecordStatus='%s'" % (date1,date2,fueltype[fuel],recordtype[record]))
			totalpagenum=cursor.fetchall()[0]
			cursor.execute("select * from analysis where PassTime BETWEEN '%s' AND '%s' and FuelType regexp '%s' and RecordStatus='%s' order by ID limit %d,%d" %(date1,date2,fueltype[fuel],recordtype[record],indexcur-1,perpage))
		else:
			if fuel==0 and record ==0:
				cursor.execute("select count(*) from  analysis where PassTime BETWEEN '%s' AND '%s'" % (date1,date2))
				totalpagenum=cursor.fetchall()[0]
				cursor.execute("select * from analysis where PassTime BETWEEN '%s' AND '%s' order by ID limit %d,%d" %(date1,date2,indexcur-1,perpage))
			else:
				if record==0:
					cursor.execute("select count(*) from  analysis where PassTime BETWEEN '%s' AND '%s' and FuelType regexp '%s'" % (date1,date2,fueltype[fuel]))
					totalpagenum=cursor.fetchall()[0]
					cursor.execute("select * from analysis where PassTime BETWEEN '%s' AND '%s' and FuelType regexp '%s' order by ID limit %d,%d" %(date1,date2,fueltype[fuel],indexcur-1,perpage))
				else:
					cursor.execute("select count(*) from  analysis where PassTime BETWEEN '%s' AND '%s' and RecordStatus='%s'" % (date1,date2,recordtype[record]))
					totalpagenum=cursor.fetchall()[0]
					cursor.execute("select * from analysis where PassTime BETWEEN '%s' AND '%s' and RecordStatus='%s' order by ID limit %d,%d" %(date1,date2,recordtype[record],indexcur-1,perpage))
	print 'query-fuel=',fuel,"query-record",record,"totalpagenum",totalpagenum,"query-date1",date1,"query-date2",date2

	if int(index['index'])==0:
		indexcur=0
	indexcur=perpage*int(index['index'])+indexcur
	if indexcur+perpage-1>totalpagenum:
		indexcur=totalpagenum-9
	if indexcur<1:
		indexcur=1
	
	print 'indexcur=',indexcur
	print ' totalpagenum=',totalpagenum
	movies = cursor.fetchall()
	closedb(db,cursor)
	#return render_template('list.html',movies=movies)
	return json.dumps({"movies": movies})
	
@app.route('/list')#对应list.html
def list():
	(db,cursor) = connectdb()
	global indexcur
	global perpage
	global fuel
	if fuel==0:
		cursor.execute("select * from movie order by id limit %d,%d" %(indexcur-1,perpage))
	else:
		cursor.execute("select * from movie where showtime = %d order by id limit %d,%d" %(fuel,indexcur-1,perpage))
	movies = cursor.fetchall()
	closedb(db,cursor)
	print 'list-fuel=',fuel
	return render_template('list.html',movies=movies,Fuel=fuel)#
	#return json.dumps({"movies": movies})

@app.route('/query',methods=['POST'])#处理post请求
def query():
	index = request.form
	print 'index=',index
	(db,cursor) = connectdb()
	global indexcur
	global perpage
	global totalpagenum
	global indexcur
	global perpage
	global flag0
	global fuel
	fuel=int(index['fuel'])
	print 'query-fuel=',fuel
	if flag0==0:
		cursor.execute("select count(*) from  movie")
		totalpagenum=cursor.fetchall()[0]
		flag0=1
	indexcur=perpage*int(index['index'])+indexcur
	if indexcur+perpage-1>totalpagenum:
		indexcur=totalpagenum-9
	if indexcur<1:
		indexcur=1
	
	print 'indexcur=',indexcur
	print ' totalpagenum=',totalpagenum
	if fuel==0:
		cursor.execute("select * from movie order by id limit %d,%d" %(indexcur-1,perpage))
	else:
		cursor.execute("select * from movie where showtime = %d order by id limit %d,%d" %(fuel,indexcur-1,perpage))
	movies = cursor.fetchall()
	closedb(db,cursor)
	#return render_template('list.html',movies=movies)
	return json.dumps({"movies": movies})

@app.route('/keyword',methods=['POST'])#处理post请求
def keyword():
	data = request.form
	print data['keyword']
	(db,cursor) = connectdb()
	cursor.execute("select * from movie where title like '%%%s%%' order by rate desc" % (data['keyword']))
	movies = cursor.fetchall()
	for item in movies:
		item['description'] = item['description'].split('/')
		item['composer'] = item['composer'].replace('/',' ')
		item['actor'] = item['actor'].replace('/',' ')
		item['category'] = item['category'].replace('/',' ')
		item['district'] = item['district'].split('/')
		temp = ''
		for d in item['district']:
			temp = temp + d.split('_')[1] + ' '
		item['district'] = temp[:-1]
		item['language'] = item['language'].replace('/',' ')
		item['othername'] = item['othername'].replace('/',' ')
	closedb(db,cursor)
	return json.dumps({"movies": movies})

if __name__ == '__main__':
	app.run(host='0.0.0.0',debug=True)