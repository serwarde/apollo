import json
from flask import Flask, request, Response
from flask_cors import CORS
from functools import wraps
import os

import model.poll_lists
import model.notifications
import firebase_connection

app = Flask(__name__)
CORS(app)


def check_token(f):
    """
    Executed before requesting a route.
    Checks whether the authorization header is set to a valid firebase user id token
    """
    @wraps(f)
    def wrap(*args,**kwargs):
        if not request.headers.get('authorization'):
            return {'message': 'No token provided'},400
        try:
            user = firebase_connection.auth.verify_id_token(request.headers['authorization'])
            request.user = user
        except:
            return {'message':'Invalid token provided.'},400
        return f(*args, **kwargs)
    return wrap

@app.route('/api/token')
def token():
    """
    Return a jwt for a firebase user to grant him access to other routes of this API
    """
    email = request.form.get('email')
    password = request.form.get('password')
    try:
        print("getting token for " + str(email) + " with " + str(password))
        user = firebase_connection.pb.auth().sign_in_with_email_and_password(email, password)
        jwt = user['idToken']
        return {'token': jwt}, 200
    except Exception as e:
        print(e)
        return {'message': 'There was an error logging in'},400

#region poll lists

@app.route("/info")
def info():
    """
    A route to check whether the server is running and working
    """
    return "Awesome", 200

@app.route('/api/listPollsNearby')
@check_token
def listPollsNearby():
    return model.poll_lists.listPollsNearby(request.args.get('longitude', type=float), request.args.get('latitude', type=float)), 200

@app.route('/api/listPollsMap')
@check_token
def listPollsMap():
    return model.poll_lists.listPolls(), 200

#endregion

# @app.route("/notify")
# def notify():
#     model.notifications.notifyAllUsers("Test Notification", "a test", 37.56940129307669, -122.06898162225727, 50000)

#     return "Success", 200


if os.environ.get('WERKZEUG_RUN_MAIN') != 'true':
    # execute only once, not at reload
    model.notifications.initialize()

if __name__ == '__main__':
    app.debug = True
    app.run(host="0.0.0.0")