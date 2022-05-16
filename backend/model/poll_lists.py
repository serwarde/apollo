from firebase_connection import db
import json

path_polls = 'polls'

def listPollsNearby(longitude, latitude):
    """
    Fetch a list of all polls from the database, 
    filter it by the given location matching the polls active regions and return the list
    """

    def isInReach(poll, longitude, latitude):
        earth_perimeter = 40030 * 1000  # in meters
        print(poll['title'])
        print(poll['radius']/earth_perimeter*360)
        return pow((longitude - poll['longitude']), 2) + pow((latitude - poll['latitude']), 2) < pow(poll['radius']/earth_perimeter*360, 2)
        
    poll_list_ordered_dict = db.child(path_polls).get().val()
    # convert to dict
    poll_list_dict = json.loads(json.dumps(poll_list_ordered_dict))
    poll_list_filtered = {k: v for k,v in poll_list_dict.items() if isInReach(v, longitude, latitude)}

    return poll_list_filtered

def listPolls():
    """
    Fetch a list of all polls from the database
    """
     
    poll_list_ordered_dict = db.child(path_polls).get().val()
    # convert to dict
    poll_list_dict = json.loads(json.dumps(poll_list_ordered_dict))
    poll_list_filtered = {k: v for k,v in poll_list_dict.items()}

    return poll_list_filtered