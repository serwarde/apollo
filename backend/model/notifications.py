
from firebase_admin import messaging
from firebase_connection import db
import json
import threading
import model.notification_scheduler
import time


note_scheduler = model.notification_scheduler.NotificationScheduler()
scheduler_thread = None
db_stream = None

mutex = threading.Lock()

def notifyAllUsers(title, body, latitude, longitude, radius):
    """
    Send a notification to all users containing a notification title, a notification body 
    and latitude, longitude and radius of the poll that the notification is for.
    """
    all_users_ordered_dict = db.child("users").get().val()
    all_users_dict = json.loads(json.dumps(all_users_ordered_dict))
    registration_tokens = [v['registrationToken'] for k,v in all_users_dict.items()]

    # message = messaging.MulticastMessage(
    #     notification = messaging.Notification(title, body),
    #     tokens=registration_tokens,
    # )
    message = messaging.MulticastMessage(
        data = {
            "title": title,
            "body": body,
            "latitude": str(latitude), 
            "longitude": str(longitude), 
            "radius": str(radius)
        },
        tokens=registration_tokens,
    )
    response = messaging.send_multicast(message)


    print('{0} messages were sent successfully'.format(response.success_count))

def notify_poll_active(sched_name, poll, poll_title, latitude, longitude, radius):
    """
    Send a notification, that the given poll is now active.
    """
    print(poll_title + " is now active!")
    notifyAllUsers("There's a poll", poll_title + " is now active!", latitude, longitude, radius)

def notify_poll_closed(sched_name, poll, poll_title, latitude, longitude, radius):
    """
    Send a notification, that the given poll is now closed.
    """
    print(poll_title + " is now closed!")
    notifyAllUsers("Poll is closed", poll_title + " is now closed!", latitude, longitude, radius)

def schedules_changed(message):
    """
    Called, when there is a change in the database.
    It schedules new notifications to be sent, if there is a change in start and and time of (new) polls
    """
    # print(message["event"]) # put
    # print(message["path"]) # /-K7yGTTEp7O549EzTYtI
    # print(message["data"]) # {'title': 'Pyrebase', "body": "etc..."}

    if(message["path"]!=None and message["data"]!=None and message["path"]!="/"):
        poll = message["path"][1:]  # strip of the / at the beginning
        schedule(poll, message["data"]["startTime"] / 1000, message["data"]["endTime"] / 1000, message["data"]["title"], message["data"]["latitude"], message["data"]["longitude"], message["data"]["radius"])
    elif(message["path"]=="/" and message["data"]!=None):
        """ 
        Whole subtree is changed. This is for example the case for the initial database fetch .
        Iterate through all polls.
        """
        for poll_path, data in message["data"].items():
            poll = poll_path
            schedule(poll, data["startTime"] / 1000, data["endTime"] / 1000, data["title"], data["latitude"], data["longitude"], data["radius"])
    elif(message["path"]!=None and message["data"]==None):
        """
        Probably a poll has beed deleted. Deschedule it
        """
        poll = message["path"][1:]  # strip of the / at the beginning
        note_scheduler.removeTask(poll + "-active")
        note_scheduler.removeTask(poll + "-closed")
            

def schedule(poll, startTime=-1, endTime=-1, poll_title="A poll", latitude=-1, longitude=-1, radius=-1):
    """
    Schedule notificaitons for the given poll.
    """
    mutex.acquire()
    if(startTime!=None and startTime!=-1 and startTime>time.time()-15*60):   # also allow a few minutes before
        sched_name = poll + "-active"
        note_scheduler.removeTask(sched_name)       # removes currently schedule if exists
        # schedule notification at timestamp startTime
        note_scheduler.addTask(startTime, notify_poll_active, sched_name, poll, poll_title, latitude, longitude, radius)
    if(endTime!=None and endTime!=-1 and endTime>time.time()):
        sched_name = poll + "-closed"
        note_scheduler.removeTask(sched_name)       # removes currently schedule if exists
        # schedule notification at timestamp endTime
        note_scheduler.addTask(endTime, notify_poll_closed, sched_name, poll, poll_title, latitude, longitude, radius)
            
    mutex.release()



def stop_scheduler():
    """
    Delete all schedules and stop the scheduler thread
    """
    print("terminating notification scheduler")
    note_scheduler.stop()
    scheduler_thread.join()
    db_stream.close()



def monitor_thread():
    """
    This thread runns until the main thread ends. It then shuts down the scheduler thread.
    """
    main_thread = threading.main_thread()
    main_thread.join()      # wait for main thread to exit
    stop_scheduler()
    

def initialize():
    """
    Start all needed threads to listen for changes in start and end times of polls and to schedule notifications.
    """

    monitor = threading.Thread(target=monitor_thread)
    monitor.daemon = True
    monitor.start()

    global scheduler_thread
    scheduler_thread = threading.Thread(target=note_scheduler.run)
    # scheduler_thread.daemon = True
    scheduler_thread.start()

    global db_stream
    db_stream = db.child("poll-details").stream(schedules_changed)
    print("started listening for notification schedules")
