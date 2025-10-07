# lib Folder Documentation

## 📁 Folder Structure

```
lib/
├── main.dart           # Application entry point
└── pages/              # Application pages/screens
    ├── login.dart      # Login/Authentication page
    ├── home.dart       # Home page with Google Sheets integration
    └── emaildata.dart  # Email data management and sending
```

## 📄 File Descriptions

### `main.dart`
**Purpose:** Application entry point and root widget configuration

**Key Features:**
- Initializes the Flutter application
- Configures MaterialApp with custom theme
- Sets LoginPage as the initial route
- Disables debug banner for production-ready look
- Uses Poppins font family throughout the app

**Main Components:**
- `MyApp` - Root StatelessWidget that builds the MaterialApp

---

### `pages/login.dart`
**Purpose:** User authentication and login functionality

**Key Features:**
- Custom login form with username and password fields
- Form validation with error messages
- Password visibility toggle
- Hardcoded credential authentication (Demo: vinay14/1201)
- Loading state with circular progress indicator
- Success/failure feedback via SnackBar
- Navigation to HomePage on successful login

**Main Components:**
- `LoginPage` - StatefulWidget for login screen
- `_LoginPageState` - State management for login logic

**UI Elements:**
- Lock icon header
- Username input field with person icon
- Password input field with visibility toggle
- Black-themed login button
- Responsive card layout with border styling

---

### `pages/home.dart`
**Purpose:** Google Sheets integration and spreadsheet ID input

**Key Features:**
- Google Spreadsheet ID/URL input form
- Automatic URL parsing to extract spreadsheet ID
- Form validation
- Navigation to EmailDataListPage with spreadsheet data
- Instructions for users on how to get spreadsheet ID
- Integration with Google Sheets API

**Main Components:**
- `HomePage` - StatefulWidget for home screen
- `_HomePageState` - State management for spreadsheet handling

**Google Sheets Integration:**
- API Key: Pre-configured for Google Sheets API
- Sheet Name: Defaults to 'Sheet1'
- Accepts both full URL and spreadsheet ID
- Parses URL format: `https://docs.google.com/spreadsheets/d/{ID}/edit`

**UI Elements:**
- Spreadsheet ID input field
- Instructions card with sharing guidelines
- Submit button to proceed to email list

---

### `pages/emaildata.dart`
**Purpose:** Email data management and bulk email sending functionality

**Key Features:**
- Fetches email data from Google Sheets
- Displays email list with status tracking
- Individual email sending capability
- Bulk email sending to all contacts
- CSRF token security implementation
- Real-time status updates (Pending/Sent/Failed)
- Email preview and detail view
- PHP backend integration for email delivery

**Main Components:**

#### **EmailData Model**
```dart
class EmailData {
  String email;          // Primary email(s) - supports multiple
  String emailBackup;    // Backup email address
  String subject;        // Email subject line
  String links;          // Relevant links to include
  String body;           // Email body content
  String cc;             // CC recipients - supports multiple
  String status;         // Email status: Pending/Sent/Failed
  int rowIndex;          // Row number in spreadsheet
}
```

**Helper Methods:**
- `name` - Extracts formatted name from email
- `emailList` - Parses comma/space-separated emails
- `ccList` - Parses CC recipients
- `statusColor` - Returns color based on status

#### **EmailDataListPage**
**Parameters:**
- `spreadsheetId` - Google Sheets document ID
- `apiKey` - Google Sheets API key
- `sheetName` - Name of the sheet to read
- `phpEndpoint` - PHP backend URL for sending emails

**Core Functionality:**

1. **Data Loading**
   - Fetches data from Google Sheets API
   - Parses rows into EmailData objects
   - Expected columns: Emails, Emails backup, Subject, Links, Body, CC, Status
   - Handles missing status column (defaults to 'Pending')

2. **Email Sending**
   - Individual email sending via detail view
   - Bulk sending with progress tracking
   - CSRF token security
   - 500ms delay between bulk emails to prevent server overload
   - Status update after each send attempt

3. **CSRF Security**
   - Fetches CSRF token from `/get_csrf.php`
   - Includes token in POST requests
   - 10-second timeout for token fetch
   - Fallback: continues without token if unavailable

4. **PHP Integration**
   - Default endpoint: `http://192.168.0.110/redbox/send_mail.php`
   - POST request with form data:
     - `to` - Recipient email(s)
     - `cc` - CC recipient(s)
     - `subject` - Email subject
     - `body` - Formatted email body
     - `csrf_token` - Security token

5. **Email Body Formatting**
   - Includes main body content
   - Appends relevant links if available
   - Adds backup email information if different from primary

**UI Features:**
- Pull-to-refresh functionality
- Connection test button (WiFi icon)
- Refresh button to reload data
- Send to All button for bulk operations
- Individual email cards with status badges
- Detailed email view dialog
- Progress dialogs for operations
- Success/failure feedback via SnackBars

**Status Management:**
- **Pending** (Orange) - Email not yet sent
- **Sent** (Green) - Email successfully delivered
- **Failed** (Red) - Email sending failed
- Visual status indicators with colored badges

---

## 🎨 Design System

### Color Scheme
- **Primary:** Black (`Colors.black`)
- **Background:** White (`Colors.white`)
- **Success:** Green (`Colors.green`)
- **Warning:** Orange (`Colors.orange`)
- **Error:** Red (`Colors.red`)
- **Text:** Black with Grey accents

### Typography
- **Font Family:** Poppins (all weights)
- **Title:** 24-28px, Weight 600
- **Heading:** 18-20px, Weight 600
- **Body:** 14-16px, Weight 400-500
- **Small:** 11-12px, Weight 400

