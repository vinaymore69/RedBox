# lib Folder - Comprehensive Technical Documentation

## 📁 Complete Folder Structure

```
lib/
├── main.dart           # Application entry point & app-wide configuration
└── pages/              # Feature-based screen modules
    ├── login.dart      # Authentication & user validation screen
    ├── home.dart       # Google Sheets integration & ID input screen
    └── emaildata.dart  # Email management, display & bulk sending screen
```

---

# 📄 Detailed File Analysis

## 1. `main.dart` - Application Bootstrap

### Purpose
The root entry point that initializes the Flutter application and configures global app settings.

### Complete Functionality

#### **Application Initialization**
```dart
void main() {
  runApp(const MyApp());
}
```
- Executes `runApp()` which inflates the widget tree
- Creates the root widget (`MyApp`)
- Binds the widget tree to the screen

#### **Root Widget Configuration**
```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RedBox',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}
```

**Configuration Details:**

1. **Debug Banner**
   - `debugShowCheckedModeBanner: false` - Removes the "DEBUG" ribbon from top-right corner
   - Makes the app look production-ready during development

2. **App Title**
   - `title: 'RedBox'` - Sets window title (visible in browser tabs, task managers)
   - Used by operating system for window management

3. **Theme Configuration**
   - `fontFamily: 'Poppins'` - Sets global font for all text widgets
   - Requires Poppins font defined in `pubspec.yaml`
   - Overrides default Roboto font on Android/Material Design

4. **Initial Route**
   - `home: const LoginPage()` - First screen user sees
   - Navigation stack starts here
   - `const` constructor for compile-time optimization

### Design Decisions
- **StatelessWidget**: Root doesn't need state management
- **Const Constructor**: Improves performance by creating widgets at compile-time
- **Material Design**: Uses MaterialApp for Android/cross-platform consistency

---

## 2. `pages/login.dart` - Authentication Module

### Purpose
Handles user authentication with form validation, credential verification, and navigation to the home screen.

### Complete Functionality Breakdown

#### **State Management**
```dart
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  
  @override
  State<LoginPage> createState() => _LoginPageState();
}
```
- **StatefulWidget**: Required for managing form state, loading states, and user interactions
- Creates mutable state object `_LoginPageState`

#### **Private State Variables**
```dart
class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  
  // Hardcoded credentials (demo purposes)
  final String _validUsername = 'vinay14';
  final String _validPassword = '1201';
```

**Variable Purposes:**

1. **`_formKey`**
   - Type: `GlobalKey<FormState>`
   - Purpose: Uniquely identifies the form and provides access to form validation methods
   - Usage: `_formKey.currentState!.validate()` triggers all field validators

2. **`_usernameController` & `_passwordController`**
   - Type: `TextEditingController`
   - Purpose: Manages text input state for username and password fields
   - Methods:
     - `.text` - Gets current text value
     - `.clear()` - Clears the field
     - `.dispose()` - Cleans up controller when widget is destroyed

3. **`_isPasswordVisible`**
   - Type: `bool` (default: `false`)
   - Purpose: Toggles password visibility
   - Controls: `obscureText` property of password field
   - Changes when user taps the eye icon

4. **`_isLoading`**
   - Type: `bool` (default: `false`)
   - Purpose: Prevents multiple simultaneous login attempts
   - Shows: Circular progress indicator during login process
   - Disables: Login button when `true`

#### **Login Logic Flow**

```dart
void _handleLogin() async {
  // Step 1: Validate form fields
  if (_formKey.currentState!.validate()) {
    // Step 2: Set loading state
    setState(() {
      _isLoading = true;
    });

    // Step 3: Simulate network delay (500ms)
    await Future.delayed(const Duration(milliseconds: 500));

    // Step 4: Check credentials
    if (_usernameController.text == _validUsername &&
        _passwordController.text == _validPassword) {
      
      // SUCCESS PATH
      setState(() {
        _isLoading = false;
      });
      
      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate to home (replace current screen)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
      
    } else {
      // FAILURE PATH
      setState(() {
        _isLoading = false;
      });
      
      // Show error message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid credentials!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

**Step-by-Step Execution:**

1. **Form Validation** (`_formKey.currentState!.validate()`)
   - Triggers validator functions for all TextFormFields
   - Returns `true` only if all validators return `null`
   - Shows error messages for invalid fields

2. **Loading State Activation**
   - Sets `_isLoading = true`
   - Triggers rebuild showing CircularProgressIndicator
   - Disables login button to prevent double-submission

3. **Simulated Delay**
   - `Future.delayed(500ms)` simulates network latency
   - Provides realistic user experience
   - In production: replace with actual API call

4. **Credential Verification**
   - Compares input with hardcoded values
   - Case-sensitive comparison
   - No encryption (demo only - INSECURE for production)

5. **Success Handling**
   - Stops loading indicator
   - Shows green SnackBar with success message
   - Uses `Navigator.pushReplacement()` to prevent back navigation to login
   - Removes login page from navigation stack

6. **Failure Handling**
   - Stops loading indicator
   - Shows red SnackBar with error message
   - Keeps user on login page for retry

#### **Form Validation Rules**

**Username Field:**
```dart
TextFormField(
  controller: _usernameController,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    return null;
  },
)
```
- **Required field validation**
- Checks for `null` or empty string
- Returns error message if invalid
- Returns `null` if valid (allows form submission)

**Password Field:**
```dart
TextFormField(
  controller: _passwordController,
  obscureText: !_isPasswordVisible,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  },
)
```
- **Required field validation**
- `obscureText` hides/shows password characters
- Toggles based on `_isPasswordVisible` state
- Eye icon toggles visibility

#### **UI Components Breakdown**

**1. App Bar**
```dart
AppBar(
  title: const Text(
    'Login',
    style: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 20,
    ),
  ),
  centerTitle: true,
  backgroundColor: Colors.white,
  foregroundColor: Colors.black,
  elevation: 0,
)
```
- **Flat design**: `elevation: 0` removes shadow
- **Centered title**: Professional look
- **Custom styling**: White background, black text
- **Font weight**: Semi-bold (600) for emphasis

**2. Lock Icon Header**
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    border: Border.all(color: Colors.black, width: 2),
    shape: BoxShape.circle,
  ),
  child: const Icon(
    Icons.lock_outline,
    size: 60,
    color: Colors.black,
  ),
)
```
- **Purpose**: Visual authentication indicator
- **Circular border**: 2px black outline
- **Large icon**: 60px for prominence
- **Outlined style**: Matches app design language

