#!/bin/bash

# Email Configuration Setup Script for FormFlow
# This script helps you configure email services for Firebase Functions

echo "📧 Setting up Email Configuration for FormFlow..."
echo ""

# Check if Firebase CLI is installed
if command -v firebase &> /dev/null; then
    FIREBASE_VERSION=$(firebase --version)
    echo "✅ Firebase CLI found: $FIREBASE_VERSION"
else
    echo "❌ Firebase CLI not found. Please install it first:"
    echo "npm install -g firebase-tools"
    exit 1
fi

echo ""
echo "Choose your email service:"
echo "1. Gmail (with App Password)"
echo "2. Resend (Recommended for production)"
echo "3. Skip email setup for now"
echo ""

read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        echo ""
        echo "📧 Setting up Gmail configuration..."
        
        read -p "Enter your Gmail address: " gmail_user
        read -s -p "Enter your Gmail App Password (not regular password): " gmail_password
        echo ""
        
        echo ""
        echo "🔧 Setting Firebase Functions configuration..."
        
        # Set Gmail configuration
        firebase functions:config:set email.service="gmail" email.user="$gmail_user" email.password="$gmail_password" email.from="$gmail_user"
        
        echo ""
        echo "✅ Gmail configuration set successfully!"
        echo "📝 Note: Make sure you have:"
        echo "   - Enabled 2-factor authentication on your Gmail account"
        echo "   - Generated an App Password (not your regular password)"
        echo "   - Used the App Password in the configuration above"
        ;;
        
    2)
        echo ""
        echo "📧 Setting up Resend configuration..."
        
        read -p "Enter your Resend API key: " resend_api_key
        read -p "Enter your sender email address (e.g., noreply@yourdomain.com): " from_email
        
        echo ""
        echo "🔧 Setting Firebase Functions configuration..."
        
        # Set Resend configuration
        firebase functions:config:set resend.api_key="$resend_api_key" email.from="$from_email"
        
        echo ""
        echo "✅ Resend configuration set successfully!"
        echo "📝 Note: Make sure you have:"
        echo "   - Signed up at resend.com"
        echo "   - Verified your domain"
        echo "   - Have sufficient credits in your account"
        ;;
        
    3)
        echo ""
        echo "⏭️ Skipping email configuration setup"
        echo "You can configure email later using:"
        echo "firebase functions:config:set"
        ;;
        
    *)
        echo ""
        echo "❌ Invalid choice. Please run the script again."
        exit 1
        ;;
esac

echo ""
echo "🔍 Current Firebase Functions configuration:"
firebase functions:config:get

echo ""
echo "📋 Next steps:"
echo "1. Deploy your functions: firebase deploy --only functions"
echo "2. Test email functionality in your app"
echo "3. Check function logs: firebase functions:log"
echo ""

echo "🎉 Email configuration setup completed!"
