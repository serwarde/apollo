import time
import threading
import sched

class NotificationScheduler(object):
    def __init__(self):
        """
        Initialize a sched scheduler and needed variabels.
        """
        self.scheduler = sched.scheduler(time.time, time.sleep)
        self.event = threading.Event()
        self._stop = threading.Event()
        self.start = time.time()

    def addTask(self, timestamp, task, *args):
        """
        Add a schedule to be fired at the given timestamp
        """
        # self.scheduler.enterabs(timestamp, 1, task, argument=args, kwargs={'start': self.start})
        self.scheduler.enterabs(timestamp, 1, task, argument=args)
        self.event.set()

    def stop(self):
        """
        Trigger to stop the scheduler by setting the _stop flag and raising an event which will be catched in the run method.
        """
        self._stop.set()
        self.event.set()

    def removeTask(self, arg):
        """
        Deschedule the task with the name given as argument.
        """
        for event in self.scheduler.queue:
            if event.argument[0] == arg:
                self.scheduler.cancel(event)

    def run(self):
        """
        Infinitely, wait for an event and subsequently start the scheduler
        """
        # Infinitely, wait for an event and subsequently start the scheduler
        max_wait = None
        while not self._stop.is_set():
            self.event.wait(max_wait)
            self.event.clear()
            max_wait = self.scheduler.run(blocking=False)