**3. Form Card**
```dart
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.black, width: 1),
  ),
  child: Form(key: _formKey, child: ...),
)
```
- **Full width**: `double.infinity` ensures responsiveness
- **Padding**: 24px internal spacing for readability
- **Border**: 1px black outline for definition
- **Rounded corners**: 8px radius for modern look

**4. Login Button**
```dart
SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: _isLoading ? null : _handleLogin,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    child: _isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : const Text(
            'Login',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
  ),
)
```

**Button State Management:**
- **Disabled state**: `onPressed: null` when loading
- **Loading indicator**: 20x20px white spinner
- **Full width**: Matches form card width
- **Visual feedback**: User knows action is processing

#### **Memory Management**
```dart
@override
void dispose() {
  _usernameController.dispose();
  _passwordController.dispose();
  super.dispose();
}
```
- **Critical cleanup**: Prevents memory leaks
- **Controller disposal**: Removes listeners and frees memory
- **Called automatically**: When widget is removed from tree

### Security Analysis

⚠️ **Current Implementation (Demo Only):**
- Hardcoded credentials in source code
- No encryption of password
- No secure storage
- Visible credentials in compiled app

✅ **Production Recommendations:**
- Implement OAuth2 or JWT authentication
- Use HTTPS endpoints for credential verification
- Store tokens securely (flutter_secure_storage)
- Add biometric authentication
- Implement password hashing (bcrypt, argon2)
- Add rate limiting for failed attempts
- Implement session management
- Add 2FA support

---

## 3. `pages/home.dart` - Google Sheets Integration Module

### Purpose
Provides interface for users to input Google Spreadsheet ID/URL and validates it before navigating to the email management screen.

### Complete Functionality Breakdown

#### **State Management**
```dart
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _spreadsheetController = TextEditingController();
  final String apiKey = 'AIzaSyBiH6h61tA1Uz8x4J-RxlVpzWo0v9qcI0M';
  final String sheetName = 'Sheet1';
```

**Configuration Variables:**

1. **`apiKey`**
   - **Type**: Google Cloud API Key
   - **Purpose**: Authenticates requests to Google Sheets API v4
   - **Permissions**: Read-only access to public spreadsheets
   - **Format**: 39-character alphanumeric string
   - **Security**: Should be moved to environment variables in production

2. **`sheetName`**
   - **Type**: String
   - **Default**: `'Sheet1'`
   - **Purpose**: Specifies which sheet tab to read from
   - **Behavior**: Must match exact sheet name (case-sensitive)
   - **Flexibility**: Can be changed to read different sheets

#### **Spreadsheet ID Extraction Logic**

```dart
String? _extractSpreadsheetId(String input) {
  String trimmedInput = input.trim();
  
  // Check if input is a full URL
  if (trimmedInput.contains('docs.google.com/spreadsheets')) {
    // Extract ID from URL pattern
    final RegExp regex = RegExp(r'/d/([a-zA-Z0-9-_]+)');
    final match = regex.firstMatch(trimmedInput);
    
    if (match != null && match.groupCount >= 1) {
      String extractedId = match.group(1)!;
      print('Extracted Spreadsheet ID: $extractedId');
      return extractedId;
    }
  }
  
  // If not URL, assume it's already the ID
  print('Using input as Spreadsheet ID: $trimmedInput');
  return trimmedInput;
}
```

**Extraction Algorithm:**

1. **Input Sanitization**
   - `trim()` removes leading/trailing whitespace
   - Prevents validation errors from accidental spaces

2. **URL Detection**
   - Checks for substring: `'docs.google.com/spreadsheets'`
   - Identifies Google Sheets URLs vs raw IDs

3. **Regex Pattern Matching**
   - **Pattern**: `/d/([a-zA-Z0-9-_]+)`
   - **Captures**: Spreadsheet ID from URL structure
   - **URL Format**: `https://docs.google.com/spreadsheets/d/{SPREADSHEET_ID}/edit#gid=0`
   - **Example Match**: 
     - Input: `https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit`
     - Extracted: `1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms`

