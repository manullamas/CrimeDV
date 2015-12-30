from flask import Flask
from flask import render_template
from bson import json_util
from bson.json_util import dumps

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




if __name__ == "__main__":
   app.run(host='0.0.0.0',port=5000,debug=True)

