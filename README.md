# ProofOfSkill 🧠
> “Exchange Skills. Build Reputation. Own Your Learning.”

## ⚠️ The Problem
- High costs of traditional education and professional tutoring
- Lack of verifiable trust in peer-to-peer skill exchanges
- Distractions interrupting continuous deep focus learning sessions
- No tangible proof of expertise for informal mentoring

## 💡 The Solution
ProofOfSkill is a cross-platform mobile ecosystem where users exchange knowledge instead of money, verified by a transparent trust system.

> "Your expertise is your currency; trade it, build it, own it."

## ✨ Key Features

### 🔄 Skill Exchange
- **Barter System:** Offer what you know in exchange for what you want to learn. No fiat currency involved.
- **Skill Discovery:** Browse curated feeds of available skills across various disciplines.

### 🎯 Deep Focus System (USP)
- **Synchronized Sessions:** Timer-based, synchronized focus intervals between teacher and learner.
- **Distraction-Free Environment:** Built specifically to maintain high engagement and eliminate workflow interruptions.

### 🌟 Rating & Trust System
- **Peer Reviews:** Mutual rating post-session to ensure high-quality interactions.
- **Reputation Score:** Global trust metric calculated from session success and feedback.

### 📊 Progress Tracking
- **Session History:** Detailed logs of all taught and learned sessions.
- **Growth Metrics:** Track hours spent, skills acquired, and overall learning consistency.

### 🤝 Matchmaking
- **Smart Preferences:** Find ideal learning partners based on dual-sided skill matching (What you teach vs. What they want).
- **Availability Sync:** Seamless calendar scheduling and time-zone handling.

### 💬 Chat System
- **Real-Time Communication:** Instant messaging to coordinate sessions.
- **Media Attachments:** Support for images, documents, and resources exchange inline.

### 🗺️ Map Integration
- **Nearby Networks:** Discover close-proximity learners and physical learning collaborative spaces.
- **Location-Based Matchmaking:** Opt-in geo-matching for in-person skill swapping.

### ⛓️ NFT Rewards *(Optional)*
- **Proof of Mastery:** Mint non-transferable NFTs summarizing completed learning paths.
- **Blockchain Verification:** Built on Ethereum Sepolia leveraging IPFS for decentralized metadata storage.
- **MetaMask Integration:** Seamless wallet linking for Web3 enthusiasts.

## 🛠️ Tech Stack
- **Frontend:** Flutter (iOS & Android)
- **Backend:** Firebase (Firestore, Functions, Storage)
- **Blockchain:** Ethereum Sepolia, IPFS, MetaMask

## 📐 System Architecture

Mobile Client (Flutter)
│
├── Authentication & Session Management
│   └── Firebase Auth / Google Auth
│
├── Core Services (Matchmaking, Deep Focus, Maps)
│   └── Cloud Firestore & Google Maps API
│
├── Real-Time Communication
│   └── Firebase Realtime Database / Storage
│
└── Decentralized Proof (Optional)
    └── Web3Dart / Infura / IPFS

## 🔄 System Flow
1. **User Onboarding:** User registers and sets up their "Teach" and "Learn" skill preferences.
2. **Matchmaking Engine:** System suggests compatible partners based on mutual skill requirements.
3. **Connection & Chat:** Users connect, negotiate the skill swap, and share resources via built-in chat.
4. **Session Scheduling:** A mutually agreed time is set for the Deep Focus session.
5. **Session Initiation:** Both users enter the synchronized Deep Focus timer environment.
6. **Active Learning:** Distraction-free, time-boxed learning and interaction phase.
7. **Session Completion:** The Deep Focus timer concludes.
8. **Feedback Loop:** Both parties rate the session and provide qualitative feedback, adjusting trust scores.
9. **Reward Distribution:** Hours are logged to progress trackers, and achievements/NFTs are optionally unlocked.

## 💾 Data Models

### User
```json
{
  "uid": "usr_948abs924",
  "name": "Alice Developer",
  "skillsToTeach": ["Flutter", "Dart"],
  "skillsToLearn": ["UI/UX Design"],
  "trustScore": 4.8,
  "totalHours": 120,
  "location": { "lat": 40.7128, "lng": -74.0060 }
}
```

### Session
```json
{
  "sessionId": "sess_849202nd",
  "teacherId": "usr_948abs924",
  "learnerId": "usr_038dsf231",
  "skill": "Flutter",
  "status": "completed",
  "durationMinutes": 60,
  "scheduledAt": "2026-04-14T15:00:00Z"
}
```

### Message
```json
{
  "messageId": "msg_84jf9s",
  "chatId": "chat_001",
  "senderId": "usr_948abs924",
  "content": "Here is the layout reference.",
  "attachmentUrl": "https://firebase.storage.com/.../layout.png",
  "timestamp": "2026-04-14T10:15:00Z"
}
```

### NFT
```json
{
  "tokenId": "7731",
  "owner": "0xfe3...892a",
  "metadataCid": "ipfs://QmYwAPJzv5CZsnA625s3Xf2nam...",
  "attributes": [
    { "trait_type": "Skill", "value": "Flutter" },
    { "trait_type": "Level", "value": "Intermediate" }
  ]
}
```

## 🚀 Setup Instructions

```bash
# 1. Clone the repository
git clone https://github.com/your-username/ProofOfSkill.git

# 2. Navigate into the project directory
cd ProofOfSkill

# 3. Install Flutter dependencies
flutter pub get

# 4. Run the project
flutter run
```

## ⚙️ Environment Setup
- **Firebase:** Create a Firebase project, configure Android/iOS apps, and place the `google-services.json` and `GoogleService-Info.plist` files in their respective platform directories. Enable Firestore and Storage.
- **Google Auth:** Configure SHA-1/SHA-256 fingerprints in Firebase Settings and enable the Google Sign-In provider.
- **MetaMask (Optional):** Ensure browser extension or MetaMask App is available if testing Web3 integration. Configure your RPC URL (e.g., Infura/Alchemy) in the `.env` file for Sepolia testnet access.

## 🔭 Future Scope
- **AI Tutors:** Integrating LLMs for automated help when a human peer is unavailable.
- **Group Learning Pods:** Expanding 1-on-1 sessions into community classrooms.
- **B2B Integration:** Enterprise plans for companies to run internal employee cross-skilling.
- **Advanced Verification:** Zero-knowledge proofs for verifying skill claims without exposing identity.

## 🌍 Impact
- Democratizing access to high-quality mentorship.
- Building a global economy based purely on verifiable merit and human capital.
- Combating isolation in modern learning by enforcing synchronized, human-centered focus.

## 👥 Team
- **[Team Name Placeholder]** - Built with ❤️ for open knowledge exchange.

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

---
**Your skills are your true wealth. Keep building.**