4. **ID Validation**
   - If URL: extracts ID from capture group
   - If not URL: treats entire input as ID
   - Returns `null` if extraction fails

**Supported Input Formats:**

✅ **Full URL:**
```
https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit
```

✅ **URL with GID:**
```
https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit#gid=0
```

✅ **Raw Spreadsheet ID:**
```
1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms
```

✅ **URL with Additional Parameters:**
```
https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit?usp=sharing
```

#### **Form Validation**

```dart
TextFormField(
  controller: _spreadsheetController,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Spreadsheet ID or URL';
    }
    return null;
  },
  decoration: InputDecoration(
    labelText: 'Spreadsheet ID or URL',
    hintText: 'Enter ID or paste URL',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: Colors.black, width: 1),
    ),
  ),
)
```

**Validation Rules:**
- **Required field**: Cannot be empty or null
- **No format validation**: Accepts any non-empty string
- **Flexible input**: Works with URLs or IDs
- **Error display**: Shows inline error message below field

#### **Submit Handler**

```dart
void _handleSubmit() {
  if (_formKey.currentState!.validate()) {
    String? spreadsheetId = _extractSpreadsheetId(_spreadsheetController.text);
    
    if (spreadsheetId != null && spreadsheetId.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmailDataListPage(
            spreadsheetId: spreadsheetId,
            apiKey: apiKey,
            sheetName: sheetName,
            phpEndpoint: 'http://192.168.0.110/redbox/send_mail.php',
          ),
        ),
      );
    } else {
      // Show error if extraction failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Spreadsheet ID or URL'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

**Execution Flow:**

1. **Trigger Validation**
   - Calls form validator
   - Checks all form fields
   - Returns `false` if any field invalid

2. **Extract Spreadsheet ID**
   - Calls `_extractSpreadsheetId()`
   - Handles both URL and ID formats
   - Returns extracted ID or null

3. **Validation Check**
   - Verifies ID is not null or empty
   - Ensures extraction was successful

4. **Navigation (Success Path)**
   - Uses `Navigator.push()` (allows back navigation)
   - Creates new `MaterialPageRoute`
   - Passes required parameters:
     - `spreadsheetId` - Extracted ID
     - `apiKey` - Google Sheets API key
     - `sheetName` - Target sheet name
     - `phpEndpoint` - Email sending server URL
   - Navigates to `EmailDataListPage`

5. **Error Handling (Failure Path)**
   - Shows red SnackBar
   - Displays error message
   - Keeps user on current page
   - Allows user to correct input

#### **UI Components**

**1. Instructions Card**
```dart
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.grey.shade50,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.grey.shade300),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'How to get your Spreadsheet ID:',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        '1. Open your Google Sheet\n'
        '2. Click "Share" → Set to "Anyone with link"\n'
        '3. Copy the ID from the URL or paste the entire URL',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    ],
  ),
)
```

**Purpose**: User guidance
- Step-by-step instructions
- Explains sharing requirements
- Shows URL structure example
- Reduces user confusion

**2. Input Form Card**
```dart
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.black, width: 1),
  ),
  child: Form(
    key: _formKey,
    child: Column(
      children: [
        // Spreadsheet ID input field
        // Submit button
      ],
    ),
  ),
)
```

**3. Submit Button**
```dart
SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: _handleSubmit,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
    ),
    child: const Text('Submit'),
  ),
)
```

#### **Google Sheets API Integration**

**API Endpoint Construction:**
```
https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values/{sheetName}?key={apiKey}
```

**Example Request:**
```
https://sheets.googleapis.com/v4/spreadsheets/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/values/Sheet1?key=AIzaSyBiH6h61tA1Uz8x4J-RxlVpzWo0v9qcI0M
```

**Required Spreadsheet Permissions:**
- **Sharing**: "Anyone with the link" can view
- **Access Level**: Viewer (read-only)
- **No authentication**: Public access via API key

**API Response Format** (handled in `emaildata.dart`):
```json
{
  "range": "Sheet1!A1:Z1000",
  "majorDimension": "ROWS",
  "values": [
    ["Emails", "Emails backup", "Subject", "Links", "Body", "CC", "Status"],
    ["user@example.com", "backup@example.com", "Hello", "https://...", "Body text", "cc@example.com", "Pending"]
  ]
}
```

### Error Scenarios

| Scenario | Detection | User Feedback |
|----------|-----------|---------------|
| Empty input | Form validator | Inline error message |
| Invalid URL format | Regex fails | Red SnackBar |
| Private spreadsheet | API call fails (in next screen) | Connection error |
| Invalid API key | API call fails | HTTP 400/403 error |
| Non-existent sheet | API call fails | "Sheet not found" error |

---

## 4. `pages/emaildata.dart` - Email Management & Sending Module

### Purpose
The core functionality module that fetches email data from Google Sheets, displays it in a structured list, manages email status, and handles individual/bulk email sending operations.

### Complete Architecture

#### **Data Model: EmailData Class**

```dart
class EmailData {
  String email;          // Primary recipient(s)
  String emailBackup;    // Backup/alternative email
  String subject;        // Email subject line
  String links;          // Relevant links to include
  String body;           // Main email content
  String cc;             // CC recipients
  String status;         // Current status: Pending/Sent/Failed
  int rowIndex;          // Row number in spreadsheet (for updates)

