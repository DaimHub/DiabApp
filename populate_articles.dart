import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:diabapp/firebase_options.dart';

// Logging functionality
class Logger {
  static late File _logFile;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    final logsDir = Directory('logs');
    if (!await logsDir.exists()) {
      await logsDir.create();
    }

    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')[0];
    _logFile = File('logs/article_population_$timestamp.log');

    await _logFile.writeAsString('=== Article Population Script Log ===\n');
    await _logFile.writeAsString('Started at: ${DateTime.now()}\n\n');
    _initialized = true;
  }

  static Future<void> log(String message) async {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $message\n';

    // Print to console
    print(message);

    // Write to file
    if (_initialized) {
      await _logFile.writeAsString(logMessage, mode: FileMode.append);
    }
  }

  static Future<void> error(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) async {
    final timestamp = DateTime.now().toIso8601String();
    var logMessage = '[$timestamp] ERROR: $message\n';

    if (error != null) {
      logMessage += '[$timestamp] Exception: $error\n';
    }

    if (stackTrace != null) {
      logMessage += '[$timestamp] Stack trace:\n$stackTrace\n';
    }

    logMessage += '\n';

    // Print to console
    print('❌ ERROR: $message');
    if (error != null) print('Exception: $error');

    // Write to file
    if (_initialized) {
      await _logFile.writeAsString(logMessage, mode: FileMode.append);
    }
  }

  static Future<void> success(String message) async {
    await log('✅ SUCCESS: $message');
  }

  static Future<void> info(String message) async {
    await log('ℹ️ INFO: $message');
  }

  static Future<void> warning(String message) async {
    await log('⚠️ WARNING: $message');
  }
}

