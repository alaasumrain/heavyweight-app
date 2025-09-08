# HEAVYWEIGHT APP - UI/UX TESTING CHECKLIST

## 🎯 TESTING METHODOLOGY
**Goal**: Test every screen as a real user would, checking navigation, functionality, and edge cases.

---

## 1. 🚀 SPLASH SCREEN TEST
**URL**: http://localhost:8080

### ✅ Test Cases:
- [ ] **Auto-loading**: Screen shows HEAVYWEIGHT branding
- [ ] **Initialization**: App initializes providers and services
- [ ] **Auto-redirect**: Automatically moves to next screen after ~2 seconds
- [ ] **Loading states**: No infinite loading or crashes
- [ ] **Error handling**: Graceful handling if initialization fails

### 🔍 What to Check:
- HEAVYWEIGHT logo/title displays correctly
- Loading animation works smoothly
- No console errors in browser dev tools
- Transitions to Legal Gate screen automatically

### 🐛 Potential Issues:
- Infinite loading loop
- Provider initialization failures
- Missing assets (logo, fonts)

---

## 2. ⚖️ LEGAL GATE SCREEN TEST

### ✅ Test Cases:
- [ ] **UI Display**: Terms and privacy message shows clearly
- [ ] **External Links**: "VIEW TERMS" and "VIEW PRIVACY" buttons work
- [ ] **Accept Button**: "COMMAND: ACCEPT" button functions
- [ ] **Navigation**: Successfully moves to Manifesto screen
- [ ] **State Persistence**: Legal acceptance is saved

### 🔍 What to Check:
- Terminal-style UI matches design
- External links open in new tab/window
- Accept button enables and works
- No way to bypass without accepting

### 🐛 Potential Issues:
- Broken external links
- Accept button not working
- State not persisting

---

## 3. 📜 MANIFESTO SCREEN TEST

### ✅ Test Cases:
- [ ] **Manifesto Text**: Full manifesto displays correctly
- [ ] **Input Field**: Text input for "I_COMMIT" works
- [ ] **Validation**: Only accepts exact "I_COMMIT" text
- [ ] **Error Messages**: Shows error for wrong input
- [ ] **Success**: Moves to profile flow on correct input
- [ ] **Case Sensitivity**: Tests uppercase/lowercase handling

### 🔍 What to Check:
- Manifesto text is readable and formatted
- Input field accepts text
- Validation is strict (exact match)
- Error messages are clear
- Terminal aesthetic maintained

### 🐛 Potential Issues:
- Input validation too strict/loose
- Error messages not showing
- Navigation not working after success

---

## 4. 👤 PROFILE SETUP FLOW TEST (5 Screens)

### 4A. Training Experience Screen
### ✅ Test Cases:
- [ ] **Radio Options**: BEGINNER | INTERMEDIATE | ADVANCED selectable
- [ ] **Selection State**: Visual feedback for selected option
- [ ] **Continue Button**: Enabled only when selection made
- [ ] **Navigation**: Moves to Training Frequency screen
- [ ] **Data Persistence**: Selection is saved

### 4B. Training Frequency Screen
### ✅ Test Cases:
- [ ] **Selector Wheel**: 3-6 days selector works
- [ ] **Value Display**: Current selection shows clearly
- [ ] **Increment/Decrement**: +/- buttons work
- [ ] **Bounds**: Can't go below 3 or above 6
- [ ] **Navigation**: Moves to Unit Preference screen

### 4C. Unit Preference Screen
### ✅ Test Cases:
- [ ] **Toggle Switch**: KG/LB toggle works
- [ ] **Visual Feedback**: Clear indication of selected unit
- [ ] **Default Value**: Has sensible default
- [ ] **Navigation**: Moves to Physical Stats screen

### 4D. Physical Stats Screen
### ✅ Test Cases:
- [ ] **Age Selector**: 16-80 range works
- [ ] **Weight Input**: Accepts valid weight values
- [ ] **Height Input**: Accepts valid height values
- [ ] **Unit Conversion**: Respects KG/LB preference
- [ ] **Validation**: Rejects invalid inputs
- [ ] **Navigation**: Moves to Training Objective screen

### 4E. Training Objective Screen
### ✅ Test Cases:
- [ ] **Radio Options**: STRENGTH | SIZE | DISCIPLINE selectable
- [ ] **Selection State**: Visual feedback works
- [ ] **Continue Button**: Enabled when selection made
- [ ] **Navigation**: Moves to Auth screen
- [ ] **Complete Profile**: All profile data collected

