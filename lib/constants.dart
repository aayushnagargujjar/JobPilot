import 'models/student_profile.dart'; // Ensure this path matches your file structure

final kDefaultProfile = StudentProfile(
  name: "Aarav Sharma",
  email: "aarav.dev@example.com",
  isComplete: true, // Optional, defaults to false if removed

  // 🎓 Education
  education: [
    Education(
      school: "IIT Bombay",
      degree: "B.Tech in Computer Science",
      year: "2022 - 2026",
    ),
    Education(
      school: "Delhi Public School",
      degree: "Higher Secondary (PCM)",
      year: "2022",
    ),
  ],

  // 🚀 Projects (Now includes 'id' and 'skills' inside project)
  projects: [
    Project(
      id: "proj_001", // specific to your Project class
      name: "JobPilot",
      description: "A smart resume analyzer app using Gemini AI to help students get hired.",
      skills: ["Flutter", "Dart", "Firebase", "Gemini API"],
      link: "https://github.com/aayushnagargujjar/JobPilot",
    ),
    Project(
      id: "proj_002",
      name: "PetNest",
      description: "A startup app for delivering pet food and medical facilities.",
      skills: ["Flutter", "Stripe API", "Google Maps"],
      link: null, // link is nullable in your class
    ),
  ],

  // 🛠️ Skills (General profile skills)
  skills: [
    "Flutter",
    "Dart",
    "Firebase",
    "C++",
    "Python",
    "Git",
  ],

  // 📍 Constraints
  constraints: Constraints(
    location: ["Bangalore", "Hyderabad", "Remote"],
    remoteOnly: false,
  ),

  // 📄 Bullet Bank
  bulletBank: [
    "Developed a cross-platform mobile application using Flutter.",
    "Integrated Google Gemini API for AI-based text analysis.",
    "Collaborated with a team of 3 to build a pet-care ecosystem.",
    "Implemented secure authentication using Firebase Auth.",
  ],
);