// Sample articles to populate
final List<Map<String, dynamic>> sampleArticles = [
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

Future<void> main() async {
  print('🚀 Script starting...');

  try {
    // Initialize logging with error handling
    print('📝 Initializing logging...');
    try {
      await Logger.init();
      await Logger.info('🚀 Starting article population script...');
    } catch (logError) {
      print('⚠️ Logging initialization failed: $logError');
      print('Continuing without logging...');
    }

    // Log system information
    print('📋 System info:');
    print('Dart version: ${Platform.version}');
    print('Operating system: ${Platform.operatingSystem}');
    print('Current directory: ${Directory.current.path}');

    if (Logger._initialized) {
      await Logger.info('Dart version: ${Platform.version}');
      await Logger.info('Operating system: ${Platform.operatingSystem}');
      await Logger.info('Current directory: ${Directory.current.path}');
    }

    // Check if firebase_options.dart exists
    print('🔍 Checking firebase_options.dart...');
    final firebaseOptionsFile = File('lib/firebase_options.dart');
    if (!await firebaseOptionsFile.exists()) {
      final error =
          'firebase_options.dart not found. Please run "flutterfire configure" first.';
      print('❌ ERROR: $error');
      if (Logger._initialized) {
        await Logger.error(error);
      }
      return;
    }
    print('✅ firebase_options.dart found');
    if (Logger._initialized) {
      await Logger.info('firebase_options.dart found');
    }

    // Initialize Firebase
    print('🔥 Initializing Firebase...');
    if (Logger._initialized) {
      await Logger.info('Initializing Firebase...');
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('✅ Firebase initialized successfully');
    if (Logger._initialized) {
      await Logger.success('Firebase initialized successfully');
    }

    // Get Firestore instance
    print('📊 Getting Firestore instance...');
    if (Logger._initialized) {
      await Logger.info('Getting Firestore instance...');
    }

    final firestore = FirebaseFirestore.instance;
    final learnCollection = firestore.collection('learn');

    print('✅ Firestore instance obtained');
    if (Logger._initialized) {
      await Logger.info('Firestore instance obtained');
    }

    // Check existing articles
    print('📑 Checking existing articles in learn collection...');
    if (Logger._initialized) {
      await Logger.info('Checking existing articles in learn collection...');
    }

    final existingArticles = await learnCollection.get();

    print('📊 Found ${existingArticles.docs.length} existing articles');
    if (Logger._initialized) {
      await Logger.info(
        'Found ${existingArticles.docs.length} existing articles',
      );
    }

    // Log existing article titles
    for (final doc in existingArticles.docs) {
      final data = doc.data();
      final title = data['title'] ?? 'No title';
      print('📄 Existing article: "$title" (ID: ${doc.id})');
      if (Logger._initialized) {
        await Logger.info('Existing article: "$title" (ID: ${doc.id})');
      }
    }

    // Prepare timestamp for new articles
    final now = DateTime.now();
    print('⏰ Using timestamp: $now');
    if (Logger._initialized) {
      await Logger.info('Using timestamp: $now');
    }

    print('📚 Starting to add ${sampleArticles.length} new articles...');
    if (Logger._initialized) {
      await Logger.info(
        'Starting to add ${sampleArticles.length} new articles...',
      );
    }

    // Add each article with detailed logging
    for (int i = 0; i < sampleArticles.length; i++) {
      try {
        final article = Map<String, dynamic>.from(sampleArticles[i]);

        print('--- Processing Article ${i + 1}/${sampleArticles.length} ---');
        print('Title: "${article['title']}"');
        print('Difficulty: ${article['difficulty']}');
        print('Read time: ${article['readTime']} minutes');
        print('Tags: ${article['tags']}');
        print('Content length: ${article['content']?.length ?? 0} characters');

        if (Logger._initialized) {
          await Logger.info(
            '--- Processing Article ${i + 1}/${sampleArticles.length} ---',
          );
          await Logger.info('Title: "${article['title']}"');
          await Logger.info('Difficulty: ${article['difficulty']}');
          await Logger.info('Read time: ${article['readTime']} minutes');
          await Logger.info('Tags: ${article['tags']}');
          await Logger.info(
            'Content length: ${article['content']?.length ?? 0} characters',
          );
        }

        // Add timestamps
        article['publishedAt'] = Timestamp.fromDate(now);
        article['updatedAt'] = Timestamp.fromDate(now);
        print('✅ Added timestamps to article');
        if (Logger._initialized) {
          await Logger.info('Added timestamps to article');
        }

        // Validate required fields
        final requiredFields = [
          'title',
          'summary',
          'content',
          'difficulty',
          'tags',
          'published',
          'author',
          'order',
        ];
        for (final field in requiredFields) {
          if (!article.containsKey(field) || article[field] == null) {
            print('⚠️ WARNING: Missing or null field: $field');
            if (Logger._initialized) {
              await Logger.warning('Missing or null field: $field');
            }
          }
        }

        print('💾 Adding article to Firestore...');
        if (Logger._initialized) {
          await Logger.info('Adding article to Firestore...');
        }

        final docRef = await learnCollection.add(article);

        print('✅ Added article with ID: ${docRef.id}');
        if (Logger._initialized) {
          await Logger.success('Added article with ID: ${docRef.id}');
        }

        // Verify the article was added
        final addedDoc = await docRef.get();
        if (addedDoc.exists) {
          print('✅ Verified article exists in Firestore');
          final addedData = addedDoc.data() as Map<String, dynamic>;
          print('📄 Stored title: "${addedData['title']}"');
          if (Logger._initialized) {
            await Logger.success('Verified article exists in Firestore');
            await Logger.info('Stored title: "${addedData['title']}"');
          }
        } else {
          print('❌ ERROR: Article was not found after adding');
          if (Logger._initialized) {
            await Logger.error('Article was not found after adding');
          }
        }

        // Small delay to avoid overwhelming Firestore
        await Future.delayed(Duration(milliseconds: 200));
        print('✅ Completed processing article ${i + 1}');
        if (Logger._initialized) {
          await Logger.info('Completed processing article ${i + 1}');
        }
      } catch (e, stackTrace) {
        print(
          '❌ ERROR: Failed to add article ${i + 1}: "${sampleArticles[i]['title']}"',
        );
        print('Exception: $e');
        print('Stack trace: $stackTrace');
        if (Logger._initialized) {
          await Logger.error(
            'Failed to add article ${i + 1}: "${sampleArticles[i]['title']}"',
            e,
            stackTrace,
          );
        }
        // Continue with next article instead of stopping
      }
    }

    // Final verification
    print('--- Final Verification ---');
    if (Logger._initialized) {
      await Logger.info('--- Final Verification ---');
    }

    final finalArticles = await learnCollection.get();
    print(
      '📊 Total articles in collection after script: ${finalArticles.docs.length}',
    );
    if (Logger._initialized) {
      await Logger.info(
        'Total articles in collection after script: ${finalArticles.docs.length}',
      );
    }

    final addedCount = finalArticles.docs.length - existingArticles.docs.length;
    print('🎉 Successfully added $addedCount new articles to Firestore!');
    if (Logger._initialized) {
      await Logger.success(
        'Successfully added $addedCount new articles to Firestore!',
      );
    }

    // Log final collection state
    print('📋 Final collection contents:');
    if (Logger._initialized) {
      await Logger.info('Final collection contents:');
    }

    for (final doc in finalArticles.docs) {
      final data = doc.data();
      final title = data['title'] ?? 'No title';
      final order = data['order'] ?? 'N/A';
      print('- "$title" (ID: ${doc.id}, Order: $order)');
      if (Logger._initialized) {
        await Logger.info('- "$title" (ID: ${doc.id}, Order: $order)');
      }
    }

    print('🎉 Script completed successfully!');
    if (Logger._initialized) {
      await Logger.success('Script completed successfully!');
    }
  } catch (e, stackTrace) {
    print('💥 FATAL ERROR: Script failed with unexpected error');
    print('Exception: $e');
    print('Stack trace: $stackTrace');
    if (Logger._initialized) {
      await Logger.error('Script failed with unexpected error', e, stackTrace);
    }
    exit(1);
  }
}
