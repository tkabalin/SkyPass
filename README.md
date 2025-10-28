<img width="250" alt="Skypass_Logo_Gray" src="https://github.com/user-attachments/assets/13f8dd98-0e53-4611-a174-452bce6708ab" />

# SkyPass - Grade 10 Practical Assessment Task (PAT)

This project is a desktop application that provides a secure tool for generating passwords and passcodes. It features a multi-level authentication system (login + CAPTCHA), separate user and administrator roles, and detailed code generation options.

## Features

### 👤 Standard User

**Secure Login:** Authenticate via email, password, and CAPTCHA.  
**Account Creation:** Register with validation and CAPTCHA.  
**Password Generator:** Create passwords (up to 50 chars) with customizable character sets.  
**Passcode Generator:** Generate numeric-only passcodes (up to 50 chars).  
**Advanced Mode:** Long passwords (up to 512 chars), unique chars, or custom sets.  
**Password Strength:** Visual indicator (*Weak, Medium, Strong*).  
**Copy to Clipboard:** Easily copy generated codes.

### 🛠️ Administrator

**Secure Admin Login:** Access a separate panel.  
**User Management:** View and delete standard users.  
**Log Management:** View, search, or clear activity logs.  
**Credential Management:** Change admin username/password.  
**Security:** Admins cannot see user passwords or codes.

## Application Forms

The application is built around four main forms:

1. **Login Form**  
   Authenticates existing users or administrators and includes a CAPTCHA to prevent automated access.

2. **Create Account Form**  
   Allows new users to register. It validates input (email format, password matching) and also requires CAPTCHA completion.

3. **Code Generator Form**  
   The main screen for standard users. It has three modes (*Password, Passcode, Advanced*) for generating codes with various user-defined specifications.

4. **Administrator Form**  
   A secure panel for administrators to manage user accounts and view the application's activity log.


## User Interface
<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/d11072c3-26bc-4df2-b521-9bd15e4e8ce3" alt="Login" height="250"></td>
    <td><img src="https://github.com/user-attachments/assets/f6024422-339a-44f3-9197-e1377a6aa306" alt="Create_Account" height="250"></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/438e8091-5d3d-4234-b4e4-963e7e622c61" alt="Password_Generator" height="250"></td>
    <td><img src="https://github.com/user-attachments/assets/ad9f2579-a874-4902-8d2b-ed7323c996de" alt="Admin_Console" height="250"></td>
  </tr>
</table>



## How to Run the Program

A pre-compiled executable is available in the repository.  
1. Download or clone the repository.  
2. Navigate to the `Win32/Debug` folder.  
3. Run `SkyPass_p.exe`.



## License

This project is protected by copyright. See [LICENSE.md](LICENSE.md) for full details.
