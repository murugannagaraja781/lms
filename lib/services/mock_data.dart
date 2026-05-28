import '../models/course.dart';
import '../models/lesson.dart';
import '../models/quiz.dart';

class MockData {
  static List<Course> getMockCourses() {
    return [
      Course(
        id: 'dev_flutter',
        title: 'Flutter Mobile App Development: Zero to Hero',
        instructor: 'Dr. Angela Yu',
        instructorImageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
        duration: '14h 30m',
        rating: 4.9,
        enrolledCount: 12450,
        difficulty: 'Beginner',
        imageUrl: 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?auto=format&fit=crop&w=800&q=80',
        category: 'Development',
        price: 999.0,
        description: 'Master cross-platform mobile development using Flutter and Dart. Build beautiful, natively compiled applications for iOS, Android, and Web with a single codebase. Includes hands-on projects, state management solutions, and API integration.',
        lessons: [
          Lesson(
            id: 'l_flutter_intro',
            title: '1. Introduction to Flutter & Installation',
            duration: '12:15',
            videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
            description: 'Learn why Flutter is a game-changer for cross-platform app development. We will set up your local development environment and run your first Flutter project.',
            isLocked: false, // First lesson unlocked
          ),
          Lesson(
            id: 'l_flutter_widgets',
            title: '2. Stateless vs. Stateful Widgets',
            duration: '18:40',
            videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
            description: 'Dive deep into the widget tree. Understand the key differences between Stateless and Stateful widgets, and when to use each configuration.',
            quiz: Quiz(
              id: 'q_widgets',
              passingScore: 66,
              questions: [
                Question(
                  questionText: 'Which widget allows you to dynamically redraw UI components when state changes?',
                  options: ['StatelessWidget', 'StatefulWidget', 'InheritedWidget', 'CanvasWidget'],
                  correctAnswerIndex: 1,
                ),
                Question(
                  questionText: 'What method is called inside a StatefulWidget to update the visual interface?',
                  options: ['build()', 'initState()', 'setState()', 'dispose()'],
                  correctAnswerIndex: 2,
                ),
                Question(
                  questionText: 'True or False: A StatelessWidget can have a mutable state.',
                  options: ['True', 'False'],
                  correctAnswerIndex: 1,
                )
              ]
            )
          ),
          Lesson(
            id: 'l_flutter_state',
            title: '3. State Management with Provider',
            duration: '22:10',
            videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
            description: 'A professional-grade deep-dive into application architecture. Learn how to separate business logic from UI using ChangeNotifier and Provider patterns.',
          ),
          Lesson(
            id: 'l_flutter_api',
            title: '4. REST API Integration and JSON Parsing',
            duration: '25:35',
            videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
            description: 'Learn how to pull external data, handle asynchronous futures, parse complex nested JSON strings, and build dynamic grids.',
          ),
        ],
      ),
      Course(
        id: 'design_uiux',
        title: 'UI/UX Design Masterclass: Figma & Design Systems',
        instructor: 'Sarah Jenkins',
        instructorImageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=200&q=80',
        duration: '8h 15m',
        rating: 4.8,
        enrolledCount: 8900,
        difficulty: 'Intermediate',
        imageUrl: 'https://images.unsplash.com/photo-1561070791-2526d30994b5?auto=format&fit=crop&w=800&q=80',
        category: 'Design',
        price: 0.0,
        description: 'Learn the complete product design cycle. From wireframes to visual mockups and interactive high-fidelity prototypes, master Figma tools and build a complete enterprise design system.',
        lessons: [
          Lesson(
            id: 'l_design_principles',
            title: '1. Fundamentals of Visual Hierarchy',
            duration: '15:20',
            videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
            description: 'Understand spacing, scale, typography, and contrast rules that distinguish a premium product design from a basic template.',
            isLocked: false,
          ),
          Lesson(
            id: 'l_design_figma',
            title: '2. Figma Auto Layout 4.0 Advanced Features',
            duration: '21:05',
            videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
            description: 'Become a Figma layout wizard. Learn relative positioning, wrapping widgets, and building fully responsive navigation grids.',
            quiz: Quiz(
              id: 'q_autolayout',
              passingScore: 50,
              questions: [
                Question(
                  questionText: 'How do you create an Auto Layout frame in Figma?',
                  options: ['Ctrl + L', 'Shift + A', 'Alt + F', 'Cmd + G'],
                  correctAnswerIndex: 1,
                ),
                Question(
                  questionText: 'Which setting allows a child element to dynamically fill the remaining space in a parent row?',
                  options: ['Hug Contents', 'Fixed Width', 'Fill Container', 'Align Stretch'],
                  correctAnswerIndex: 2,
                )
              ]
            )
          ),
          Lesson(
            id: 'l_design_systems',
            title: '3. Architecting Color & Type Variables',
            duration: '18:50',
            videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
            description: 'Learn how to define theme variables, responsive typography styles, and atomic components for smooth developers handoff.',
          ),
        ],
      ),
      Course(
        id: 'mkt_digital',
        title: 'Digital Marketing & Growth Hacking Essentials',
        instructor: 'Marcus Aurel',
        instructorImageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
        duration: '10h 0m',
        rating: 4.7,
        enrolledCount: 6540,
        difficulty: 'Beginner',
        imageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=800&q=80',
        category: 'Marketing',
        price: 499.0,
        description: 'Propel your business using modern channels. Formulate customer acquisition plans, design scalable SEO setups, configure targeted ad funnels, and optimize conversion metrics.',
        lessons: [
          Lesson(
            id: 'l_mkt_funnel',
            title: '1. Structuring the Customer Journey',
            duration: '14:40',
            videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
            description: 'Deconstruct the AARRR Pirate metrics funnel (Acquisition, Activation, Retention, Referral, Revenue) and learn how to optimize each conversion stage.',
            isLocked: false,
          ),
          Lesson(
            id: 'l_mkt_seo',
            title: '2. On-Page SEO & Keyword Clustering',
            duration: '19:15',
            videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
            description: 'Learn SEO tactics, keyword search-intent analysis, structuring header cards, and setting up metadata for ultimate visibility.',
          ),
        ],
      ),
      Course(
        id: 'bus_startup',
        title: 'Startup Launchpad: Pitching & Funding 101',
        instructor: 'Elena Rostova',
        instructorImageUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=200&q=80',
        duration: '6h 30m',
        rating: 4.9,
        enrolledCount: 4210,
        difficulty: 'Advanced',
        imageUrl: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=800&q=80',
        category: 'Business',
        price: 0.0,
        description: 'Transform an idea into an active company. Construct pitch decks that close venture capital deals, calculate cash runway, structure equity cap tables, and prepare for due diligence.',
        lessons: [
          Lesson(
            id: 'l_bus_deck',
            title: '1. The 10-Slide Pitch Deck Formula',
            duration: '18:10',
            videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
            description: 'Analyze pitch decks from successful startups like Airbnb and Uber. We review slide-by-slide formatting constraints to grab investor attention.',
            isLocked: false,
          ),
          Lesson(
            id: 'l_bus_cap',
            title: '2. Valuation, SAFE notes & Dilution math',
            duration: '24:50',
            videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
            description: 'A deep spreadsheet-based session calculating equity dilution across Seed and Series A financing rounds using SAFE instruments.',
            quiz: Quiz(
              id: 'q_cap_table',
              passingScore: 100,
              questions: [
                Question(
                  questionText: 'What does "SAFE" stand for in startup financing?',
                  options: [
                    'Standard Arrangement for Financial Equity',
                    'Simple Agreement for Future Equity',
                    'Secure Asset Funding Enterprise',
                    'Startup Association for Financial Entrepreneurs'
                  ],
                  correctAnswerIndex: 1,
                ),
                Question(
                  questionText: 'If a startup issues a pre-money SAFE and later closes a round, dilution occurs for which group first?',
                  options: ['Founders/Common Shareholders', 'New VC Investors', 'Debt lenders', 'None'],
                  correctAnswerIndex: 0,
                )
              ]
            )
          ),
        ],
      )
    ];
  }
}
