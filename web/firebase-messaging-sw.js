importScripts("https://www.gstatic.com/firebasejs/9.6.10/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.6.10/firebase-messaging-compat.js");

// todo Copy/paste firebaseConfig from Firebase Console
const firebaseConfig = {
    apiKey: "AIzaSyAuIuPTlNqsfv7dW9KReNOMr0ebAiPfRfw",
    authDomain: "flutter-fcm-cba29.firebaseapp.com",
    projectId: "flutter-fcm-cba29",
    storageBucket: "flutter-fcm-cba29.appspot.com",
    messagingSenderId: "1062608794290",
    appId: "1:1062608794290:web:260d9db8ff3f0f85c28fab"
};

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

// todo Set up background message handler