### UI Components
- **Cards:** White background, black border (1px), rounded corners (4-8px)
- **Buttons:** Black background, white text, 16px vertical padding
- **Input Fields:** Black border, rounded corners (4px), focused border (2px)
- **Icons:** Outlined style, black color, size 20-60px

---

## 🔌 External Dependencies

### Google Sheets API
- **Purpose:** Fetch email data from spreadsheet
- **API Endpoint:** `https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values/{sheetName}?key={apiKey}`
- **Authentication:** API Key
- **Required Permissions:** Public read access to spreadsheet

### PHP Backend
- **Purpose:** Send emails via server
- **Endpoints:**
  - `POST /send_mail.php` - Send email
  - `GET /get_csrf.php` - Get CSRF token
- **Required Headers:** `Content-Type: application/x-www-form-urlencoded`

### Flutter Packages
- `http: ^0.13.6` - HTTP requests for API calls
- `flutter/material.dart` - Material Design components

---

## 📊 Google Sheets Setup

### Required Sheet Structure
| Column A | Column B | Column C | Column D | Column E | Column F | Column G |
|----------|----------|----------|----------|----------|----------|----------|
| Emails | Emails backup | Subject | Links | Body | CC | Status |
| email@example.com | backup@example.com | Subject line | https://... | Email content | cc@example.com | Pending |

**Column Details:**
- **Emails** (Required) - Primary recipient(s), comma/space separated
- **Emails backup** (Optional) - Backup email address
- **Subject** (Required) - Email subject line
- **Links** (Optional) - URLs to include in email
- **Body** (Required) - Main email content
- **CC** (Optional) - CC recipients, comma/space separated
- **Status** (Auto) - Email status (Pending/Sent/Failed)

### Sharing Settings
1. Open your Google Sheet
2. Click "Share" button (top right)
3. Set "Anyone with the link" → "Viewer"
4. Copy the spreadsheet ID from URL
5. Paste ID in the app's home page

---

## 🔐 Security Considerations

### Authentication
- Hardcoded credentials for demo (production: use secure backend)
- No password encryption (demo purposes only)

### CSRF Protection
- CSRF token fetched before sending emails
- Token included in POST requests
- 10-second timeout for token retrieval
- Graceful fallback if token unavailable

### API Keys
- Google Sheets API key hardcoded (production: use environment variables)
- PHP endpoint IP hardcoded (production: use secure HTTPS)

### Recommendations for Production
1. Implement OAuth2 authentication
2. Move API keys to environment variables
3. Use HTTPS for all endpoints
4. Implement rate limiting
5. Add email validation
6. Store credentials securely
7. Add logging and monitoring

---

## 🚀 Usage Flow

1. **Login**
   - User enters credentials (vinay14/1201)
   - App validates credentials
   - Redirects to HomePage on success

2. **Home**
   - User enters Google Spreadsheet ID or URL
   - App parses and validates ID
   - Navigates to EmailDataListPage

3. **Email Data**
   - App fetches data from Google Sheets
   - Displays list of emails with status
   - User can:
     - View email details
     - Send individual emails
     - Send bulk emails to all
     - Refresh data
     - Test connection

4. **Email Sending**
   - App sends POST request to PHP endpoint
   - Updates status based on response
   - Shows success/failure feedback
   - Updates local state

---

## 🛠️ Configuration

### Update PHP Endpoint
Edit `lib/pages/emaildata.dart`:
```dart
phpEndpoint: 'http://YOUR_SERVER_IP/redbox/send_mail.php'
```

### Update API Key
Edit `lib/pages/home.dart`:
```dart
apiKey: 'YOUR_GOOGLE_SHEETS_API_KEY'
```

### Update Sheet Name
Edit `lib/pages/home.dart`:
```dart
sheetName: 'YOUR_SHEET_NAME'  // Default: 'Sheet1'
```

### Update Demo Credentials
Edit `lib/pages/login.dart`:
```dart
final String _validUsername = 'your_username';
final String _validPassword = 'your_password';
```

---

## 🐛 Debugging

### Connection Test
- WiFi icon in EmailDataListPage AppBar
- Tests connection to PHP endpoint
- Shows response status and body
- Helps diagnose connection issues

### Console Logging
The app includes extensive console logging:
- Spreadsheet ID parsing
- API requests and responses
- CSRF token operations
- Email sending attempts
- Error messages

### Common Issues

1. **"Failed to load data"**
   - Check spreadsheet ID
   - Verify sharing settings
   - Confirm API key is valid

2. **"Failed to send email"**
   - Check PHP endpoint URL
   - Verify server is running
   - Test connection using WiFi icon
   - Check CSRF token

3. **"Invalid credentials"**
   - Verify username and password
   - Default: vinay14/1201

---

## 📝 Future Enhancements

- [ ] OAuth2 authentication
- [ ] Environment-based configuration
- [ ] Offline mode with local storage
- [ ] Email templates
- [ ] Attachment support
- [ ] Email scheduling
- [ ] Analytics dashboard
- [ ] Multi-language support
- [ ] Dark mode theme
- [ ] Export functionality
- [ ] Advanced filtering and search
- [ ] Email history tracking

---

## 📄 License

This code is part of the RedBox project. Please refer to the main repository for licensing information.

---

## 👨‍💻 Developer Notes

### Code Style
- Uses `const` constructors for optimization
- Follows Flutter/Dart style guide
- Comprehensive error handling
- Async/await for asynchronous operations
- StatefulWidget for dynamic UI

### State Management
- Currently using setState (simple approach)
- Consider Provider/Riverpod for larger scale
- Local state for UI components
- API data cached in state

### Performance
- Efficient list rendering with ListView.builder
- Debounced network requests
- Loading states for better UX
- Minimal rebuilds with const widgets

---

For questions or issues, please contact the development team or create an issue in the repository.
