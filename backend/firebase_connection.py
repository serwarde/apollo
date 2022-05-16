import firebase_admin
import pyrebase
import json
from firebase_admin import credentials, auth

# Firebase Admin Connection
# Please update fbadmin.json with your credentials
cred = credentials.Certificate('fbadmin.json')
firebase = firebase_admin.initialize_app(cred)
pb = pyrebase.initialize_app(json.load(open('fbconfig.json')))


db = pb.database()