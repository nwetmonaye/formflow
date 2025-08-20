# FormFlow Email Troubleshooting Guide

## 🚨 **Email Not Working in Production? Here's How to Fix It!**

### **Quick Diagnosis Steps**

1. **Check Function Logs**
   ```bash
   firebase functions:log
   ```
   Look for email function errors and execution logs.

2. **Test Email Function Locally**
   ```bash
   cd functions
   npm run serve
   ```
   Test with sample data to see if it works locally.

3. **Verify Configuration**
   ```bash
   firebase functions:config:get
   ```
   Check if email settings are properly configured.

---

## 🔧 **Common Email Issues & Solutions**

### **Issue 1: Gmail Authentication Failed**

**Symptoms:**
- Error: "Invalid login: 535-5.7.8 Username and Password not accepted"
- Function logs show authentication errors

**Solutions:**
1. **Enable 2-Factor Authentication** on your Gmail account
2. **Generate App Password**:
   - Go to Google Account → Security → App Passwords
   - Select "Mail" and "Other (Custom name)"
   - Use the generated 16-character password
3. **Update Firebase Config**:
   ```bash
   firebase functions:config:set email.service="gmail" email.user="your-email@gmail.com" email.password="your-app-password"
   ```

**⚠️ Important:** Never use your regular Gmail password! Only use App Passwords.

---

### **Issue 2: Resend API Key Invalid**

**Symptoms:**
- Error: "Invalid API key" or "Unauthorized"
- Function fails to connect to Resend

**Solutions:**
1. **Verify API Key** at [resend.com](https://resend.com)
2. **Check Account Status**:
   - Ensure account is verified
   - Check if you have sufficient credits
   - Verify domain is properly configured
3. **Update Firebase Config**:
   ```bash
   firebase functions:config:set resend.api_key="your-actual-api-key"
   ```

---

### **Issue 3: Function Not Triggered**

**Symptoms:**
- No email function logs
- Function never executes
- No errors in logs

**Solutions:**
1. **Check Function Deployment**:
   ```bash
   firebase deploy --only functions
   ```
2. **Verify Function Export** in `functions/src/index.ts`
3. **Check Client-Side Calls** to ensure function is being called
4. **Test Function Directly** using Firebase Console

---

### **Issue 4: Email Sent but Not Received**

**Symptoms:**
- Function logs show success
- No email in inbox or spam folder
- Email appears to be sent

**Solutions:**
1. **Check Spam/Junk Folder**
2. **Verify Email Address** format
3. **Check Sender Reputation** (especially for new domains)
4. **Use Gmail for Testing** first (better deliverability)
5. **Check Email Headers** for delivery issues

---

## 🛠️ **Step-by-Step Fix Process**

### **Step 1: Configure Email Service**

Run the setup script:
```bash
.\setup-email-config.ps1
```

Or manually configure:
```bash
# For Gmail
firebase functions:config:set email.service="gmail" email.user="your-email@gmail.com" email.password="your-app-password"

# For Resend
firebase functions:config:set resend.api_key="your-api-key" email.from="noreply@yourdomain.com"
```

### **Step 2: Deploy Functions**

```bash
firebase deploy --only functions
```

### **Step 3: Test Email Function**

Test with a simple email:
```javascript
// In your app or Firebase Console
const testEmail = {
  to: "test@example.com",
  subject: "Test Email",
  html: "<h1>Test</h1><p>This is a test email</p>",
  type: "test"
};

// Call your function
sendEmailFromApp(testEmail);
```

### **Step 4: Check Logs**

```bash
firebase functions:log --only sendEmailFromApp
```

---

## 📧 **Email Service Recommendations**

### **For Development/Testing:**
- **Gmail** with App Password
- Easy to set up
- Good for testing
- Limited to 500 emails/day

### **For Production:**
- **Resend** (recommended)
- Better deliverability
- Professional features
- Higher limits
- Domain verification

### **Alternative Services:**
- **SendGrid**
- **Mailgun**
- **Amazon SES**

---

## 🔍 **Debugging Commands**

### **Check Function Status**
```bash
firebase functions:list
```

### **View Function Logs**
```bash
firebase functions:log
firebase functions:log --only sendEmailFromApp
```

### **Test Function Locally**
```bash
cd functions
npm run serve
```

### **Check Configuration**
```bash
firebase functions:config:get
firebase functions:config:get email
firebase functions:config:get resend
```

---

## 📋 **Email Configuration Checklist**

- [ ] Email service configured (Gmail or Resend)
- [ ] App Password generated (for Gmail)
- [ ] API key valid (for Resend)
- [ ] Function deployed successfully
- [ ] Function logs show no errors
- [ ] Test email sent and received
- [ ] Production email working

---

## 🚀 **Quick Fix Commands**

### **Reset and Reconfigure Gmail**
```bash
firebase functions:config:unset email
firebase functions:config:set email.service="gmail" email.user="your-email@gmail.com" email.password="your-app-password"
firebase deploy --only functions
```

### **Reset and Reconfigure Resend**
```bash
firebase functions:config:unset resend
firebase functions:config:set resend.api_key="your-api-key"
firebase deploy --only functions
```

### **Clear All Config and Start Over**
```bash
firebase functions:config:unset email
firebase functions:config:unset resend
firebase functions:config:set email.service="gmail" email.user="your-email@gmail.com" email.password="your-app-password"
firebase deploy --only functions
```

---

## 📞 **Still Having Issues?**

1. **Check Function Logs** for specific error messages
2. **Verify Email Service** credentials
3. **Test Locally** first
4. **Check Network** and firewall settings
5. **Contact Support** for your email service provider

---

**Remember:** Email delivery can be affected by many factors including spam filters, domain reputation, and email service provider policies. Start with Gmail for testing, then move to a professional service like Resend for production.
