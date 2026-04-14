<div align="center">
  <h1>ProofOfSkill 🧠</h1>
  <p><b>“Exchange Skills. Build Reputation. Own Your Learning.”</b></p>
  
  [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?logo=Flutter&logoColor=white)](#)
  [![Firebase](https://img.shields.io/badge/Firebase-%23039BE5.svg?logo=firebase&logoColor=white)](#)
  [![Ethereum](https://img.shields.io/badge/Ethereum-3C3C3D?logo=ethereum&logoColor=white)](#)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

  <p>A cross-platform mobile ecosystem where users exchange knowledge instead of money, verified by a transparent trust system.</p>
</div>

---

## 📸 App Preview

> *(Add your screenshots below. Replace the `src` with your actual image paths from your repository)*

| Dashboard / Feed | Matchmaking Map | Deep Focus Timer | Proof of Skill NFT |
|:---:|:---:|:---:|:---:|
| <img src="docs/screenshots/feed.png" width="200" alt="Feed Screen"/> | <img src="docs/screenshots/map.png" width="200" alt="Map Screen"/> | <img src="docs/screenshots/timer.png" width="200" alt="Timer Screen"/> | <img src="docs/screenshots/nft.png" width="200" alt="NFT Screen"/> |

*Experience a distraction-free, synchronized learning environment.*

---

## ⚠️ The Problem

- **Financial Barriers:** High costs of traditional education and professional tutoring limit access to quality up-skilling.
- **Trust Deficit:** Lack of verifiable trust and accountability in informal, peer-to-peer skill exchanges.
- **Attention Economy:** Constant distractions interrupt continuous deep-focus learning and knowledge retention.
- **Invisible Effort:** No tangible proof of expertise or recognition for informal mentoring and community teaching.

## 💡 The Solution

**ProofOfSkill** tokenizes time and expertise. It provides a structured platform to barter skills seamlessly while establishing a verifiable reputation. 

> *"Your expertise is your currency; trade it, build it, own it."*

---

## ✨ Key Features

### 🔄 Skill Exchange
- **Barter System:** Offer what you know in exchange for what you want to learn. No fiat currency involved.
- **Skill Discovery:** Browse curated feeds of available skills across various disciplines.

### 🎯 Deep Focus System (Our USP)
- **Synchronized Sessions:** Timer-based, synchronized focus intervals between teacher and learner.
- **Distraction-Free Environment:** Built specifically to maintain high engagement and eliminate workflow interruptions.

### 🌟 Rating & Trust System
- **Peer Reviews:** Mutual rating post-session to ensure high-quality, respectful interactions.
- **Reputation Score:** Global trust metric calculated dynamically from session success and feedback.

### 📊 Progress Tracking
- **Session History:** Detailed logs and visual graphs of all taught and learned sessions.
- **Growth Metrics:** Track hours spent, skills acquired, and overall learning consistency over time.

### 🤝 Matchmaking & 🗺️ Map Integration
- **Smart Preferences:** Find ideal learning partners based on dual-sided skill matching (What you teach vs. What they want to learn).
- **Nearby Networks:** Discover close-proximity learners and physical learning collaborative spaces.
- **Availability Sync:** Seamless calendar scheduling and automatic time-zone handling.

### 💬 Seamless Communication
- **Real-Time Chat:** Instant messaging to coordinate sessions efficiently.
- **Media Attachments:** Support for sharing images, code snippets, documents, and resources inline.

### ⛓️ NFT Rewards *(Optional Web3 Layer)*
- **Proof of Mastery:** Mint non-transferable NFTs (Soulbound Tokens) summarizing completed learning milestones.
- **Blockchain Verification:** Built on Ethereum Sepolia leveraging IPFS for decentralized metadata storage.
- **MetaMask Integration:** Seamless wallet linking for users who want to carry their reputation on-chain.

---

## 📐 System Architecture

An elegant, scalable approach blending Web2 speed with Web3 verifiability.

```text
Mobile Client (Flutter)
│
├── Authentication & Identity
│   └── Firebase Auth & Google Sign-In
│
├── Core Mechanics (Matchmaking, Deep Focus, Maps)
│   └── Cloud Firestore & Google Maps API
│
├── Real-Time Communication
│   └── Firebase Realtime Database & Cloud Storage
│
└── Decentralized Proof Layer (Optional)
    └── Web3Dart → Infura/Alchemy → Ethereum Sepolia (IPFS)
```

---

## 🔄 System Flow

1. **Onboarding:** User registers and defines "Teach" and "Learn" skill preferences.
2. **Matchmaking:** The engine suggests compatible partners based on mutual skill requirements and geolocation.
3. **Connection:** Users connect, negotiate the skill swap, and share resources via built-in chat.
4. **Scheduling:** A mutually agreed time is set for the Deep Focus session.
5. **Initiation:** Both users enter the synchronized Deep Focus timer environment.
6. **Active Learning:** Distraction-free, time-boxed learning and interaction phase.
7. **Completion:** The Deep Focus timer concludes, unlocking the review phase.
8. **Feedback:** Both parties rate the session to adjust mutual trust scores.
9. **Rewards:** Hours are logged to progress trackers, and achievements/NFTs are optionally unlocked.

---

## 💾 Core Data Models

<details>
<summary><b>Click to expand Data Models</b></summary>
<br>

**User Profile**
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

**Learning Session**
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

**NFT Metadata**
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
</details>

---

## 🚀 Setup Instructions

```bash
# 1. Clone the repository
git clone https://github.com/your-username/ProofOfSkill.git

# 2. Navigate into the project directory
cd ProofOfSkill

# 3. Install Flutter dependencies
flutter pub get

# 4. Generate necessary platform files
flutter create .

# 5. Run the project
flutter run
```

### ⚙️ Environment Setup
- **Firebase:** Create a Firebase project, configure Android/iOS apps, and place `google-services.json` / `GoogleService-Info.plist` in their respective directories.
- **Google Auth:** Configure SHA-1/SHA-256 fingerprints in Firebase Settings and enable Google Sign-In.
- **Web3 (Optional):** Define your Sepolia RPC URL (e.g., via Infura/Alchemy) in a `.env` file at the root level. Ensure a MetaMask wallet is available for testing on-device.

---

## 🔭 Future Scope

- **AI Companions:** Integrating LLMs for automated initial help when a human peer is unavailable.
- **Group Learning Pods:** Expanding 1-on-1 sessions into community-driven virtual classrooms.
- **B2B Integration:** Enterprise plans allowing companies to manage internal employee cross-skilling.
- **Zero-Knowledge Proofs:** Advanced zk-SNARKs implementation for verifying skill claims without exposing user identity.

## 🌍 Impact

- **Democratized Learning:** Stripping away financial barriers to high-quality, practical mentorship.
- **Merit-Based Economy:** Building a global ecosystem based purely on verifiable human capital.
- **Focused Growth:** Combating the isolation and distraction of modern learning by enforcing synchronized, structured focus.

---

## 👥 Team
- **[Your Name / Team Logo]** - Built with ❤️ for open knowledge exchange.

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

> **Your skills are your true wealth. Keep building.**