  EmailData({
    required this.email,
    required this.emailBackup,
    required this.subject,
    required this.links,
    required this.body,
    required this.cc,
    required this.status,
    required this.rowIndex,
  });
}
```

**Field Specifications:**

1. **`email`** (Primary Recipients)
   - **Format**: Single email or comma/space-separated list
   - **Examples**: 
     - `user@example.com`
     - `user1@example.com, user2@example.com`
     - `user1@example.com user2@example.com`
   - **Parsing**: Handled by `emailList` getter
   - **Usage**: Primary "TO" field in email

2. **`emailBackup`** (Backup Email)
   - **Purpose**: Alternative contact if primary fails
   - **Display**: Shown in email body as reference
   - **Usage**: Not sent to, only informational
   - **Can be empty**: Optional field

3. **`subject`** (Email Subject)
   - **Type**: Plain text string
   - **Usage**: Direct email subject line
   - **Validation**: None (can be empty)

4. **`links`** (Relevant Links)
   - **Format**: URLs separated by commas/spaces
   - **Purpose**: Reference links appended to email body
   - **Display**: Added as "Relevant Links:" section
   - **Can be empty**: Optional field

5. **`body`** (Email Content)
   - **Type**: Plain text (HTML not supported currently)
   - **Usage**: Main email message
   - **Formatting**: Line breaks preserved
   - **Required**: Should not be empty for meaningful emails

6. **`cc`** (Carbon Copy Recipients)
   - **Format**: Comma/space-separated emails
   - **Parsing**: Handled by `ccList` getter
   - **Usage**: CC field in email
   - **Can be empty**: Optional field

7. **`status`** (Email Status)
   - **Values**: 
     - `"Pending"` - Not yet sent (default)
     - `"Sent"` - Successfully delivered
     - `"Failed"` - Send attempt failed
   - **Color Coding**: 
     - Pending → Orange
     - Sent → Green
     - Failed → Red
   - **Updates**: Changed after each send attempt

8. **`rowIndex`** (Spreadsheet Row)
   - **Type**: Integer (1-based index)
   - **Purpose**: Maps to Google Sheets row number
   - **Usage**: For future status update functionality
   - **Example**: Row 2 has `rowIndex = 2`

#### **Helper Methods**

**1. Name Extraction**
```dart
String get name {
  if (email.isEmpty) return 'No Email';
  
  String firstEmail = email.split(RegExp(r'[,\s]+')).first.trim();
  String namePart = firstEmail.split('@').first;
  
  return namePart
      .split('.')
      .map((part) => part.isNotEmpty 
          ? '${part[0].toUpperCase()}${part.substring(1)}' 
          : '')
      .join(' ');
}
```

**Functionality:**
- Extracts display name from first email address
- **Example Transformations**:
  - `john.doe@example.com` → `John Doe`
  - `alice_smith@company.com` → `Alice_smith` (underscores preserved)
  - `user123@domain.com` → `User123`
  - `first.middle.last@email.com` → `First Middle Last`

**Algorithm:**
1. Extract first email from comma/space-separated list
2. Get username part (before @)
3. Split by dots (.)
4. Capitalize first letter of each part
5. Join with spaces

**2. Email List Parser**
```dart
List<String> get emailList {
  if (email.isEmpty) return [];
  return email
      .split(RegExp(r'[,\s]+'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}
```

**Functionality:**
- Converts comma/space-separated string to list
- **Handles**:
  - Multiple delimiters: `, ` `  ` `,`
  - Extra whitespace
  - Empty strings
- **Example**: `"user1@x.com, user2@y.com user3@z.com"` → `["user1@x.com", "user2@y.com", "user3@z.com"]`

**3. CC List Parser**
```dart
List<String> get ccList {
  if (cc.isEmpty) return [];
  return cc
      .split(RegExp(r'[,\s]+'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}
```
- Identical to `emailList` but for CC field
- Returns empty list if no CC recipients

**4. Status Color Mapper**
```dart
Color get statusColor {
  switch (status.toLowerCase()) {
    case 'sent':
      return Colors.green;
    case 'failed':
      return Colors.red;
    case 'pending':
    default:
      return Colors.orange;
  }
}
```
- Case-insensitive matching
- Defaults to orange for unknown statuses
- Used for visual status badges

---

#### **Main Widget: EmailDataListPage**

```dart
class EmailDataListPage extends StatefulWidget {
  final String spreadsheetId;
  final String apiKey;
  final String sheetName;
  final String phpEndpoint;

  const EmailDataListPage({
    super.key,
    required this.spreadsheetId,
    required this.apiKey,
    this.sheetName = 'Sheet1',
    this.phpEndpoint = 'http://192.168.0.110/redbox/send_mail.php',
  });

  @override
  State<EmailDataListPage> createState() => _EmailDataListPageState();
}
```

**Constructor Parameters:**

| Parameter | Type | Required | Default | Purpose |
|-----------|------|----------|---------|---------|
| `spreadsheetId` | String | ✅ Yes | - | Google Sheets document ID |
| `apiKey` | String | ✅ Yes | - | Google Sheets API key |
| `sheetName` | String | ❌ No | `'Sheet1'` | Sheet tab name to read |
| `phpEndpoint` | String | ❌ No | Local server | Email sending backend URL |

---

#### **State Variables**

```dart
class _EmailDataListPageState extends State<EmailDataListPage> {
  List<EmailData> _emailData = [];
  bool _isLoading = true;
  String? _csrfToken;
  bool _isSendingAll = false;
```

**Variable Purposes:**

1. **`_emailData`**
   - **Type**: `List<EmailData>`
   - **Initial**: Empty list `[]`
   - **Updates**: After successful API fetch
   - **Usage**: Data source for ListView.builder

2. **`_isLoading`**
   - **Type**: `bool`
   - **Initial**: `true` (shows loading spinner)
   - **Changes**: 
     - `false` after data loads successfully
     - `false` after error
   - **Controls**: Loading indicator visibility

3. **`_csrfToken`**
   - **Type**: `String?` (nullable)
   - **Initial**: `null`
   - **Fetched**: During `initState()` or before sending
   - **Purpose**: CSRF protection for email sending
   - **Fallback**: Continues without token if unavailable

4. **`_isSendingAll`**
   - **Type**: `bool`
   - **Initial**: `false`
   - **Changes**: 
     - `true` during bulk send operation
     - `false` after completion
   - **Purpose**: Prevents concurrent bulk operations
   - **UI Effect**: Disables "Send to All" button

---

#### **Initialization Flow**

```dart
@override
void initState() {
  super.initState();
  _fetchCSRFToken();
  _loadData();
}
```

**Execution Order:**
1. **CSRF Token Fetch** (asynchronous, non-blocking)
2. **Data Load** (asynchronous, shows loading UI)

---

#### **CSRF Token Management**

**Purpose**: Protects against Cross-Site Request Forgery attacks

```dart
Future<void> _fetchCSRFToken() async {
  try {
    final uri = Uri.parse(widget.phpEndpoint).replace(
      path: '/redbox/get_csrf.php',
    );
    
    final response = await http.get(uri).timeout(
      const Duration(seconds: 10),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _csrfToken = data['csrf_token'];
      });
      print('CSRF Token fetched: $_csrfToken');
    } else {
      print('Failed to fetch CSRF token: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching CSRF token: $e');
    // Continue without token - server may not require it
  }
}
```

**Detailed Flow:**

1. **Endpoint Construction**
   - Base URL: From `widget.phpEndpoint`
   - Path replacement: `/redbox/get_csrf.php`
   - Example: `http://192.168.0.110/redbox/get_csrf.php`

2. **HTTP GET Request**
   - **Method**: GET
   - **Timeout**: 10 seconds
   - **Headers**: None required

3. **Success Response (200)**
   ```json
   {
     "csrf_token": "a1b2c3d4e5f6..."
   }
   ```
   - Parses JSON response
   - Stores token in `_csrfToken` state
   - Logs token to console

4. **Error Handling**
   - **Non-200 status**: Logs error, continues without token
   - **Timeout**: Caught by catch block
   - **Network error**: Caught by catch block
   - **Parsing error**: Caught by catch block

5. **Fallback Behavior**
   - App continues functioning without token
   - Server may accept requests without CSRF protection
   - Logs error for debugging

**Security Note**: Token should be refreshed periodically and validated on server

---

#### **Data Loading from Google Sheets**

```dart
Future<void> _loadData() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // Step 1: Construct API URL
    final url =
        'https://sheets.googleapis.com/v4/spreadsheets/${widget.spreadsheetId}/values/${widget.sheetName}?key=${widget.apiKey}';
    
    // Step 2: Make HTTP GET request
    final response = await http.get(Uri.parse(url));

    // Step 3: Check response status
    if (response.statusCode == 200) {
      // Step 4: Parse JSON response
      final data = json.decode(response.body);
      final List<dynamic> rows = data['values'] ?? [];

      // Step 5: Validate data structure
      if (rows.isEmpty) {
        throw Exception('No data found in spreadsheet');
      }

      // Step 6: Extract header row
      final headerRow = rows[0] as List<dynamic>;
      
      // Step 7: Find column indices
      int emailIndex = headerRow.indexOf('Emails');
      int emailBackupIndex = headerRow.indexOf('Emails backup');
      int subjectIndex = headerRow.indexOf('Subject');
      int linksIndex = headerRow.indexOf('Links');
      int bodyIndex = headerRow.indexOf('Body');
      int ccIndex = headerRow.indexOf('CC');
      int statusIndex = headerRow.indexOf('Status');

      // Step 8: Validate required columns
      if (emailIndex == -1 || subjectIndex == -1 || bodyIndex == -1) {
        throw Exception('Required columns missing');
      }

      // Step 9: Parse data rows
      List<EmailData> emailList = [];
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i] as List<dynamic>;
        
        emailList.add(EmailData(
          email: emailIndex != -1 && row.length > emailIndex
              ? row[emailIndex].toString()
              : '',
          emailBackup: emailBackupIndex != -1 && row.length > emailBackupIndex
              ? row[emailBackupIndex].toString()
              : '',
          subject: subjectIndex != -1 && row.length > subjectIndex
              ? row[subjectIndex].toString()
              : '',
          links: linksIndex != -1 && row.length > linksIndex
              ? row[linksIndex].toString()
              : '',
          body: bodyIndex != -1 && row.length > bodyIndex
              ? row[bodyIndex].toString()
              : '',
          cc: ccIndex != -1 && row.length > ccIndex
              ? row[ccIndex].toString()
              : '',
          status: statusIndex != -1 && row.length > statusIndex
              ? row[statusIndex].toString()
              : 'Pending',
          rowIndex: i + 1, // 1-based row number
        ));
      }

      // Step 10: Update state
      setState(() {
        _emailData = emailList;
        _isLoading = false;
      });

    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error loading data: $e');
    setState(() {
      _isLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

**Step-by-Step Breakdown:**

**Step 1-2: API Request Construction**
- **Endpoint**: Google Sheets API v4
- **Format**: `https://sheets.googleapis.com/v4/spreadsheets/{ID}/values/{SHEET}?key={KEY}`
- **Example**: `https://sheets.googleapis.com/v4/spreadsheets/1BxiM.../values/Sheet1?key=AIzaSy...`

**Step 3: Response Validation**
- **200**: Success, proceed to parse
- **400**: Bad request (invalid parameters)
- **403**: Forbidden (API key invalid or quota exceeded)
- **404**: Spreadsheet/sheet not found

**Step 4-5: JSON Parsing**
```json
{
  "range": "Sheet1!A1:Z1000",
  "majorDimension": "ROWS",
  "values": [
    ["Emails", "Emails backup", "Subject", "Links", "Body", "CC", "Status"],
    ["user@example.com", "backup@example.com", "Test", "http://...", "Hello", "cc@example.com", "Pending"]
  ]
}
```
- Extracts `values` array
- First element is header row
- Remaining elements are data rows

**Step 6-7: Column Mapping**
- Uses `indexOf()` to find column positions
- Handles dynamic column order
- Returns `-1` if column not found

**Expected Sheet Structure:**
| A | B | C | D | E | F | G |
|---|---|---|---|---|---|---|
| Emails | Emails backup | Subject | Links | Body | CC | Status |
| user@x.com | backup@x.com | Hello | https://... | Message | cc@x.com | Pending |

**Step 8: Required Column Validation**
- **Required**: Emails, Subject, Body
- **Optional**: Emails backup, Links, CC, Status
- **Failure**: Throws exception if required columns missing

**Step 9: Row Parsing Logic**
- Starts from index 1 (skips header)
- Checks if column exists (`emailIndex != -1`)
- Checks if row has enough columns (`row.length > emailIndex`)
- Converts cell value to string
- Defaults to empty string if column missing
- Defaults to "Pending" if status column missing
- Stores 1-based row number for future updates

**Step 10: State Update**
- Updates `_emailData` with parsed list
- Sets `_isLoading = false` to hide spinner
- Triggers widget rebuild to display data

**Error Handling:**
- **Network errors**: Caught and logged
- **Parsing errors**: Caught and logged
- **User feedback**: Shows red SnackBar with error message
- **Loading state**: Always set to `false` on error

---

#### **Individual Email Sending**

```dart
Future<void> _sendEmail(EmailData email) async {
  // Step 1: Validate CSRF token
  if (_csrfToken == null) {
    await _fetchCSRFToken();
  }

  try {
    // Step 2: Construct email body
    String fullBody = email.body;
    if (email.links.isNotEmpty) {
      fullBody += '\n\nRelevant Links:\n${email.links}';
    }
    if (email.emailBackup.isNotEmpty && email.emailBackup != email.email) {
      fullBody += '\n\nBackup Email: ${email.emailBackup}';
    }

    // Step 3: Prepare form data
    final Map<String, String> formData = {
      'to': email.emailList.join(', '),
      'cc': email.ccList.join(', '),
      'subject': email.subject,
      'body': fullBody,
    };

    // Step 4: Add CSRF token if available
    if (_csrfToken != null) {
      formData['csrf_token'] = _csrfToken!;
    }

    // Step 5: Send POST request
    final response = await http.post(
      Uri.parse(widget.phpEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: formData,
    );

    // Step 6: Handle response
    if (response.statusCode == 200) {
      setState(() {
        email.status = 'Sent';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      setState(() {
        email.status = 'Failed';
      });
      
      throw Exception('Server returned ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending email: $e');
    setState(() {
      email.status = 'Failed';
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

**Detailed Execution:**

**Step 1: CSRF Token Validation**
- Checks if token exists
- Fetches new token if missing
- Waits for fetch to complete before proceeding

**Step 2: Body Construction**
- Starts with original body content
- **Appends links** (if present):
  ```
  
  Relevant Links:
  https://example.com, https://test.com
  ```
- **Appends backup email** (if different from primary):
  ```
  
  Backup Email: backup@example.com
  ```

**Example Full Body:**
```
Hello, this is the main message content.

Relevant Links:
https://docs.google.com, https://github.com

Backup Email: backup@example.com
```

**Step 3: Form Data Preparation**
```dart
{
  'to': 'user1@example.com, user2@example.com',
  'cc': 'manager@company.com',
  'subject': 'Project Update',
  'body': 'Full constructed body...',
  'csrf_token': 'a1b2c3d4...' // if available
}
```

**Step 4: CSRF Token Addition**
- Only added if token was successfully fetched
- Skipped if token is null

**Step 5: HTTP POST Request**
- **Method**: POST
- **Content-Type**: `application/x-www-form-urlencoded`
- **Encoding**: URL-encoded form data
- **Endpoint**: `widget.phpEndpoint`

**Server-Side Expected Format:**
```php
$_POST['to']         // "user1@x.com, user2@x.com"
$_POST['cc']         // "manager@x.com"
$_POST['subject']    // "Project Update"
$_POST['body']       // "Full body content..."
$_POST['csrf_token'] // "a1b2c3d4..."
```

**Step 6: Response Handling**

**Success (200):**
- Updates email status to "Sent"
- Changes status badge color to green
- Shows success SnackBar
- Email remains in list

**Failure (Non-200):**
- Updates status to "Failed"
- Changes status badge to red
- Throws exception with status code
- Shows error SnackBar

**Network/Exception Errors:**
- Updates status to "Failed"
- Logs error to console
- Shows error SnackBar with details
- Email can be retried later

---

#### **Bulk Email Sending**

```dart
Future<void> _sendAllEmails() async {
  // Step 1: Prevent concurrent bulk operations
  if (_isSendingAll) return;

  // Step 2: Filter pending emails
  final pendingEmails = _emailData.where((email) => 
    email.status.toLowerCase() == 'pending'
  ).toList();

  if (pendingEmails.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No pending emails to send'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  // Step 3: Set sending state
  setState(() {
    _isSendingAll = true;
  });

  // Step 4: Show progress dialog
  int totalEmails = pendingEmails.length;
  int sentCount = 0;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Sending Emails'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('$sentCount / $totalEmails sent'),
              ],
            ),
          );
        },
      );
    },
  );

  // Step 5: Send emails sequentially
  for (var email in pendingEmails) {
    await _sendEmail(email);
    sentCount++;
    
    // Update progress dialog
    if (mounted) {
      setState(() {}); // Trigger dialog update
    }
    
    // Step 6: Add delay between sends
    if (sentCount < totalEmails) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  // Step 7: Cleanup
  if (mounted) {
    Navigator.of(context).pop(); // Close dialog
  }

  setState(() {
    _isSendingAll = false;
  });

  // Step 8: Show completion summary
  final successCount = pendingEmails.where((e) => 
    e.status.toLowerCase() == 'sent'
  ).length;
  
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sent $successCount out of $totalEmails emails'),
        backgroundColor: successCount == totalEmails 
          ? Colors.green 
          : Colors.orange,
      ),
    );
  }
}
```

**Detailed Flow:**

**Step 1: Concurrency Prevention**
- Checks `_isSendingAll` flag
- Prevents multiple simultaneous bulk operations
- Returns early if already sending

**Step 2: Email Filtering**
- Filters emails with status "pending" (case-insensitive)
- Creates new list of pending emails only
- Checks if list is empty
- Shows warning if no pending emails

**Step 3: State Management**
- Sets `_isSendingAll = true`
- Triggers rebuild
- Disables "Send to All" button

**Step 4: Progress Dialog**
- **Non-dismissible**: User cannot cancel by tapping outside
- **StatefulBuilder**: Allows dialog content updates
- **Shows**:
  - Circular progress indicator
  - Current progress: "X / Y sent"
- **Updates**: After each email sent

**Step 5: Sequential Sending**
- Uses `for` loop (not parallel to avoid server overload)
- Calls `_sendEmail()` for each pending email
- Waits for each send to complete before next
- Increments `sentCount` after each attempt
- Updates dialog progress

**Step 6: Rate Limiting**
- 500ms delay between emails
- Prevents server overload
- Gives server time to process
- Skips delay after last email

**Step 7: Dialog Cleanup**
- Pops dialog from navigation stack
- Resets `_isSendingAll` flag
- Re-enables "Send to All" button

**Step 8: Summary Notification**
- Counts successfully sent emails
- Shows final statistics
- **Green SnackBar**: All sent successfully
- **Orange SnackBar**: Some failed
- Format: "Sent X out of Y emails"

**Example Execution Timeline:**
```
T+0ms    : Start bulk send (10 pending emails)
T+0ms    : Show progress dialog "0 / 10"
T+100ms  : Email 1 sent → "1 / 10"
T+600ms  : Email 2 sent → "2 / 10" (500ms delay)
T+1100ms : Email 3 sent → "3 / 10"
...
T+5000ms : Email 10 sent → "10 / 10"
T+5000ms : Close dialog, show summary
```

---

#### **Connection Testing**

```dart
Future<void> _testConnection() async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(
        color: Colors.white,
      ),
    ),
  );

  try {
    final response = await http.get(
      Uri.parse(widget.phpEndpoint)
    ).timeout(const Duration(seconds: 5));

    if (mounted) {
      Navigator.pop(context); // Close loading dialog
    }

    String message = 'Status: ${response.statusCode}\n'
                     'Response: ${response.body.substring(0, min(100, response.body.length))}';

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Connection Test'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

**Purpose**: Diagnostic tool for debugging connection issues

**Test Process:**
1. Shows loading dialog
2. Sends GET request to PHP endpoint
3. 5-second timeout
4. Displays response details:
   - HTTP status code
   - First 100 characters of response body
5. Helps identify:
   - Server unavailable (timeout)
   - Wrong endpoint (404)
   - Server errors (500)
   - CORS issues
   - Network connectivity

---

#### **UI Components**

**1. App Bar**
```dart
AppBar(
  title: const Text(
    'Email Data',
    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
  ),
  centerTitle: true,
  backgroundColor: Colors.white,
  foregroundColor: Colors.black,
  elevation: 0,
  actions: [
    // Connection test icon
    IconButton(
      icon: const Icon(Icons.wifi),
      onPressed: _testConnection,
      tooltip: 'Test Connection',
    ),
    // Refresh icon
    IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: _loadData,
      tooltip: 'Refresh Data',
    ),
  ],
)
```

**2. Email List Card**
```dart
InkWell(
  onTap: () => _showEmailDetail(email),
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      children: [
        // Status badge (colored circle)
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: email.statusColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        // Email details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                email.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                email.email,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                email.subject,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Status text badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: email.statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: email.statusColor,
              width: 1,
            ),
          ),
          child: Text(
            email.status,
            style: TextStyle(
              color: email.statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  ),
)
```

**3. Email Detail Dialog**
```dart
void _showEmailDetail(EmailData email) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(email.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Email', email.email),
            if (email.emailBackup.isNotEmpty)
              _buildDetailRow('Backup', email.emailBackup),
            _buildDetailRow('Subject', email.subject),
            if (email.cc.isNotEmpty)
              _buildDetailRow('CC', email.cc),
            if (email.links.isNotEmpty)
              _buildDetailRow('Links', email.links),
            _buildDetailRow('Body', email.body),
            _buildDetailRow('Status', email.status),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (email.status.toLowerCase() != 'sent')
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendEmail(email);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
            ),
            child: const Text('Send Email'),
          ),
      ],
    ),
  );
}
```

**4. Send to All Button (Floating Action Button)**
```dart
FloatingActionButton.extended(
  onPressed: _isSendingAll ? null : _sendAllEmails,
  backgroundColor: _isSendingAll ? Colors.grey : Colors.black,
  icon: _isSendingAll
      ? const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
      : const Icon(Icons.send),
  label: Text(_isSendingAll ? 'Sending...' : 'Send to All'),
)
```

**States:**
- **Normal**: Black background, "Send to All" text
- **Sending**: Grey background, spinner, "Sending..." text
- **Disabled**: `onPressed: null` when already sending

---

### Complete User Journey

```
1. User opens app
   ↓
2. Login screen (vinay14/1201)
   ↓
3. Home screen (enter spreadsheet ID)
   ↓
4. Email list loads from Google Sheets
   ↓
5. User has options:
   a) View email details (tap card)
   b) Send individual email (tap "Send" in detail)
   c) Send all pending (tap FAB)
   d) Refresh data (tap refresh icon)
   e) Test connection (tap WiFi icon)
   ↓
6. Email status updates in real-time
   ↓
7. User can pull-to-refresh
   ↓
8. Summary shown after bulk send
```

---

### Error Handling Matrix

| Error Type | Detection | User Feedback | Recovery |
|------------|-----------|---------------|----------|
| No internet | HTTP timeout | Red SnackBar | Retry button |
| Invalid spreadsheet ID | 404 response | Error dialog | Go back, re-enter |
| Private spreadsheet | 403 response | Access denied message | Share publicly |
| Missing columns | Header validation | Error SnackBar | Fix sheet structure |
| Server down | Connection timeout | Connection test dialog | Check server |
| Invalid email format | (Not validated currently) | Send fails | Manual correction |
| CSRF token fetch fail | Timeout/error | Console log | Continues without |
| Bulk send interrupted | Network error mid-send | Partial success message | Resume manually |

---

### Performance Optimizations

1. **ListView.builder** - Only builds visible items
2. **Const constructors** - Compile-time widget creation
3. **Sequential email sending** - Prevents server overload
4. **500ms delay** - Rate limiting for bulk operations
5. **Pull-to-refresh** - User-initiated data reload
6. **Loading states** - Prevents duplicate API calls

---

### Security Considerations

⚠️ **Current Vulnerabilities:**
- Hardcoded API keys in source code
- No email validation
- No input sanitization
- HTTP (not HTTPS) for PHP endpoint
- CSRF token optional (continues without)
- No authentication for email sending
- Spreadsheet must be publicly accessible

✅ **Production Recommendations:**
1. Move API keys to environment variables
2. Implement OAuth2 for Google Sheets
3. Add email format validation
4. Sanitize all user inputs before sending
5. Use HTTPS for all endpoints
6. Enforce CSRF token requirement
7. Implement rate limiting on server
8. Add email sending authentication
9. Use service account for private spreadsheets
10. Add logging and monitoring
11. Implement retry logic with exponential backoff
12. Add email queue system
13. Validate email addresses before sending

---

This comprehensive documentation provides a complete understanding of every aspect of the `lib` folder's functionality. Each file, class, method, and user interaction is explained in detail with code examples, execution flows, and technical specifications.
