# 🚀 ProofOfSkill  
### Exchange Skills. Build Reputation. Own Your Learning.

ProofOfSkill is a cross-platform mobile application (iOS + Android) that enables users to exchange skills instead of money, track their progress, and earn verifiable digital achievements.

---

## 🎯 Problem

- Learning is expensive and inaccessible  
- Skills are hard to verify in real-world scenarios  
- Lack of trust and personalization in existing platforms  

---

## 💡 Solution

ProofOfSkill enables:
- Peer-to-peer skill exchange  
- Deep focus learning sessions  
- Trust-based rating system  
- NFT-based proof of skill (optional blockchain layer)  

> “Your skills are your real currency — we just make them tradable.”

---

## ✨ Key Features

### 🤝 Skill Exchange
- Offer and learn skills  
- No money, only barter + points  

### 🔥 Deep Focus System
- Both users start session together  
- Timer-based focused learning  
- Duration impacts ratings and rewards  

### ⭐ Rating System
- Post-session feedback  
- Dynamic reputation  

### 📊 Progress Tracking
- Sessions completed  
- Hours spent  
- Growth charts  

### 🧠 Matchmaking
- Match based on skills and rating  

### 💬 Chat System
- Real-time messaging  
- Attachments (docs, media, location)  
- Video call (planned)  

### 🗺️ Map Integration
- Discover nearby learners  
- Find learning spaces  

### 💎 NFT Rewards (Optional)
- Earn points → unlock NFTs  
- Mint on Ethereum Sepolia  
- Stored on IPFS  
- MetaMask wallet integration  

---

## 🏗️ Tech Stack

### Frontend
- Flutter (iOS + Android)

### Backend
- Firebase (Auth, Firestore, Realtime DB)

### Blockchain (Optional)
- Ethereum (Sepolia Testnet)  
- ERC-721 Smart Contracts  
- IPFS  
- MetaMask  

---

## 🧩 System Architecture

Flutter App  
↓  
Firebase Backend  
↓  
Matchmaking + Session Logic  
↓  
Points + Rating Engine  
↓  
(Optional) Blockchain Layer  

---

## 🔄 System Flow

1. User Registration  
2. Skill Matching  
3. Session Scheduling  
4. Deep Focus Session  
5. Skill Exchange  
6. Rating & Verification  
7. Points & Achievements  
8. NFT Minting (Optional)  
9. Profile Update  

---

## 📊 Data Models

### User
```json
{
  "id": "",
  "name": "",
  "skillsOffered": [],
  "skillsWanted": [],
  "rating": 0,
  "points": 0
}