### 🔍 Profile Flow General Checks:
- Back navigation works between profile screens
- Data persists when navigating back/forward
- Progress indication (if any) works
- Terminal aesthetic consistent across all screens
- No data loss during navigation

---

## 5. 🔐 AUTHENTICATION SCREEN TEST

### ✅ Test Cases:
- [ ] **Mode Toggle**: Switch between SIGNUP/LOGIN works
- [ ] **Email Field**: Accepts valid email format
- [ ] **Password Field**: Secure input, shows/hides password
- [ ] **Email Validation**: Rejects invalid email formats
- [ ] **Password Validation**: Enforces password requirements
- [ ] **Signup Flow**: Creates new account successfully
- [ ] **Login Flow**: Authenticates existing user
- [ ] **Error Handling**: Shows clear error messages
- [ ] **Forgot Password**: Link works (if implemented)
- [ ] **Navigation**: Moves to main app on success

### 🔍 What to Check:
- Form validation works properly
- Supabase authentication integrates correctly
- Error messages are user-friendly
- Loading states during auth requests
- Profile data is saved to user account

### 🐛 Potential Issues:
- Supabase connection issues
- Validation too strict/loose
- Profile data not linking to user
- Authentication state not persisting

---

## 6. 🏠 MAIN APP NAVIGATION TEST

### ✅ Test Cases:
- [ ] **Bottom Navigation**: Assignment | Training Log | Settings tabs work
- [ ] **Swipe Navigation**: Left/right swipe between screens
- [ ] **Swipe Threshold**: 25% screen width threshold works
- [ ] **Swipe Animation**: Smooth carousel-like transitions
- [ ] **Swipe Boundaries**: Can't swipe beyond first/last screen
- [ ] **Tab Highlighting**: Active tab clearly indicated
- [ ] **Navigation State**: Maintains current screen state

### 🔍 What to Check:
- Swipe gestures feel natural
- Animations are smooth (300ms duration)
- Visual feedback during swipe
- Navigation state persists
- No conflicts between tap and swipe

---

## 7. 📋 ASSIGNMENT SCREEN TEST

### ✅ Test Cases:
- [ ] **Workout Display**: Today's workout shows correctly
- [ ] **Exercise List**: All exercises with weights displayed
- [ ] **Start Session**: "COMMAND: START_SESSION" button works
- [ ] **Last Session**: Previous session summary shows
- [ ] **No Workout**: Handles rest days gracefully
- [ ] **Loading States**: Shows loading while fetching data
- [ ] **Error States**: Handles data fetch errors
- [ ] **Navigation**: Can navigate to other main screens

### 🔍 What to Check:
- Workout data loads from Supabase
- Exercise weights are calculated correctly
- UI updates when data changes
- Performance is smooth
- Error handling is graceful

---

## 8. 💪 WORKOUT FLOW TEST

### 8A. Session Active Screen
### ✅ Test Cases:
- [ ] **Exercise Display**: Current exercise shows clearly
- [ ] **Weight Display**: Correct weight for exercise
- [ ] **Rep Logger**: Can input reps (4-6 range validation)
- [ ] **Set Logging**: "LOG_SET" button works
- [ ] **Progress Tracking**: Shows current set/total sets
- [ ] **Exercise Progression**: Moves through exercises
- [ ] **Inline Feedback**: Shows feedback after logging set
- [ ] **Navigation**: Can access other screens during workout

### 8B. Enforced Rest Screen
### ✅ Test Cases:
- [ ] **Timer Display**: Countdown shows correctly (180 seconds)
- [ ] **Timer Functionality**: Counts down properly
- [ ] **UI Lock**: Commands locked during rest
- [ ] **Skip Button**: Disabled until timer ends
- [ ] **Next Set Preview**: Shows upcoming set info
- [ ] **Auto Navigation**: Returns to session after rest
- [ ] **Timer Accuracy**: Time is accurate

### 8C. Session Complete Screen
### ✅ Test Cases:
- [ ] **Performance Summary**: Shows session statistics
- [ ] **Duration Display**: Workout duration calculated
- [ ] **Sets Summary**: Total sets completed
- [ ] **Performance Breakdown**: On target/above/below analysis
- [ ] **Navigation Options**: Can go to training log or home
- [ ] **Data Persistence**: Session saved to database

---

## 9. 📊 TRAINING LOG SCREEN TEST

### ✅ Test Cases:
- [ ] **History Display**: Past workouts show chronologically
- [ ] **Session Cards**: Each session displays key info
- [ ] **Date Formatting**: Dates are clear and readable
- [ ] **Performance Indicators**: Visual performance feedback
- [ ] **Session Details**: Can tap to view detailed session
- [ ] **Empty State**: Handles no workout history gracefully
- [ ] **Loading State**: Shows loading while fetching history
- [ ] **Infinite Scroll**: Handles large workout history
- [ ] **Export Options**: Data export functionality (if implemented)

