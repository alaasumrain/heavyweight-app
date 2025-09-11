# HEAVYWEIGHT - COMPREHENSIVE TESTING GUIDE
*How to test the complete HEAVYWEIGHT application*

---

## 🚀 **QUICK START TESTING**

### **Current Setup**
- **URL**: http://localhost:8080
- **Platform**: Web (Chrome/Safari/Firefox)
- **Backend**: Supabase (live database)
- **Status**: ✅ Production-ready build

### **Prerequisites**
1. **Flutter app running**: `flutter run -d web-server --web-port=8080`
2. **Browser open**: Navigate to http://localhost:8080
3. **Network connection**: Required for Supabase sync

---

## 🧪 **COMPLETE TESTING SCENARIOS**

### **🎯 SCENARIO 1: NEW USER COMPLETE JOURNEY**
*Test the full onboarding → first workout flow*

#### **Step 1: Onboarding Flow (7 screens)**
```
1. SPLASH SCREEN (2 seconds)
   ✅ Check: HEAVYWEIGHT logo displays
   ✅ Check: Auto-advances after 2 seconds
   ✅ Check: Loading indicator works

2. LEGAL GATE SCREEN
   ✅ Check: Terms/Privacy links work
   ✅ Check: "COMMAND: ACCEPT" button functions
   ✅ Check: Cannot proceed without accepting

3. MANIFESTO SCREEN
   ✅ Check: Full manifesto text displays
   ✅ Check: Input field accepts text
   ✅ Check: Only "I COMMIT" (exact) proceeds
   ✅ Check: Error for wrong input

4-8. PROFILE SETUP (5 screens)
   ✅ Check: Training Experience selection
   ✅ Check: Training Frequency selection  
   ✅ Check: Unit Preference (KG/LB)
   ✅ Check: Physical Stats (Age/Weight/Height)
   ✅ Check: Training Objective selection
   ✅ Check: Back buttons work on all screens

9. AUTH SCREEN
   ✅ Check: Email/password validation
   ✅ Check: Signup creates account
   ✅ Check: Loading states during auth
   ✅ Check: Error messages display
```

#### **Step 2: First Workout Experience**
```
10. ASSIGNMENT SCREEN
    ✅ Check: Today's workout displays
    ✅ Check: Exercise list shows
    ✅ Check: "BEGIN WORKOUT" button works

11. DAILY WORKOUT SCREEN
    ✅ Check: Exercise cards display
    ✅ Check: "FIND 5RM" for uncalibrated exercises
    ✅ Check: Tapping exercise starts workout

12. PROTOCOL SCREEN
    ✅ Check: Rep logger works (0-15 reps)
    ✅ Check: Set counter increments
    ✅ Check: Rest timer activates (5 seconds)
    ✅ Check: Haptic feedback on actions

13. SESSION COMPLETE
    ✅ Check: Session summary displays
    ✅ Check: Data saves to database
    ✅ Check: Next workout preview
```

---

### **🔄 SCENARIO 2: RETURNING USER FLOW**
*Test existing user experience*

#### **Login & Navigation**
```
1. SPLASH → AUTH (if not logged in)
   ✅ Check: Login with existing credentials
   ✅ Check: "Forgot Password" functionality
   ✅ Check: Error handling for wrong credentials

2. MAIN APP NAVIGATION
   ✅ Check: Bottom nav carousel (swipe/tap)
   ✅ Check: Assignment → Training Log → Settings
   ✅ Check: Smooth transitions between screens
   ✅ Check: Back buttons work everywhere
```

#### **Data Persistence Testing**
```
3. TRAINING LOG SCREEN
   ✅ Check: Previous workouts display
   ✅ Check: Session details accessible
   ✅ Check: Statistics calculate correctly
   ✅ Check: Performance trends show

4. SETTINGS SCREEN
   ✅ Check: Profile editing works
   ✅ Check: Unit preferences save
   ✅ Check: Data reset functionality
   ✅ Check: Account management options
```

---

### **💪 SCENARIO 3: WORKOUT FLOW TESTING**
*Deep test of the core workout experience*

#### **Calibration Testing**
```
1. UNCALIBRATED EXERCISE
   ✅ Check: "FIND 5RM" displays
   ✅ Check: Calibration process works
   ✅ Check: Weight progression logic
   ✅ Check: 5RM calculation accuracy

2. CALIBRATED EXERCISE
   ✅ Check: Prescribed weight displays
   ✅ Check: 4-6 rep mandate enforcement
   ✅ Check: Weight adjustments based on performance
```

#### **Session Management**
```
3. ACTIVE SESSION
   ✅ Check: Cannot navigate away during workout
   ✅ Check: Session state persists
   ✅ Check: Rest timer cannot be skipped
   ✅ Check: Set logging works correctly

4. SESSION COMPLETION
   ✅ Check: All data saves to Supabase
   ✅ Check: Statistics update
   ✅ Check: Next workout generates
   ✅ Check: Calibration updates
```

---

### **🚨 SCENARIO 4: ERROR HANDLING & EDGE CASES**
*Test app resilience and error recovery*

#### **Network & Data Issues**
```
1. OFFLINE TESTING
   ✅ Check: Disconnect internet during workout
   ✅ Check: Data caches locally
   ✅ Check: Sync when reconnected
   ✅ Check: Error messages display correctly

2. INVALID DATA
   ✅ Check: Invalid email formats
   ✅ Check: Weak passwords
   ✅ Check: Empty form submissions
   ✅ Check: Extreme values (age: 999, weight: -50)
```

