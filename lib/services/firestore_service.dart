import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Référence à la collection users
  static CollectionReference get usersCollection =>
      _firestore.collection('users');

  // Obtenir l'UID de l'utilisateur actuel
  static String? get currentUserId => _auth.currentUser?.uid;

  // Obtenir le document de l'utilisateur actuel
  static DocumentReference? get currentUserDoc {
    final uid = currentUserId;
    return uid != null ? usersCollection.doc(uid) : null;
  }

  // Récupérer les données de l'utilisateur
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userDoc = currentUserDoc;
      if (userDoc == null) return null;

      final snapshot = await userDoc.get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Créer ou mettre à jour les données de l'utilisateur
  static Future<bool> saveUserData(Map<String, dynamic> data) async {
    try {
      final userDoc = currentUserDoc;
      if (userDoc == null) return false;

      await userDoc.set(data, SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Mettre à jour un champ spécifique
  static Future<bool> updateUserField(String field, dynamic value) async {
    try {
      final userDoc = currentUserDoc;
      if (userDoc == null) return false;

      await userDoc.update({field: value});
      return true;
    } catch (e) {
      return false;
    }
  }

  // Obtenir un stream des données utilisateur (pour les mises à jour en temps réel)
  static Stream<DocumentSnapshot>? getUserDataStream() {
    final userDoc = currentUserDoc;
    return userDoc?.snapshots();
  }

  // Méthodes spécifiques pour les paramètres
  static Future<bool> updateNotificationSettings({
    bool? notificationsEnabled,
    bool? bloodSugarCheckNotifications,
    bool? medicationReminders,
  }) async {
    final Map<String, dynamic> updates = {};

    if (notificationsEnabled != null) {
      updates['notificationsEnabled'] = notificationsEnabled;
    }
    if (bloodSugarCheckNotifications != null) {
      updates['bloodSugarCheckNotifications'] = bloodSugarCheckNotifications;
    }
    if (medicationReminders != null) {
      updates['medicationReminders'] = medicationReminders;
    }

    return await saveUserData(updates);
  }

  static Future<bool> updateUnits({
    String? glucoseUnit,
    String? carbohydrateUnit,
  }) async {
    final Map<String, dynamic> updates = {};

    if (glucoseUnit != null) {
      updates['glucoseUnit'] = glucoseUnit;
    }
    if (carbohydrateUnit != null) {
      updates['carbohydrateUnit'] = carbohydrateUnit;
    }

    return await saveUserData(updates);
  }

  static Future<bool> updateGlucoseTargets({
    int? targetGlucoseMin,
    int? targetGlucoseMax,
  }) async {
    final Map<String, dynamic> updates = {};

    if (targetGlucoseMin != null) {
      updates['targetGlucoseMin'] = targetGlucoseMin;
    }
    if (targetGlucoseMax != null) {
      updates['targetGlucoseMax'] = targetGlucoseMax;
    }

    return await saveUserData(updates);
  }

  static Future<bool> updatePersonalInfo({
    String? firstName,
    String? lastName,
    String? diabetesType,
  }) async {
    final Map<String, dynamic> updates = {};

    if (firstName != null) {
      updates['firstName'] = firstName;
    }
    if (lastName != null) {
      updates['lastName'] = lastName;
    }
    if (diabetesType != null) {
      updates['diabetesType'] = diabetesType;
    }

    return await saveUserData(updates);
  }

  // Events management methods
  static CollectionReference? get eventsCollection {
    final userDoc = currentUserDoc;
    return userDoc?.collection('events');
  }

  // Add a new event
  static Future<String?> addEvent(Map<String, dynamic> eventData) async {
    try {
      final eventsRef = eventsCollection;
      if (eventsRef == null) return null;

      // Only add server timestamp if no date is provided
      if (!eventData.containsKey('date') || eventData['date'] == null) {
        eventData['date'] = FieldValue.serverTimestamp();
      }

      final docRef = await eventsRef.add(eventData);

      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  // Get events for a specific date range
  static Future<List<Map<String, dynamic>>> getEvents({
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    int limit = 50,
  }) async {
    try {
      final eventsRef = eventsCollection;
      if (eventsRef == null) return [];

      Query query = eventsRef.orderBy('date', descending: true);

      // Apply date filters
      if (startDate != null) {
        query = query.where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }
      if (endDate != null) {
        query = query.where(
          'date',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      // Apply type filter
      if (type != null && type.isNotEmpty) {
        query = query.where('type', isEqualTo: type);
      }

      // Apply limit
      query = query.limit(limit);

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        // Convert Timestamp to DateTime
        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate();
        }

        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get events for a specific day
  static Future<List<Map<String, dynamic>>> getEventsForDay(
    DateTime day,
  ) async {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);

    return await getEvents(startDate: startOfDay, endDate: endOfDay);
  }

  // Update an event
  static Future<bool> updateEvent(
    String eventId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final eventsRef = eventsCollection;
      if (eventsRef == null) return false;

      await eventsRef.doc(eventId).update(updates);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete an event
  static Future<bool> deleteEvent(String eventId) async {
    try {
      final eventsRef = eventsCollection;
      if (eventsRef == null) return false;

      await eventsRef.doc(eventId).delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get the latest glucose measurement
  static Future<Map<String, dynamic>?> getLatestGlucoseMeasurement() async {
    try {
      final eventsRef = eventsCollection;
      if (eventsRef == null) return null;

      final snapshot = await eventsRef
          .where('type', isEqualTo: 'glucose')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        // Convert Timestamp to DateTime
        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate();
        }

        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get average glucose for the last 7 days
  static Future<double?> getWeeklyGlucoseAverage() async {
    try {
      final eventsRef = eventsCollection;
      if (eventsRef == null) return null;

      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));

      final snapshot = await eventsRef
          .where('type', isEqualTo: 'glucose')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      if (snapshot.docs.isEmpty) return null;

      double total = 0;
      int count = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final measure = data['measure'];
        if (measure != null) {
          total += (measure as num).toDouble();
          count++;
        }
      }

      return count > 0 ? total / count : null;
    } catch (e) {
      return null;
    }
  }

  // Get average glucose for the previous week (8-14 days ago)
  static Future<double?> getPreviousWeekGlucoseAverage() async {
    try {
      final eventsRef = eventsCollection;
      if (eventsRef == null) return null;

      final endDate = DateTime.now().subtract(const Duration(days: 7));
      final startDate = endDate.subtract(const Duration(days: 7));

      final snapshot = await eventsRef
          .where('type', isEqualTo: 'glucose')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      if (snapshot.docs.isEmpty) return null;

      double total = 0;
      int count = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final measure = data['measure'];
        if (measure != null) {
          total += (measure as num).toDouble();
          count++;
        }
      }

      return count > 0 ? total / count : null;
    } catch (e) {
      return null;
    }
  }

  // Get daily glucose averages for the past 7 days (for chart)
  static Future<List<Map<String, dynamic>>> getDailyGlucoseAverages() async {
    try {
      final eventsRef = eventsCollection;
      if (eventsRef == null) return [];

      final now = DateTime.now();
      final dailyAverages = <Map<String, dynamic>>[];

      // Get data for each of the past 7 days
      for (int i = 6; i >= 0; i--) {
        final targetDate = now.subtract(Duration(days: i));
        final startOfDay = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
        );
        final endOfDay = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          23,
          59,
          59,
        );

        final snapshot = await eventsRef
            .where('type', isEqualTo: 'glucose')
            .where(
              'date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
            .get();

        double total = 0;
        int count = 0;

        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final measure = data['measure'];
          if (measure != null) {
            total += (measure as num).toDouble();
            count++;
          }
        }

        final average = count > 0 ? total / count : null;

        // Get day name
        const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final dayName = dayNames[targetDate.weekday - 1];

        dailyAverages.add({
          'date': targetDate,
          'dayName': dayName,
          'average': average,
          'count': count,
        });
      }

      return dailyAverages;
    } catch (e) {
      return [];
    }
  }
}