### 🔍 What to Check:
- Data loads from Supabase correctly
- Performance with large datasets
- Session detail navigation works
- Historical data accuracy

---

## 10. ⚙️ SETTINGS SCREEN TEST

### ✅ Test Cases:
- [ ] **Profile Display**: Current profile info shows
- [ ] **Inline Editing**: Can edit profile fields directly
- [ ] **Unit Preferences**: Can change KG/LB preference
- [ ] **Account Info**: Shows user account details
- [ ] **Subscription Status**: Shows current subscription (if implemented)
- [ ] **Data Export**: Export functionality works
- [ ] **Logout Button**: Logout works and clears state
- [ ] **Data Persistence**: Changes are saved immediately
- [ ] **Validation**: Profile edits are validated

---

## 11. 🚨 ERROR HANDLING TEST

### ✅ Test Cases:
- [ ] **Network Errors**: Graceful handling of connection issues
- [ ] **Invalid Inputs**: Clear error messages for bad data
- [ ] **Authentication Errors**: Proper auth error handling
- [ ] **Database Errors**: Supabase error handling
- [ ] **Retry Functionality**: Error screens have retry options
- [ ] **Offline Mode**: App works when offline (cached data)
- [ ] **Error Recovery**: Can recover from error states
- [ ] **Error Boundaries**: Widget errors don't crash app

### 🔍 What to Check:
- Error messages are user-friendly
- Retry mechanisms work
- App doesn't crash on errors
- Offline functionality (if implemented)

---

## 12. ⬅️ BACK NAVIGATION TEST

### ✅ Test Cases:
- [ ] **Browser Back**: Browser back button works correctly
- [ ] **Navigation Stack**: Proper navigation history
- [ ] **Deep Links**: Direct URLs work for all screens
- [ ] **State Preservation**: Screen state preserved on back navigation
- [ ] **Onboarding Flow**: Can't skip required onboarding steps
- [ ] **Authentication Guard**: Protected routes redirect properly
- [ ] **URL Updates**: URLs update correctly during navigation

---

## 13. 📱 RESPONSIVE DESIGN TEST

### ✅ Test Cases:
- [ ] **Mobile View**: Works on mobile screen sizes (320px+)
- [ ] **Tablet View**: Works on tablet screen sizes
- [ ] **Desktop View**: Works on desktop screen sizes
- [ ] **Touch Interactions**: Touch targets are appropriate size
- [ ] **Swipe Gestures**: Work properly on touch devices
- [ ] **Text Scaling**: Text remains readable at different sizes
- [ ] **Layout Adaptation**: UI adapts to different screen ratios

---

## 14. 💾 DATA PERSISTENCE TEST

### ✅ Test Cases:
- [ ] **Page Refresh**: State persists after page refresh
- [ ] **Browser Close/Reopen**: Returns to correct screen
- [ ] **Session Management**: User session persists appropriately
- [ ] **Profile Data**: Profile changes are saved permanently
- [ ] **Workout Data**: Workout history persists correctly
- [ ] **Authentication State**: Login state persists across sessions
- [ ] **Offline Storage**: Critical data cached locally

---

## 🎯 TESTING PRIORITY LEVELS

### 🔴 **CRITICAL (Must Fix Before Launch)**
- Authentication flow
- Core workout functionality
- Data persistence
- Navigation between main screens

### 🟡 **HIGH (Should Fix Soon)**
- Error handling
- Back navigation
- Profile setup flow
- Responsive design

### 🟢 **MEDIUM (Nice to Have)**
- Swipe gestures
- Advanced error recovery
- Performance optimizations
- Accessibility features

---

## 📝 TESTING NOTES TEMPLATE

For each test, document:
- **✅ PASS**: Feature works as expected
- **❌ FAIL**: Issue found - describe the problem
- **⚠️ PARTIAL**: Works but has minor issues
- **📝 NOTES**: Additional observations

---

## 🚀 TESTING EXECUTION PLAN

1. **Start Fresh**: Clear browser cache and localStorage
2. **Test Systematically**: Go through each screen in order
3. **Document Issues**: Note every problem found
4. **Test Edge Cases**: Try to break things
5. **Verify Fixes**: Re-test after fixes are made
6. **Cross-Browser**: Test in Chrome, Safari, Firefox
7. **Mobile Testing**: Test on actual mobile devices
