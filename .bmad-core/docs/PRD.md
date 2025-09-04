# 🏋️ Heavyweight Fitness App - Product Requirements Document

## 📊 Executive Summary

**Product Name**: Heavyweight  
**Version**: 1.0.0  
**Project Type**: Flutter Mobile App  
**Platform**: iOS & Android  
**Backend**: Supabase  

### Product Vision
Heavyweight is a brutalist strength training application that enforces the scientifically-proven 4-6 repetition mandate for optimal strength gains. Unlike traditional fitness apps, Heavyweight removes choice and complexity, providing users with a systematic, non-negotiable approach to strength development.

### Core Philosophy
- **No Choices, Only Mandates**: The system prescribes, users execute
- **Brutal Simplicity**: Minimal UI, maximum effectiveness  
- **Truth Over Comfort**: Honest data logging without sugar-coating
- **Progress Enforcement**: Automatic load progression based on performance

## 🎯 Product Objectives

### Primary Objectives
1. **Systematic Strength Development**: Provide scientifically-backed progression protocols
2. **User Compliance**: Enforce proper training discipline through mandatory rest and prescribed loads
3. **Data Integrity**: Capture honest workout data for accurate progression calculations
4. **Offline Reliability**: Function completely without internet connectivity in gym environments

### Success Metrics
- **User Retention**: 70% 30-day retention rate
- **Session Completion**: 85% of started workouts completed
- **Progression Adherence**: 90% of users following prescribed load increases
- **App Store Rating**: Maintain 4.5+ stars with 4.0+ quality rating

## 👥 Target Users

### Primary User: The Committed Lifter
- **Demographics**: Ages 25-45, experienced with weight training
- **Motivation**: Seeking systematic approach to strength gains
- **Pain Points**: Inconsistent programming, decision fatigue, plateau breaking
- **Goals**: Measurable strength increases, structured progression

### Secondary User: The Returning Athlete
- **Demographics**: Ages 30-50, former competitive athletes
- **Motivation**: Return to peak physical condition with structure
- **Pain Points**: Outdated training knowledge, time constraints
- **Goals**: Efficient training, injury prevention, systematic comeback

### Tertiary User: The Serious Beginner
- **Demographics**: Ages 20-35, new to strength training but highly motivated
- **Motivation**: Learn proper training methodology from the start
- **Pain Points**: Information overload, program confusion
- **Goals**: Build strength foundation, establish proper habits

## 🔥 Core Features

### 1. Workout Assignment System
**Business Value**: Eliminates decision paralysis and ensures progressive overload

**Functionality**:
- Daily workout prescriptions based on user's training cycle
- Exercise selection from "The Big Six" compound movements
- Prescribed weights calculated from calibration data
- No user choices - system determines all variables

**Acceptance Criteria**:
- [ ] User sees today's assignment upon app launch
- [ ] Assignment displays exercise name, prescribed weight, and set/rep targets
- [ ] Assignment updates based on user's training cycle position
- [ ] Offline assignment access for gym environments

### 2. Calibration Protocol
**Business Value**: Establishes accurate baseline for load prescription

**Functionality**:
- Initial 5-rep maximum testing for each major movement
- Progressive loading protocol to find true strength levels
- Automatic working weight calculations (80% of 5RM)
- Re-calibration triggers based on performance data

**Acceptance Criteria**:
- [ ] New users complete calibration before accessing main app
- [ ] Calibration protocol guides users through proper 5RM testing
- [ ] System calculates working weights automatically
- [ ] Calibration data persists and syncs across devices

### 3. Session Execution Engine
**Business Value**: Ensures proper workout execution with enforced recovery

**Functionality**:
- Set-by-set progression through prescribed workout
- Rep logging with no artificial limits (accepts 0-30+ reps)
- Mandatory rest periods (3+ minutes) with countdown timer
- Automatic progression calculations based on performance

**Acceptance Criteria**:
- [ ] Users cannot skip or reduce prescribed rest periods
- [ ] Rep logger accepts any value without validation limits
- [ ] System provides immediate feedback on set performance (below/within/above mandate)
- [ ] Session state persists through app crashes or connectivity issues

### 4. Automatic Load Progression
**Business Value**: Removes guesswork and ensures continuous progress

**Functionality**:
- Increase load by 2.5% when reps exceed 6
- Decrease load by 7.5% when reps fall below 4
- Maintain load when reps fall within 4-6 mandate
- Account for partial credit on failed attempts

**Acceptance Criteria**:
- [ ] Load adjustments apply automatically to next workout
- [ ] Progression algorithm accounts for all sets in exercise
- [ ] System rounds weights to nearest available increment
- [ ] Progression history is logged and reviewable

### 5. Offline-First Architecture
**Business Value**: Ensures functionality in gym environments with poor connectivity

**Functionality**:
- Complete workout execution without internet connection
- Local data persistence with background sync
- Conflict resolution for data synchronization
- Cached assignment data for offline access

**Acceptance Criteria**:
- [ ] All core features work without internet connection
- [ ] Workout data saves locally and syncs when connected
- [ ] Assignment data caches for offline access
- [ ] User receives notification when sync fails

## 🏗️ Technical Requirements

### Performance Requirements
- **Cold Start Time**: <3 seconds to workout screen
- **Memory Usage**: <150MB during active workout session
- **Battery Impact**: Minimal drain during 60-minute workout
- **Rendering**: Maintain 60fps during all interactions
- **Crash Rate**: <0.1% of user sessions

### Platform Requirements
- **iOS**: iOS 14.0+ on iPhone and iPad
- **Android**: Android API 28+ on phones and tablets
- **Cross-Platform**: UI/UX parity between platforms
- **Offline**: 100% core functionality without internet

