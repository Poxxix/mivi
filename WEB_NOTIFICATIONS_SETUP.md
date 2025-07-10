# 🌐 Web Push Notifications Setup Guide

## ❌ Vấn đề hiện tại
`flutter_local_notifications` **KHÔNG hỗ trợ Web platform**. Để sử dụng push notifications trên Flutter Web, bạn cần Firebase Cloud Messaging (FCM).

## ✅ Giải pháp: Firebase Cloud Messaging

### 1. Setup Firebase Project

#### 1.1 Tạo Firebase Project
1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Tạo new project hoặc chọn project có sẵn
3. Chọn "Add app" → "Web" (</> icon)
4. Nhập app nickname và check "Firebase Hosting"
5. Copy Firebase configuration

#### 1.2 Cấu hình Firebase cho Web
Thêm vào `web/index.html` trước `</body>`:

```html
<!-- Firebase SDKs -->
<script src="https://www.gstatic.com/firebasejs/9.19.1/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.19.1/firebase-messaging.js"></script>

<script>
  // Your web app's Firebase configuration
  const firebaseConfig = {
    apiKey: "your-api-key",
    authDomain: "your-project.firebaseapp.com",
    projectId: "your-project-id",
    storageBucket: "your-project.appspot.com",
    messagingSenderId: "your-sender-id",
    appId: "your-app-id",
    measurementId: "your-measurement-id"
  };

  // Initialize Firebase
  firebase.initializeApp(firebaseConfig);
</script>
```

### 2. Tạo Service Worker

#### 2.1 Tạo file `web/firebase-messaging-sw.js`:
```javascript
importScripts("https://www.gstatic.com/firebasejs/9.19.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.19.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "your-api-key",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "your-sender-id",
  appId: "your-app-id",
  measurementId: "your-measurement-id"
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage(async (payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload.data,
    actions: [
      {
        action: 'open',
        title: 'Open App',
        icon: '/icons/Icon-192.png'
      }
    ]
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification clicks
self.addEventListener('notificationclick', function(event) {
  console.log('[firebase-messaging-sw.js] Notification clicked:', event);
  
  event.notification.close();
  
  // Open the app when notification is clicked
  event.waitUntil(
    clients.openWindow('/')
  );
});
```

#### 2.2 Register Service Worker trong `web/index.html`:
```html
<script>
  // Register service worker
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', function() {
      navigator.serviceWorker.register('/firebase-messaging-sw.js')
        .then(function(registration) {
          console.log('Service Worker registered:', registration.scope);
        })
        .catch(function(err) {
          console.log('Service Worker registration failed:', err);
        });
    });
  }
</script>
```

### 3. Cấu hình VAPID Key

#### 3.1 Tạo VAPID Key:
1. Trong Firebase Console → Project Settings → Cloud Messaging
2. Web configuration → Generate key pair
3. Copy VAPID key

#### 3.2 Cập nhật `WebNotificationService`:
```dart
// Replace trong web_notification_service.dart
String? token = await _messaging!.getToken(
  vapidKey: "your-vapid-key-here", // Thay bằng VAPID key thực
);
```

### 4. Cập nhật Dependencies

Trong `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^3.8.0
  firebase_messaging: ^15.1.4
  flutter_local_notifications: ^17.2.3 # Cho mobile
```

### 5. Test Notifications

#### 5.1 Test từ Firebase Console:
1. Firebase Console → Cloud Messaging → Send your first message
2. Chọn target: "Send test message to FCM registration token"
3. Nhập FCM token từ console log
4. Gửi message

#### 5.2 Test từ Code:
```dart
// Trong web_notification_service.dart
await WebNotificationService().showLocalWebNotification(
  title: 'Test Notification',
  body: 'This is a test notification for web',
  icon: '/icons/Icon-192.png',
);
```

### 6. Sử dụng trong App

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase for web
  if (kIsWeb) {
    await Firebase.initializeApp(options: /* your config */);
  }
  
  runApp(MyApp());
}

// Trong widget
await NotificationService().initialize();
await NotificationService().showNewMovieNotification(movie);
```

## 🔧 Troubleshooting

### Lỗi phổ biến:
1. **"VAPID key not found"**: Thêm VAPID key vào Firebase config
2. **"Service worker not registered"**: Kiểm tra đường dẫn `/firebase-messaging-sw.js`
3. **"Permission denied"**: User chưa cho phép notifications
4. **"FCM token null"**: Firebase chưa được khởi tạo đúng cách

### Debug:
```dart
// Kiểm tra web platform
print('Is web: ${kIsWeb}');

// Kiểm tra FCM token
String? token = await WebNotificationService().getToken();
print('FCM Token: $token');

// Kiểm tra permissions
print('Notification permission: ${Notification.permission}');
```

## 📝 Notes quan trọng

1. **Browser Support**: Chỉ hoạt động trên HTTPS (hoặc localhost)
2. **Permissions**: User phải manually approve notifications
3. **Background**: Cần service worker để handle background notifications
4. **Testing**: Sử dụng `flutter run -d chrome --web-port=8080`
5. **Production**: Deploy lên Firebase Hosting hoặc server hỗ trợ HTTPS

## 🚀 Production Deployment

1. Build for web: `flutter build web`
2. Deploy to Firebase Hosting: `firebase deploy`
3. Test notifications trên domain production
4. Configure FCM server key cho backend notifications

## 🔗 Tài liệu tham khảo

- [Firebase Cloud Messaging Web](https://firebase.google.com/docs/cloud-messaging/js/client)
- [Flutter Firebase Setup](https://firebase.flutter.dev/docs/overview)
- [Web Push Notifications](https://web.dev/push-notifications/)
- [Service Workers](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API) 