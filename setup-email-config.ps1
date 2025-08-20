# Email Configuration Setup Script for FormFlow
# This script helps you configure email services for Firebase Functions

Write-Host "📧 Setting up Email Configuration for FormFlow..." -ForegroundColor Green
Write-Host ""

# Check if Firebase CLI is installed
try {
    $firebaseVersion = firebase --version
    Write-Host "✅ Firebase CLI found: $firebaseVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Firebase CLI not found. Please install it first:" -ForegroundColor Red
    Write-Host "npm install -g firebase-tools" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Choose your email service:" -ForegroundColor Cyan
Write-Host "1. Gmail (with App Password)" -ForegroundColor White
Write-Host "2. Resend (Recommended for production)" -ForegroundColor White
Write-Host "3. Skip email setup for now" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1-3)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "📧 Setting up Gmail configuration..." -ForegroundColor Yellow
        
        $gmailUser = Read-Host "Enter your Gmail address"
        $gmailPassword = Read-Host "Enter your Gmail App Password (not regular password)" -AsSecureString
        $gmailPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($gmailPassword))
        
        Write-Host ""
        Write-Host "🔧 Setting Firebase Functions configuration..." -ForegroundColor Yellow
        
        # Set Gmail configuration
        firebase functions:config:set email.service="gmail" email.user="$gmailUser" email.password="$gmailPassword" email.from="$gmailUser"
        
        Write-Host ""
        Write-Host "✅ Gmail configuration set successfully!" -ForegroundColor Green
        Write-Host "📝 Note: Make sure you have:" -ForegroundColor Cyan
        Write-Host "   - Enabled 2-factor authentication on your Gmail account" -ForegroundColor White
        Write-Host "   - Generated an App Password (not your regular password)" -ForegroundColor White
        Write-Host "   - Used the App Password in the configuration above" -ForegroundColor White
    }
    
    "2" {
        Write-Host ""
        Write-Host "📧 Setting up Resend configuration..." -ForegroundColor Yellow
        
        $resendApiKey = Read-Host "Enter your Resend API key"
        $fromEmail = Read-Host "Enter your sender email address (e.g., noreply@yourdomain.com)"
        
        Write-Host ""
        Write-Host "🔧 Setting Firebase Functions configuration..." -ForegroundColor Yellow
        
        # Set Resend configuration
        firebase functions:config:set resend.api_key="$resendApiKey" email.from="$fromEmail"
        
        Write-Host ""
        Write-Host "✅ Resend configuration set successfully!" -ForegroundColor Green
        Write-Host "📝 Note: Make sure you have:" -ForegroundColor Cyan
        Write-Host "   - Signed up at resend.com" -ForegroundColor White
        Write-Host "   - Verified your domain" -ForegroundColor White
        Write-Host "   - Have sufficient credits in your account" -ForegroundColor White
    }
    
    "3" {
        Write-Host ""
        Write-Host "⏭️ Skipping email configuration setup" -ForegroundColor Yellow
        Write-Host "You can configure email later using:" -ForegroundColor Cyan
        Write-Host "firebase functions:config:set" -ForegroundColor White
    }
    
    default {
        Write-Host ""
        Write-Host "❌ Invalid choice. Please run the script again." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "🔍 Current Firebase Functions configuration:" -ForegroundColor Cyan
firebase functions:config:get

Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Green
Write-Host "1. Deploy your functions: firebase deploy --only functions" -ForegroundColor White
Write-Host "2. Test email functionality in your app" -ForegroundColor White
Write-Host "3. Check function logs: firebase functions:log" -ForegroundColor White
Write-Host ""

Write-Host "🎉 Email configuration setup completed!" -ForegroundColor Green
