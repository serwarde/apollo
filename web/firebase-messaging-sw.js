

importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
    apiKey: "AIzaSyClK5pyVyEVJmFTIz8iR-zI2PBFBztTwNg",
    authDomain: "awesome-poll-app.firebaseapp.com",
    databaseURL: "https://awesome-poll-app-default-rtdb.europe-west1.firebasedatabase.app",
    projectId: "awesome-poll-app",
    storageBucket: "awesome-poll-app.appspot.com",
    messagingSenderId: "22485641319",
    appId: "1:22485641319:web:f054f40f7b04e7ad394cc2",
    measurementId: "G-R9BZZLK3L2"
};

// Initialize Firebase
const app = firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

messaging.onBackgroundMessage((m) => {
    console.log("onBackgroundMessage", m);

    var lastLatitude = localStorage.getItem('flutter.lastLatitude');
    var lastLongitude = localStorage.getItem('flutter.lastLongitude');

    var poll_latitude = parseFloat(m.data["latitude"]);
    var poll_longitude = parseFloat(m.data["longitude"]);
    var poll_radius = parseFloat(m.data["radius"]);
    const earthPerimeter = 40030 * 1000; // in meters


    if(((lastLongitude - poll_longitude) ** 2) + ((lastLatitude - poll_latitude) ** 2) < (((poll_radius/earthPerimeter*360)*2) ** 2)) {

        const notificationTitle = m.data.title;
        const notificationOptions = {
            body: m.data.body,
            icon: '/favicon.png'
        };

        self.registration.showNotification(notificationTitle,
            notificationOptions);
    }
});