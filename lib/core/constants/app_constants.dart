class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'ProofOfSkill';
  static const String appTagline = 'Exchange Skills and Earn NFTs';

  // Points system
  static const int pointsPerSessionTeach = 100;
  static const int pointsPerSessionLearn = -50;
  static const int pointsSignupBonus = 200;
  static const int pointsPerRating = 10;

  // Deep Focus scoring
  static const double deepFocusBaseMultiplier = 1.0;
  static const int deepFocusMinMinutes = 15; // min minutes for bonus
  static const double deepFocusMaxScore = 10.0;

  // Achievement thresholds
  static const int achieveFirstSession = 1;
  static const int achieveFiveSessions = 5;
  static const int achieveTenSessions = 10;
  static const int achieveTwentyFiveSessions = 25;
  static const int achieveFiftySessions = 50;

  // Firebase collection names (ready for integration)
  static const String colUsers = 'users';
  static const String colSessions = 'sessions';
  static const String colMatches = 'matches';
  static const String colRatings = 'ratings';
  static const String colAchievements = 'achievements';
  static const String colMessages = 'messages';
  static const String colNFTs = 'nfts';
  static const String colWallets = 'wallets';

  // All available skills
  static const List<String> allSkills = [
    'Flutter',
    'React',
    'Python',
    'JavaScript',
    'TypeScript',
    'Node.js',
    'UI/UX Design',
    'Figma',
    'Machine Learning',
    'Data Science',
    'Photography',
    'Video Editing',
    'Content Writing',
    'Marketing',
    'Music Production',
    'Blockchain',
    'Solidity',
    'Go',
    'Rust',
    'DevOps',
  ];

  // Daily insights — rotated by day of year
  static const List<String> dailyInsights = [
    '"The best way to learn is to teach. The best way to teach is to keep learning." — Frank Oppenheimer',
    '"Knowledge shared is knowledge doubled." — Ancient Proverb',
    '"In learning you will teach, and in teaching you will learn." — Phil Collins',
    '"Tell me and I forget. Teach me and I remember. Involve me and I learn." — Benjamin Franklin',
    '"The more I learn, the more I realize how much I don\'t know." — Albert Einstein',
    '"Education is not the filling of a pail, but the lighting of a fire." — W.B. Yeats',
    '"Live as if you were to die tomorrow. Learn as if you were to live forever." — Mahatma Gandhi',
    '"The only skill that will be important in the 21st century is the skill of learning new skills." — Peter Drucker',
    '"An investment in knowledge pays the best interest." — Benjamin Franklin',
    '"What we learn with pleasure we never forget." — Alfred Mercier',
    '"Every skill you acquire doubles your odds of success." — Scott Adams',
    '"Skill is the unified force of experience, intellect and passion in their operation." — John Ruskin',
    '"The expert in anything was once a beginner." — Helen Hayes',
    '"Learning never exhausts the mind." — Leonardo da Vinci',
    '"Continuous learning is the minimum requirement for success." — Brian Tracy',
    '"Share your knowledge. It is a way to achieve immortality." — Dalai Lama',
    '"A single conversation across the table with a wise person is worth a month\'s study of books." — Chinese Proverb',
    '"Skills make you rich, not theories." — Robert Kiyosaki',
    '"The beautiful thing about learning is that nobody can take it away from you." — B.B. King',
    '"You don\'t have to be great to start, but you have to start to be great." — Zig Ziglar',
    '"The capacity to learn is a gift; the ability to learn is a skill; the willingness to learn is a choice." — Brian Herbert',
    '"The future belongs to those who learn more skills and combine them in creative ways." — Robert Greene',
    '"I am always doing that which I cannot do, in order that I may learn how to do it." — Pablo Picasso',
    '"Intellectual growth should commence at birth and cease only at death." — Albert Einstein',
    '"One hour per day of study in your chosen field is all it takes." — Earl Nightingale',
    '"We now accept the fact that learning is a lifelong process." — Peter Drucker',
    '"Change is the end result of all true learning." — Leo Buscaglia',
    '"The only person who is educated is the one who has learned how to learn and change." — Carl Rogers',
    '"Develop a passion for learning. If you do, you will never cease to grow." — Anthony J. D\'Angelo',
    '"Learning is not attained by chance, it must be sought for with ardor." — Abigail Adams',
    '"Anyone who stops learning is old. Anyone who keeps learning stays young." — Henry Ford',
  ];

  // Web3 constants
  static const String sepoliaChainId = '0xaa36a7'; // Sepolia testnet
  static const String ipfsGateway = 'https://ipfs.io/ipfs/';
}