### Security Requirements
- **Data Encryption**: All user data encrypted in transit and at rest
- **Authentication**: Secure user authentication with Supabase Auth
- **Privacy**: Minimal data collection, clear privacy policy
- **GDPR Compliance**: Right to data export and deletion

### Integration Requirements
- **Backend**: Supabase for database, auth, and real-time features
- **Analytics**: Minimal, privacy-focused usage analytics
- **Notifications**: Local notifications for workout reminders
- **Storage**: Local SQLite for offline data persistence

## 🎨 Design Requirements

### Visual Design Principles
- **Brutalist Aesthetic**: Stark, utilitarian interface design
- **High Contrast**: Black background, white text, minimal colors
- **Monospace Typography**: IBM Plex Mono for technical feel
- **Sharp Geometry**: Square corners, hard lines, no gradients

### User Experience Principles
- **Cognitive Load Reduction**: Minimal choices, clear hierarchy
- **Immediate Feedback**: Instant response to all user actions
- **Error Prevention**: Design prevents common user mistakes
- **Consistency**: Uniform interaction patterns throughout

### Interaction Patterns
- **Command-Based Interface**: Button text uses imperative commands
- **Modal Flows**: Full-screen modals for focused tasks
- **Progressive Disclosure**: Reveal information as needed
- **Confirmation Patterns**: Critical actions require explicit confirmation

## 📋 User Stories

### Epic: Workout Execution
**As a** strength athlete  
**I want** to execute prescribed workouts with enforced parameters  
**So that** I follow proper training protocols without deviation

#### Story: Set Logging
**As a** user during workout  
**I want** to log the actual reps I completed  
**So that** the system can track my performance accurately

**Acceptance Criteria**:
- [ ] Rep logger accepts any integer value from 0-50
- [ ] System provides immediate feedback on set performance
- [ ] Logged data persists immediately (crash-safe)
- [ ] UI shows clear visual feedback for different performance zones

#### Story: Enforced Rest Periods
**As a** user between sets  
**I want** mandatory rest periods enforced  
**So that** I allow proper recovery for next set

**Acceptance Criteria**:
- [ ] Rest timer counts down from prescribed time (3+ minutes)
- [ ] User cannot skip or reduce rest duration
- [ ] Timer shows clear visual progress indicator
- [ ] Audio/haptic feedback when rest period ends

### Epic: Progressive Overload
**As a** strength athlete  
**I want** automatic load progression based on performance  
**So that** I continuously challenge my muscles for growth

#### Story: Automatic Weight Calculation
**As a** user after completing workout  
**I want** my next workout weights calculated automatically  
**So that** I don't have to guess at proper progression

**Acceptance Criteria**:
- [ ] Weights increase 2.5% when performance exceeds mandate
- [ ] Weights decrease 7.5% when performance falls below mandate
- [ ] Weights maintain when performance is within mandate
- [ ] User can preview next workout weights

## 📊 Analytics & Metrics

### User Engagement Metrics
- **Daily Active Users (DAU)**: Target 1,000 within 6 months
- **Session Duration**: Average 45-60 minutes per workout session
- **Feature Adoption**: 90%+ users complete calibration protocol
- **Workout Completion**: 85%+ of started sessions completed

### Performance Metrics
- **Load Progression**: 75% of users following prescribed increases
- **Mandate Adherence**: 80% of sets fall within 4-6 rep range
- **Session Recovery**: 99%+ recovery rate from crashes/interruptions
- **Sync Success**: 99%+ of workout data successfully synchronized

### Quality Metrics
- **App Store Rating**: Maintain 4.5+ stars
- **Crash Rate**: <0.1% of sessions
- **Customer Support**: <2% of users require support contact
- **User Retention**: 70% 30-day, 50% 90-day retention rates

## 🚀 Release Strategy

### Phase 1: Core MVP (8 weeks)
- Calibration protocol
- Basic workout execution
- Manual load progression
- Local data storage

### Phase 2: Automation (4 weeks)
- Automatic load progression
- Enhanced offline support
- Performance optimizations
- Cross-platform testing

### Phase 3: Polish (4 weeks)
- Advanced analytics
- User onboarding flow
- App store optimization
- Documentation completion

### Post-Launch: Iteration (Ongoing)
- User feedback integration
- Performance monitoring
- Feature refinements
- Platform updates

## ⚠️ Risks & Mitigation

### Technical Risks
- **Risk**: Poor gym WiFi affects functionality
- **Mitigation**: Offline-first architecture with local persistence

- **Risk**: Cross-platform performance differences
- **Mitigation**: Extensive device testing and platform-specific optimization

- **Risk**: User data loss during workouts
- **Mitigation**: Immediate local persistence with background sync

### Product Risks
- **Risk**: Users abandon rigid system constraints
- **Mitigation**: Clear onboarding explaining benefits of systematic approach

- **Risk**: Competition from established fitness apps
- **Mitigation**: Differentiate through uncompromising training philosophy

- **Risk**: Regulatory changes affecting health apps
- **Mitigation**: Legal review and compliance monitoring

## ✅ Success Criteria

### Launch Success
- [ ] 1,000+ app downloads in first month
- [ ] 4.5+ app store rating with 50+ reviews
- [ ] <0.5% crash rate across all devices
- [ ] 85%+ workout completion rate

### Product-Market Fit
- [ ] 70% monthly retention rate
- [ ] 50% of users complete 10+ workouts
- [ ] Net Promoter Score >50
- [ ] Organic user growth >20% monthly

### Technical Success
- [ ] 99.9% uptime for backend services
- [ ] <3 second cold start time
- [ ] 100% offline core functionality
- [ ] Zero critical security vulnerabilities

---

**Document Version**: 1.0  
**Last Updated**: September 4, 2024  
**Next Review**: October 4, 2024  
**Owner**: Product Manager Agent