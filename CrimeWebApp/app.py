from flask import Flask
from flask import render_template
from bson import json_util
from bson.json_util import dumps
from collections import defaultdict

import string
import csv
import json
import pymongo
from pymongo import MongoClient
import datetime
from datetime import timedelta
from bson.code import Code

FIELDS = {'Month': True, 'LSOA code': True, 'Crime type': True, '_id': False}
app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html")


@app.route("/mapStations")
def mapStations():
    return render_template("mapStations.html")


@app.route("/london/crimesPerAll")
def london_crimesPerAll():
 client = MongoClient('mongodb://mongodb-dse662l3.cloudapp.net:27017/')
 db = client.DSproject
 collection = db.londonCrime3

 pipeline1 = [ { "$match": { "Month" : { "$exists" : "true", "$ne" : "none"}, "LocalAuthority" : { "$exists" : "true" , "$ne" : "none"},"Reportedby" : { "$exists" : "true" , "$ne" : "none"}  , "Crimetype" : { "$exists" : "true" , "$ne" : "none"}} },
               {"$project" : {"Month" : 1, "LocalAuthority":1,"Crimetype":1 ,"Reportedby" : 1}},
               {"$group"   : {"_id" :  {"M": "$Month" ,"C":"$Crimetype", "L":"$LocalAuthority", "R":"$Reportedby" } , "n" : {"$sum" : 1}}}]
#	       {"$limit"   : 1000},
#               {"$project" : {"M" : 1, "L":1,"C":1,"n":1 }}]
#               {"$group"   : {"_id" :  "null"  ,"countos" : {"$sum" : 1}}} ]
 
 list  = collection.aggregate(pipeline1,allowDiskUse=True)
#for project in list:
# print project["countos"]
 client.close()

 json_projects = []
 for project in list:
  json_projects.append(project)
 json_projects = json.dumps(json_projects, default=json_util.default)
 return json_projects



@app.route("/london/crimesPerStations")
def london_crimesPerStations():
 client = MongoClient('mongodb://mongodb-dse662l3.cloudapp.net:27017/')
 db = client.DSproject
# collection1 = db.stationsCrime
 collection1 = db.stationsCrime3
 collection2 = db.londonCrime3

# pipeline1 = [ {"$project" : {"_id" : "$Station" , "lat" :"$Latitude", "lng" : "$Longitude","usage":1,"crimesNumb":"$Count.totals"}}]

 pipeline1 = [ {"$project" : {"_id" : "$Station" , "lat" :"$Latitude", "lng" : "$Longitude","usage":1,"crimesNumb":"$Crime Density Per Usage.totals"}}]
 

 listStations  = collection1.aggregate(pipeline1,allowDiskUse=True)

 #pipeline2 = [
  #             {"$group"   : {"_id" : "$Station" , "crimesNumb" : {"$sum" : 1}}}]

 #listNumbCrimesPerStations  = collection2.aggregate(pipeline2,allowDiskUse=True)

 client.close()

 json_stations = []

# l1 = listStations
# l2 = listNumbCrimesPerStations

# d = defaultdict(dict)
# for l in (l1, l2):
  #   for elem in l:
 #        d[elem['_id']].update(elem)
# l3 = d.values()




# a = ["first" :"one", "second":"two", "third":"tree"]
# b = ["first":"one","second":"two"]
 
# for x in a:
#  print '-----'+ x[] +'--------'
#  for y in b:
#   print '--' + y
# for station in listStations:
 #  print '----------------- '+ station["Station"] +  '------------------'
  # bb = station["Station"]
  # aa = (item for item in listNumbCrimesPerStations if item["_id"]["S"] == bb ).next() 


 for station in listStations:
  json_stations.append(station)
 json_stations = json.dumps(json_stations, default=json_util.default)
 return json_stations



if __name__ == "__main__":
   app.run(host='0.0.0.0',port=5000,debug=True)

