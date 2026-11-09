
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'fcm_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('onBackgroundMessage: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FCMService _fcmService = FCMService();

  static const Map<String, String> _assets = {
    'default': 'assets/images/default.png',
    'promo': 'assets/images/promo.png',
  };

  String _statusText = 'Waiting for a cloud message';
  String _imagePath = 'assets/images/default.png';
  String _feedback = 'Initializing messaging...';
  String _lastHandler = 'None yet';
  String _lastMessageId = 'None yet';
  int _messageCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeMessaging();
  }

  Future<void> _initializeMessaging() async {
    try {
      await _fcmService.initialize(
        onMessage: _handleMessage,
      );

      if (!mounted) return;
      setState(() {
        _feedback = 'Messaging initialized';
      });
    } catch (error) {
      debugPrint('Messaging error: $error');
      if (!mounted) return;
      setState(() {
        _feedback = 'Messaging error: $error';
      });
    }
  }

  void _handleMessage(RemoteMessage message, String source) {
    if (!mounted) return;

    setState(() {
      _lastHandler = source;
      _lastMessageId = message.messageId ?? '(no ID)';
      _messageCount++;

      final action = message.data['action'];
      final asset = message.data['asset'];
      final path = _assets[asset];

      if (action != 'update_ui' || path == null) {
        _feedback = 'Rejected payload: invalid action or asset. '
            'Previous content preserved.';
        return;
      }

      _statusText = message.notification?.title ?? 'Payload received';
      _imagePath = path;
      _feedback = 'Applied payload successfully';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity 14: FCM'),
        backgroundColor: Colors.deepPurple.shade100,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            _statusText,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Image.asset(
            _imagePath,
            height: 180,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Text('Cannot load image: $_imagePath');
            },
          ),
          const SizedBox(height: 24),
          Text('Last handler: $_lastHandler'),
          const SizedBox(height: 8),
          Text('Messages handled this launch: $_messageCount'),
          const SizedBox(height: 8),
          Text('Last message ID: $_lastMessageId'),
          const SizedBox(height: 16),
          Text(_feedback),
        ],
      ),
    );
  }
}