#### **UI/UX Edge Cases**
```
3. BROWSER TESTING
   ✅ Check: Chrome, Safari, Firefox compatibility
   ✅ Check: Mobile browser responsiveness
   ✅ Check: Browser back button behavior
   ✅ Check: Refresh during workout

4. RAPID INTERACTIONS
   ✅ Check: Double-tap buttons
   ✅ Check: Rapid navigation
   ✅ Check: Fast form submissions
   ✅ Check: Concurrent operations
```

---

## 🛠️ **TESTING TOOLS & COMMANDS**

### **Development Testing**
```bash
# Run app with hot reload
flutter run -d web-server --web-port=8080

# Check for errors
flutter analyze

# Run tests (if any exist)
flutter test

# Build for production testing
flutter build web
```

### **Browser Developer Tools**
```javascript
// Check console for errors
console.clear()

// Monitor network requests
// Network tab → Filter by "Fetch/XHR"

// Check local storage
localStorage.getItem('flutter.app_state')

// Monitor performance
// Performance tab → Record session
```

### **Database Testing (Supabase)**
```sql
-- Check user data
SELECT * FROM auth.users ORDER BY created_at DESC LIMIT 5;

-- Check workout sessions
SELECT * FROM workout_sessions ORDER BY created_at DESC LIMIT 10;

-- Check sets data
SELECT * FROM sets ORDER BY created_at DESC LIMIT 20;
```

---

## 📊 **TESTING CHECKLIST**

### **✅ FUNCTIONAL TESTING**
- [ ] **Complete onboarding flow** (new user)
- [ ] **Authentication system** (login/signup/reset)
- [ ] **Profile management** (create/edit/save)
- [ ] **Workout execution** (calibration → protocol → completion)
- [ ] **Data persistence** (local + Supabase sync)
- [ ] **Navigation system** (all screens accessible)

### **✅ UI/UX TESTING**
- [ ] **Theme consistency** (colors, fonts, spacing)
- [ ] **Language consistency** (HEAVYWEIGHT voice)
- [ ] **Responsive design** (different screen sizes)
- [ ] **Loading states** (spinners, progress indicators)
- [ ] **Error states** (network, validation, system)
- [ ] **Success feedback** (haptic, visual, audio)

### **✅ PERFORMANCE TESTING**
- [ ] **App startup time** (< 3 seconds to Assignment)
- [ ] **Navigation speed** (smooth transitions)
- [ ] **Data loading** (< 2 seconds for most operations)
- [ ] **Memory usage** (no memory leaks)
- [ ] **Battery impact** (minimal background processing)

### **✅ SECURITY TESTING**
- [ ] **Authentication security** (proper session management)
- [ ] **Data validation** (input sanitization)
- [ ] **API security** (Supabase RLS policies)
- [ ] **Local storage** (sensitive data handling)

---

## 🎯 **SPECIFIC TEST SCENARIOS**

### **🔥 HIGH-PRIORITY TESTS**

#### **Test 1: Complete New User Journey**
```
Time: ~10 minutes
Goal: Verify entire onboarding → first workout
Steps: Splash → Legal → Manifesto → Profile (5) → Auth → Assignment → Workout
Expected: Smooth flow, data saves, no errors
```

#### **Test 2: Workout Data Accuracy**
```
Time: ~15 minutes  
Goal: Verify workout data saves correctly
Steps: Complete full workout session, check database
Expected: All sets, reps, weights recorded accurately
```

#### **Test 3: Navigation & Back Buttons**
```
Time: ~5 minutes
Goal: Test all navigation paths
Steps: Visit every screen, use back buttons, test deep links
Expected: No broken navigation, proper back behavior
```

#### **Test 4: Error Recovery**
```
Time: ~10 minutes
Goal: Test app resilience
Steps: Disconnect network, invalid inputs, rapid interactions
Expected: Graceful error handling, no crashes
```

### **🧪 ADVANCED TESTING**

#### **Load Testing**
```
- Multiple browser tabs
- Rapid workout logging
- Large dataset handling
- Concurrent user simulation
```

#### **Accessibility Testing**
```
- Keyboard navigation
- Screen reader compatibility
- Color contrast validation
- Touch target sizes
```

#### **Cross-Platform Testing**
```
- Desktop browsers (Chrome, Safari, Firefox, Edge)
- Mobile browsers (iOS Safari, Android Chrome)
- Different screen resolutions
- Touch vs mouse interactions
```

---

## 🚀 **READY TO TEST!**

### **Start Testing Now:**

1. **Open browser** → http://localhost:8080
2. **Follow Scenario 1** (New User Journey)
3. **Check each ✅** as you complete tests
4. **Report any issues** found during testing

### **Expected Results:**
- **Smooth onboarding** with no errors
- **Functional workout system** with proper data saving
- **Consistent HEAVYWEIGHT aesthetic** throughout
- **Professional user experience** with haptic feedback

The app is production-ready and should handle all test scenarios successfully! 💪

---

*This testing guide ensures comprehensive coverage of all HEAVYWEIGHT functionality. Follow the scenarios systematically to verify the app meets all requirements.*
