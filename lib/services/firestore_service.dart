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

  // Learn Articles Methods

  // Get all published articles
  static Future<List<Map<String, dynamic>>> getLearnArticles() async {
    try {
      final snapshot = await _firestore
          .collection('learn')
          .where('published', isEqualTo: true)
          .orderBy('order')
          .get();

      final articles = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        // Convert timestamps to DateTime if needed
        if (data['publishedAt'] is Timestamp) {
          data['publishedAt'] = (data['publishedAt'] as Timestamp).toDate();
        }
        if (data['updatedAt'] is Timestamp) {
          data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate();
        }

        articles.add(data);
      }

      return articles;
    } catch (e) {
      return [];
    }
  }

  // Get a specific article by ID
  static Future<Map<String, dynamic>?> getLearnArticle(String articleId) async {
    try {
      final snapshot = await _firestore
          .collection('learn')
          .doc(articleId)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        data['id'] = snapshot.id;

        // Convert timestamps to DateTime if needed
        if (data['publishedAt'] is Timestamp) {
          data['publishedAt'] = (data['publishedAt'] as Timestamp).toDate();
        }
        if (data['updatedAt'] is Timestamp) {
          data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate();
        }

        return data;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // One-time article population (REMOVE AFTER USE)
  static Future<void> populateArticlesOnce() async {
    try {
      // Check how many articles currently exist
      final existingArticles = await _firestore.collection('learn').get();

      // If we already have 5 or more articles, skip
      if (existingArticles.docs.length >= 5) {
        return;
      }

      final sampleArticles = [
        {
          'title': 'Understanding Blood Glucose',
          'summary':
              'Learn what blood glucose levels mean and how to interpret your readings.',
          'content': '''# Understanding Blood Glucose

Blood glucose, also known as blood sugar, is the main sugar found in your blood. It's your body's primary source of energy and comes from the food you eat.

## Normal Blood Glucose Ranges

- **Fasting**: 70-100 mg/dL (3.9-5.6 mmol/L)
- **2 hours after eating**: Less than 140 mg/dL (7.8 mmol/L)
- **Random**: 70-140 mg/dL (3.9-7.8 mmol/L)

## Why Monitor Blood Glucose?

Regular monitoring helps you:
- Understand how food affects your levels
- Track the effectiveness of medications
- Identify patterns and trends
- Make informed decisions about your health

## When to Test

- Before meals
- 2 hours after meals
- Before bedtime
- When you feel symptoms of high or low blood sugar

Remember to always consult with your healthcare provider about your target ranges and testing schedule.''',
          'imageUrl':
              'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=800&h=400&fit=crop',
          'readTime': 5,
          'difficulty': 'beginner',
          'tags': ['glucose', 'monitoring', 'basics'],
          'published': true,
          'author': 'DiabApp Team',
          'order': 1,
        },
        {
          'title': 'Carbohydrate Counting Basics',
          'summary':
              'Master the fundamentals of counting carbs to better manage your blood glucose.',
          'content': '''# Carbohydrate Counting Basics

Carbohydrate counting is a meal planning method that helps you manage your blood glucose levels by tracking the amount of carbohydrates you eat.

## What are Carbohydrates?

Carbohydrates are one of the main nutrients found in food and drinks. They include:
- **Sugars**: Found in fruits, milk, and processed foods
- **Starches**: Found in grains, potatoes, and legumes
- **Fiber**: Found in fruits, vegetables, and whole grains

## Why Count Carbs?

- Carbohydrates have the most direct effect on blood glucose
- Helps with medication dosing (especially insulin)
- Allows for more flexible meal planning
- Improves overall blood glucose control

## How to Count Carbs

### Reading Food Labels
1. Look at the "Total Carbohydrate" line
2. Check the serving size
3. Calculate based on how much you actually eat

### Common Carb Portions
- 1 slice of bread = 15g carbs
- 1/2 cup cooked rice = 15g carbs
- 1 medium apple = 15g carbs
- 1 cup milk = 12g carbs

## Tips for Success

- Start by measuring and weighing foods
- Use a food diary or app to track
- Learn to estimate portion sizes
- Focus on consistency rather than perfection

Practice makes perfect - start with simple meals and gradually work up to more complex dishes.''',
          'imageUrl':
              'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800&h=400&fit=crop',
          'readTime': 8,
          'difficulty': 'beginner',
          'tags': ['nutrition', 'carbs', 'meal-planning'],
          'published': true,
          'author': 'DiabApp Team',
          'order': 2,
        },
        {
          'title': 'Exercise and Blood Sugar',
          'summary':
              'Discover how physical activity affects your glucose levels and exercise safely.',
          'content': '''# Exercise and Blood Sugar

Physical activity is one of the most effective tools for managing diabetes. Understanding how exercise affects your blood glucose can help you stay active safely.

## How Exercise Affects Blood Glucose

### During Exercise
- **Aerobic exercise**: Usually lowers blood glucose
- **High-intensity exercise**: May temporarily raise blood glucose
- **Duration matters**: Longer activities have more sustained effects

### After Exercise
- Blood glucose may continue to drop for up to 24 hours
- This is called the "post-exercise effect"
- Risk of delayed hypoglycemia, especially overnight

## Types of Exercise

### Aerobic Exercise
- Walking, jogging, cycling, swimming
- Generally lowers blood glucose during and after
- Improves insulin sensitivity

### Resistance Training
- Weight lifting, resistance bands
- May cause temporary glucose increase
- Builds muscle mass and improves metabolism

### Flexibility and Balance
- Yoga, tai chi, stretching
- Lower impact on blood glucose
- Great for stress reduction

## Safety Guidelines

### Before Exercise
- Check blood glucose levels
- Have fast-acting carbs available
- Stay hydrated
- Warm up properly

### During Exercise
- Monitor how you feel
- Stop if you experience symptoms of low blood sugar
- Stay hydrated

### After Exercise
- Check blood glucose again
- Eat appropriate post-workout snack if needed
- Monitor for delayed effects

## Blood Glucose Targets for Exercise

- **Before exercise**: 100-180 mg/dL is generally safe
- **Below 100 mg/dL**: Consider eating a small snack
- **Above 250 mg/dL**: Check for ketones, may need to postpone

Remember to work with your healthcare team to develop a personalized exercise plan that's safe and effective for you.''',
          'imageUrl':
              'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=400&fit=crop',
          'readTime': 10,
          'difficulty': 'intermediate',
          'tags': ['exercise', 'activity', 'safety'],
          'published': true,
          'author': 'DiabApp Team',
          'order': 3,
        },
        {
          'title': 'Managing Stress and Diabetes',
          'summary':
              'Learn effective stress management techniques that can help improve your blood glucose control.',
          'content': '''# Managing Stress and Diabetes

Stress can significantly impact your blood glucose levels and overall diabetes management. Learning to manage stress effectively is an important part of your diabetes care plan.

## How Stress Affects Blood Glucose

### Physical Stress Response
- Releases stress hormones (cortisol, adrenaline)
- These hormones can raise blood glucose
- Can make insulin less effective
- May lead to insulin resistance

### Behavioral Impact
- May lead to poor food choices
- Can disrupt sleep patterns
- Might cause skipping medications
- Can reduce motivation for self-care

## Types of Stress

### Acute Stress
- Short-term, intense situations
- Traffic jams, work deadlines, arguments
- Usually causes temporary blood glucose spikes

### Chronic Stress
- Long-term, ongoing situations
- Work pressure, family issues, financial problems
- Can lead to consistently elevated blood glucose

## Stress Management Techniques

### Relaxation Methods
- **Deep breathing**: 4-7-8 technique
- **Progressive muscle relaxation**: Tense and release muscle groups
- **Meditation**: Even 5-10 minutes daily can help
- **Mindfulness**: Focus on the present moment

### Physical Activities
- Regular exercise (as discussed in previous articles)
- Yoga or tai chi
- Dancing or other enjoyable activities
- Gardening or outdoor activities

### Social Support
- Talk to friends and family
- Join support groups
- Consider professional counseling
- Connect with diabetes communities

### Lifestyle Changes
- Prioritize sleep (7-9 hours nightly)
- Maintain regular meal times
- Limit caffeine and alcohol
- Create boundaries with technology

## Practical Stress-Busting Tips

### Daily Habits
- Start each day with 5 minutes of deep breathing
- Take short breaks during stressful activities
- Practice gratitude journaling
- Listen to calming music

### Emergency Stress Relief
- Count to 10 before reacting
- Take a short walk
- Call a supportive friend
- Use positive self-talk

### Long-term Strategies
- Identify your stress triggers
- Develop coping plans for common situations
- Regular check-ins with healthcare team
- Consider stress management classes

## When to Seek Help

Contact your healthcare provider if:
- Stress is significantly affecting your blood glucose
- You're having trouble sleeping regularly
- You feel overwhelmed or depressed
- Your usual coping strategies aren't working

Remember, managing stress is a skill that improves with practice. Be patient with yourself as you develop these important life skills.''',
          'imageUrl':
              'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=400&fit=crop',
          'readTime': 12,
          'difficulty': 'intermediate',
          'tags': ['stress', 'mental-health', 'lifestyle'],
          'published': true,
          'author': 'DiabApp Team',
          'order': 4,
        },
        {
          'title': 'Understanding Insulin Types',
          'summary':
              'A comprehensive guide to different types of insulin and how they work in your body.',
          'content': '''# Understanding Insulin Types

If you use insulin to manage your diabetes, understanding the different types and how they work can help you achieve better blood glucose control.

## What is Insulin?

Insulin is a hormone produced by the pancreas that helps glucose enter your cells for energy. In diabetes, your body either doesn't make enough insulin or can't use it effectively.

## Categories of Insulin

### Rapid-Acting Insulin
**Examples**: Lispro, Aspart, Glulisine
- **Onset**: 15 minutes
- **Peak**: 1-2 hours
- **Duration**: 3-4 hours
- **Use**: Taken with meals to cover food

### Short-Acting (Regular) Insulin
**Examples**: Humulin R, Novolin R
- **Onset**: 30 minutes
- **Peak**: 2-3 hours
- **Duration**: 6-8 hours
- **Use**: Taken before meals, sometimes mixed with longer-acting insulin

### Intermediate-Acting Insulin
**Examples**: NPH insulin
- **Onset**: 2-4 hours
- **Peak**: 4-6 hours
- **Duration**: 12-20 hours
- **Use**: Often taken twice daily to provide background insulin

### Long-Acting Insulin
**Examples**: Glargine, Detemir
- **Onset**: 2-4 hours
- **Peak**: Minimal peak
- **Duration**: 20-24 hours
- **Use**: Provides steady background insulin, usually once daily

### Ultra-Long-Acting Insulin
**Examples**: Degludec
- **Onset**: 1-2 hours
- **Peak**: No pronounced peak
- **Duration**: Up to 42 hours
- **Use**: Very stable background insulin

## Insulin Regimens

### Basal-Bolus
- Long-acting insulin for background needs
- Rapid-acting insulin with meals
- Most flexible approach
- Requires frequent blood glucose monitoring

### Fixed Mixtures
- Combines intermediate and rapid/short-acting
- Usually taken twice daily
- Less flexible but simpler
- Pre-mixed ratios (70/30, 75/25, etc.)

### Conventional
- NPH and regular insulin
- Usually twice daily
- Requires consistent meal timing
- Less expensive option

## Insulin Delivery Methods

### Syringes
- Traditional method
- Various sizes available
- Draw from vial
- Least expensive

### Insulin Pens
- Pre-filled or cartridge-based
- More convenient and discrete
- Built-in dose measurement
- Replaceable needles

### Insulin Pumps
- Continuous delivery
- Programmable rates
- Most precise dosing
- Requires training and maintenance

## Storage and Safety

### Storage Guidelines
- Unopened insulin: Store in refrigerator
- Opened insulin: Can be kept at room temperature for 28 days
- Never freeze insulin
- Protect from extreme heat and light

### Safety Tips
- Check expiration dates
- Inspect for clumping or crystals
- Rotate injection sites
- Don't share needles or pens

## Working with Your Healthcare Team

### Regular Monitoring
- Blood glucose logs
- Hemoglobin A1C tests
- Time in range assessments
- Hypoglycemia episodes

### Insulin Adjustments
- Based on blood glucose patterns
- Consider activity levels and meal changes
- Account for illness or stress
- Always follow provider guidelines

## Common Challenges

### Hypoglycemia
- Learn to recognize symptoms
- Always carry fast-acting glucose
- Know when to seek help
- Adjust insulin as directed

### Weight Gain
- Monitor portion sizes
- Stay active
- Work with dietitian
- Don't skip insulin doses

### Injection Site Issues
- Rotate sites regularly
- Use proper injection technique
- Watch for lipodystrophy
- Keep sites clean

Remember, insulin management is highly individual. Work closely with your healthcare team to find the regimen that works best for your lifestyle and glucose control goals.''',
          'imageUrl':
              'https://images.unsplash.com/photo-1584515933487-779824d29309?w=800&h=400&fit=crop',
          'readTime': 15,
          'difficulty': 'advanced',
          'tags': ['insulin', 'medication', 'treatment'],
          'published': true,
          'author': 'DiabApp Team',
          'order': 5,
        },
      ];

      // Get existing article titles to avoid duplicates
      final existingTitles = existingArticles.docs
          .map((doc) => doc.data()['title'] as String?)
          .where((title) => title != null)
          .toSet();

      final now = DateTime.now();

      for (int i = 0; i < sampleArticles.length; i++) {
        try {
          final article = Map<String, dynamic>.from(sampleArticles[i]);
          final articleTitle = article['title'] as String;

          // Skip if article already exists
          if (existingTitles.contains(articleTitle)) {
            continue;
          }

          // Add timestamps
          article['publishedAt'] = Timestamp.fromDate(now);
          article['updatedAt'] = Timestamp.fromDate(now);

          await _firestore.collection('learn').add(article);

          // Small delay to avoid overwhelming Firestore
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          // Failed to add article
        }
      }
    } catch (e) {
      // Error during article population
    }
  }
}
