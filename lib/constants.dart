import 'models/job.dart';
import 'models/student_profile.dart';

final List<Job> kMockJobs = [
  Job(
    id: 'j1',
    title: 'Junior Flutter Developer',
    company: 'TechCorp',
    location: 'San Francisco, CA',
    type: 'Full-time',
    remote: true,
    requirements: ['Flutter', 'Dart', 'State Management', 'REST APIs'],
    postedDate: '2023-10-25',
  ),
  Job(
    id: 'j2',
    title: 'React Frontend Engineer',
    company: 'WebSolutions',
    location: 'New York, NY',
    type: 'Full-time',
    remote: true,
    requirements: ['React', 'TypeScript', 'Tailwind', 'Redux'],
    postedDate: '2023-10-24',
  ),
  Job(
    id: 'j3',
    title: 'AI Research Intern',
    company: 'OpenMinds',
    location: 'Remote',
    type: 'Internship',
    remote: true,
    requirements: ['Python', 'PyTorch', 'LLMs', 'Research'],
    postedDate: '2023-10-26',
  ),
  Job(
    id: 'j9',
    title: 'Frontend Developer',
    company: 'EvilCorp',
    location: 'Remote',
    type: 'Full-time',
    remote: true,
    requirements: ['JavaScript', 'HTML', 'CSS'],
    postedDate: '2023-10-19',
  ),
  // Generate fillers
  ...List.generate(15, (index) {
    int i = index + 10;
    return Job(
      id: 'j$i',
      title: i % 2 == 0 ? 'Full Stack Developer' : 'Software Engineer',
      company: 'Startup $i',
      location: i % 3 == 0 ? 'Remote' : 'New York, NY',
      type: 'Full-time',
      remote: i % 3 == 0,
      requirements: ['React', 'Node.js', 'SQL'],
      postedDate: '2023-10-01',
    );
  })
];

final kDefaultProfile = StudentProfile(
  name: "Alex Carter",
  email: "alex.carter@university.edu",
  education: [Education("State University", "B.S. Computer Science", "2024")],
  projects: [
    Project("p1", "Expense Tracker App", "A mobile application for tracking expenses.", ["Flutter", "Dart", "Firebase"], "github.com/alex/expense"),
    Project("p2", "Portfolio Website", "Personal portfolio built with React.", ["React", "TypeScript", "Tailwind"], "github.com/alex/portfolio"),
  ],
  skills: ["Flutter", "Dart", "React", "TypeScript", "JavaScript", "Python", "Git"],
  constraints: Constraints(location: ["Remote", "San Francisco, CA"], remoteOnly: false, requireVisa: false),
  bulletBank: [
    "Developed a cross-platform mobile app using Flutter.",
    "Implemented real-time data synchronization.",
  ],
);