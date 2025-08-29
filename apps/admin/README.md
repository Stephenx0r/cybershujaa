# CyberShujaa Admin Panel

A comprehensive Flutter web application for managing the Mission cybersecurity learning platform.

## 🚀 Features

### **Authentication & Security**
- Secure Firebase Authentication
- Role-based access control (Admin only)
- Protected admin routes

### **Missions Management**
- ✅ Create new cybersecurity missions
- ✅ Edit existing mission details
- ✅ Delete missions with confirmation
- ✅ Publish/unpublish missions
- ✅ Set difficulty levels (Beginner, Intermediate, Advanced, Expert)
- ✅ Configure mission types (Quiz, Simulator, Terminal, etc.)
- ✅ Set XP and gem rewards
- ✅ Manage mission categories and status

### **Tracks Management**
- ✅ Create learning tracks
- ✅ Organize missions into sequential paths
- ✅ Drag & drop reordering
- ✅ Publish/unpublish tracks
- ✅ Multi-language support (English/Swahili)
- ✅ Delete tracks with confirmation

### **User Management**
- ✅ View all platform users
- ✅ Search users by name or email
- ✅ View detailed user statistics
- ✅ Monitor user progress and achievements
- ✅ Manage user roles (Admin/User)
- ✅ Reset user progress (with confirmation)
- ✅ Track user engagement metrics

### **Dashboard & Analytics**
- ✅ Overview statistics
- ✅ Recent activity monitoring
- ✅ Quick action buttons
- ✅ Real-time data updates

## 🛠️ Technical Stack

- **Frontend**: Flutter Web (Material Design 3)
- **Backend**: Firebase (Firestore + Auth)
- **State Management**: Flutter built-in state management
- **Models**: Shared Dart package (`shared_core`)
- **Deployment**: Firebase Hosting ready

## 🚀 Getting Started

### **Prerequisites**
- Flutter SDK (latest stable)
- Firebase project with Firestore and Auth enabled
- Admin user account with proper Firebase custom claims

### **Setup**
1. Clone the repository
2. Navigate to `apps/admin/`
3. Run `flutter pub get`
4. Configure Firebase options in `lib/firebase_options.dart`
5. Run `flutter run -d chrome`

### **Access**
- Navigate to the admin panel URL
- Sign in with admin credentials
- Use the sidebar navigation to access different sections

## 📱 Usage Guide

### **Creating a Mission**
1. Go to Missions page
2. Click the "+" button
3. Fill in mission details (title, description, type, difficulty)
4. Set rewards and requirements
5. Click "Create Mission"

### **Organizing Tracks**
1. Go to Tracks page
2. Create new tracks or edit existing ones
3. Drag and drop to reorder missions
4. Toggle publish status as needed

### **Managing Users**
1. Go to Users page
2. Search for specific users
3. Click on a user to view detailed stats
4. Use action buttons to manage roles or reset progress

## 🔒 Security Notes

- **Role Management**: User role changes require Cloud Functions for Firebase Auth custom claims
- **Data Access**: All operations are protected by Firestore security rules
- **Authentication**: Only users with admin claims can access the panel

## 🚀 Deployment

The admin panel is ready for production deployment to Firebase Hosting:

```bash
flutter build web
firebase deploy --only hosting
```

## 🎯 Future Enhancements

- Data export functionality
- Advanced analytics and reporting
- Bulk operations for missions and users
- Integration with external security tools
- Real-time notifications
- Audit logging

---

**Status**: ✅ **Production Ready** - All core functionality implemented and tested!
