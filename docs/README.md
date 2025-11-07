# HEAVYWEIGHT Documentation

## 📋 Documentation Overview

This documentation suite provides comprehensive coverage of the HEAVYWEIGHT app architecture, development practices, and operational procedures.

### 📚 Documentation Structure

| Document | Purpose | Audience |
|----------|---------|----------|
| **[ARCHITECTURE.md](./ARCHITECTURE.md)** | System design, patterns, and component overview | All developers |
| **[API_REFERENCE.md](./API_REFERENCE.md)** | Detailed API documentation with examples | Developers, integrators |
| **[DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)** | Setup, workflow, and coding standards | New developers |
| **[SUPABASE_SCHEMA.md](./SUPABASE_SCHEMA.md)** | Complete database schema, RPC functions, and RLS policies | Backend developers, DBAs |
| **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)** | Common issues and solutions | All team members |

---

## 🚀 Quick Start

### For New Developers
1. Read [ARCHITECTURE.md](./ARCHITECTURE.md) to understand the system
2. Follow [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md) for setup
3. Study [SUPABASE_SCHEMA.md](./SUPABASE_SCHEMA.md) for database structure
4. Reference [API_REFERENCE.md](./API_REFERENCE.md) while coding
5. Keep [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) handy for issues

### For Existing Team Members
- **Adding Features**: Check architecture patterns in [ARCHITECTURE.md](./ARCHITECTURE.md)
- **Database Changes**: Follow schema in [SUPABASE_SCHEMA.md](./SUPABASE_SCHEMA.md)
- **API Changes**: Update [API_REFERENCE.md](./API_REFERENCE.md)
- **Bug Fixes**: Document solutions in [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
- **Process Updates**: Maintain [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)

---

## 🏗️ System Architecture Summary

### Core Components
```
┌─────────────────┐
│   Presentation  │ ← Screens, Widgets, ViewModels
├─────────────────┤
│    Business     │ ← Workout Engine, Training Logic
├─────────────────┤
│      Data       │ ← Repositories, APIs, Local Storage
├─────────────────┤
│   Infrastructure│ ← Supabase, SharedPreferences
└─────────────────┘
```

### Key Features
- **4-6 Rep Mandate System**: Adaptive weight progression
- **Cross-Device Sync**: Training state and calibration data
- **Performance Optimization**: Sub-1-second assignment loading
- **Graceful Degradation**: Multiple fallback layers
- **Comprehensive Testing**: Unit, integration, and performance tests

### Technology Stack
- **Frontend**: Flutter/Dart with Provider state management
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **Database**: 8 tables with RLS policies and 2 performance RPC functions
- **Local Storage**: SharedPreferences for offline capability
- **Testing**: flutter_test with comprehensive mocking

### Database Architecture
```
Core Tables:
├── exercises (Big Six movements)
├── workouts (user sessions)  
├── sets (individual exercise data)
├── profiles (user preferences)
└── workout_days + day_exercises (5-day rotation)

Cross-Device Sync:
├── calibration_resume (resume calibration across devices)
└── user_training_state (sticky day persistence & streaks)

Performance Features:
├── hw_last_for_exercises_by_slug() RPC
├── hw_last_for_exercises() RPC (fallback)
└── Comprehensive indexes for fast queries
```

---

## 📊 Performance Metrics

### Current Benchmarks
| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Assignment Screen Load | <1s | <1s | ✅ |
| Database Query Count | <5 per operation | 1-2 | ✅ |
| App Build Time | <30s | ~25s | ✅ |
| Test Suite Execution | <60s | ~45s | ✅ |

### Optimization Features
- **Batch RPC Functions**: Eliminate N+1 query patterns
- **Exercise ID Caching**: Reduce database roundtrips
- **Slug-Based Lookups**: Skip ID mapping overhead
- **Optimistic Updates**: Immediate UI feedback

---

## 🔧 Development Workflow

### Standard Process
```bash
# 1. Feature branch
git checkout -b feature/new-feature

# 2. Write tests first (TDD)
flutter test test/path/to/feature_test.dart

# 3. Implement feature
# Edit files...

# 4. Verify build
flutter build ios --no-codesign

# 5. Commit and push
git commit -m "feat: add new feature"
```

### Quality Gates
- [ ] All tests pass
- [ ] Build succeeds
- [ ] Performance targets met
- [ ] Documentation updated
- [ ] Code review approved

---

## 🧪 Testing Strategy

### Test Pyramid
```
     ┌──────────────┐
     │  UI Tests    │ ← Screens, user flows
     └──────────────┘
    ┌────────────────┐
    │ Integration    │ ← Repository, RPC functions
    └────────────────┘
   ┌──────────────────┐
   │   Unit Tests     │ ← Business logic, calculations
   └──────────────────┘
```

### Coverage Goals
- **Unit Tests**: >90% coverage of business logic
- **Integration Tests**: All repository operations
- **Performance Tests**: Critical user paths <1s
- **Widget Tests**: Key user interactions

---

## 🔒 Security & Best Practices

### Database Security
- **Row Level Security (RLS)**: All tables filtered by `auth.uid()`
- **RPC Functions**: `SECURITY DEFINER` with controlled access
- **Input Validation**: Parameterized queries prevent injection

### Flutter Best Practices
- **Null Safety**: All nullable types handled explicitly
- **const Constructors**: Performance optimization
- **Provider Pattern**: Predictable state management
- **Error Boundaries**: Graceful failure handling

### Data Protection
- **Local Encryption**: Sensitive data protected at rest
- **Network Security**: HTTPS/TLS for all communications
- **Authentication**: Supabase Auth with JWT tokens
- **Audit Logging**: All operations tracked for compliance

---

## 📈 Monitoring & Observability

### Logging Strategy
```dart
// Structured event logging
HWLog.event('operation_name', data: {
  'context': 'relevant_context',
  'metrics': 'performance_data',
  'success': true,
});
```

### Key Metrics
- **Performance**: Operation timing and throughput
- **Errors**: Exception rates and patterns
- **Usage**: Feature adoption and user flows
- **System Health**: Database performance and availability

### Debug Tools
- **Status Screen**: Real-time app state inspection
- **Performance Profiler**: Operation timing analysis
- **Error Dashboard**: Exception tracking and trends

---

## 🚨 Incident Response

### Severity Levels
1. **Critical**: App crashes, data loss
2. **High**: Performance degradation, feature broken
3. **Medium**: Minor bugs, UI issues
4. **Low**: Enhancement requests, documentation

### Response Procedures
1. **Assess Impact**: How many users affected?
2. **Immediate Action**: Rollback or hotfix if needed
3. **Root Cause Analysis**: Identify underlying issue
4. **Prevention**: Update processes to prevent recurrence
5. **Communication**: Update stakeholders and users

### Recovery Procedures
- **Data Recovery**: Multi-source restoration strategies
- **Performance Recovery**: Cache clearing and optimization
- **System Recovery**: Database and infrastructure restoration

---

## 🔄 Maintenance Schedule

### Regular Tasks
- **Weekly**: Dependency updates and security patches
- **Monthly**: Performance analysis and optimization
- **Quarterly**: Architecture review and refactoring
- **Annually**: Major version upgrades and migrations

### Monitoring Checklist
- [ ] Database performance metrics
- [ ] App store ratings and reviews
- [ ] User feedback and support tickets
- [ ] Security vulnerability scanning
- [ ] Test coverage and quality metrics

---

## 📞 Support & Contact

### Development Team
- **Architecture Questions**: See [ARCHITECTURE.md](./ARCHITECTURE.md) or ask in #architecture
- **API Usage**: Check [API_REFERENCE.md](./API_REFERENCE.md) or ask in #development
- **Setup Issues**: Follow [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md) or ask in #onboarding
- **Bug Reports**: Use [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) or file GitHub issue

### Emergency Contacts
- **Production Issues**: #emergency-response channel
- **Security Incidents**: security@heavyweight.app
- **Data Issues**: #data-recovery channel

---

## 🎯 Future Roadmap

### Version 1.1 (Post-Launch)
- [ ] Social features and community
- [ ] Advanced analytics dashboard
- [ ] Exercise video integration
- [ ] Nutrition tracking integration

### Version 2.0 (Future)
- [ ] AI-powered workout recommendations
- [ ] Wearable device integration
- [ ] Virtual coaching features
- [ ] Global leaderboards and challenges

### Technical Debt
- [ ] Migration to latest Flutter version
- [ ] Enhanced error handling patterns
- [ ] Real-time synchronization
- [ ] Advanced caching strategies

---

## 📝 Contributing

### Documentation Updates
1. **Edit Markdown**: Update relevant .md files
2. **Test Links**: Verify all internal links work
3. **Review Changes**: Ensure accuracy and clarity
4. **Submit PR**: Follow standard review process

### Documentation Standards
- **Clear Structure**: Use headings and bullets
- **Code Examples**: Include working code snippets
- **Cross-References**: Link between related documents
- **Keep Current**: Update with code changes

---

*This documentation is actively maintained and updated with each release.*
*For questions or suggestions, contact the development team.*

**Last Updated**: 2025-09-15  
**Version**: 1.0.0  
**Next Review**: 2025-10-15