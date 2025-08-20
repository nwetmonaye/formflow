# Email Configuration Debug Script for FormFlow
# This script helps diagnose email issues

Write-Host "🔍 FormFlow Email Configuration Debug Tool" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Check if Firebase CLI is installed
Write-Host "1. Checking Firebase CLI installation..." -ForegroundColor Yellow
try {
    $firebaseVersion = firebase --version 2>$null
    if ($firebaseVersion) {
        Write-Host "✅ Firebase CLI installed: $firebaseVersion" -ForegroundColor Green
    } else {
        Write-Host "❌ Firebase CLI not found" -ForegroundColor Red
        Write-Host "   Install with: npm install -g firebase-tools" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Firebase CLI not found" -ForegroundColor Red
    Write-Host "   Install with: npm install -g firebase-tools" -ForegroundColor Yellow
}

Write-Host ""

# Check current project
Write-Host "2. Checking current Firebase project..." -ForegroundColor Yellow
try {
    $currentProject = firebase projects:list --filter="projectId:formflow-b0484" 2>$null
    if ($currentProject -match "formflow-b0484") {
        Write-Host "✅ Current project: formflow-b0484" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Project not set to formflow-b0484" -ForegroundColor Yellow
        Write-Host "   Run: firebase use formflow-b0484" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Could not check Firebase project" -ForegroundColor Red
}

Write-Host ""

# Check Firebase Functions config
Write-Host "3. Checking Firebase Functions configuration..." -ForegroundColor Yellow
try {
    $functionsConfig = firebase functions:config:get 2>$null
    if ($functionsConfig) {
        Write-Host "✅ Functions config found:" -ForegroundColor Green
        Write-Host $functionsConfig -ForegroundColor Gray
    } else {
        Write-Host "⚠️  No Functions config found" -ForegroundColor Yellow
        Write-Host "   This might be why emails aren't working!" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Could not get Functions config" -ForegroundColor Red
}

Write-Host ""

# Check if functions are deployed
Write-Host "4. Checking if Functions are deployed..." -ForegroundColor Yellow
try {
    $functionsList = firebase functions:list 2>$null
    if ($functionsList -match "sendEmailFromApp") {
        Write-Host "✅ sendEmailFromApp function is deployed" -ForegroundColor Green
    } else {
        Write-Host "❌ sendEmailFromApp function not found in deployed functions" -ForegroundColor Red
        Write-Host "   Deploy with: firebase deploy --only functions" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Could not check deployed functions" -ForegroundColor Red
}

Write-Host ""

# Check recent function logs
Write-Host "5. Checking recent function logs..." -ForegroundColor Yellow
Write-Host "   Run this command to see recent logs:" -ForegroundColor Gray
Write-Host "   firebase functions:log --only sendEmailFromApp --limit 10" -ForegroundColor Cyan

Write-Host ""

# Check email configuration
Write-Host "6. Email Configuration Status:" -ForegroundColor Yellow
Write-Host "   - Form Owner Email: Must be set when creating forms" -ForegroundColor Gray
Write-Host "   - Submit Email: Must be provided by external users" -ForegroundColor Gray
Write-Host "   - Firebase Functions: Must have email credentials configured" -ForegroundColor Gray

Write-Host ""

# Recommendations
Write-Host "🔧 RECOMMENDATIONS:" -ForegroundColor Cyan
Write-Host "1. Ensure your Firebase account has an email address" -ForegroundColor Yellow
Write-Host "2. Set up email configuration:" -ForegroundColor Yellow
Write-Host "   firebase functions:config:set email.service=\"gmail\" email.user=\"your-email@gmail.com\" email.password=\"your-app-password\"" -ForegroundColor Cyan
Write-Host "3. Deploy functions: firebase deploy --only functions" -ForegroundColor Cyan
Write-Host "4. Test with a simple form submission" -ForegroundColor Cyan

Write-Host ""
Write-Host "📧 To test email functionality:" -ForegroundColor Cyan
Write-Host "1. Create a form with your email as formOwnerEmail" -ForegroundColor Gray
Write-Host "2. Submit the form from another browser/device" -ForegroundColor Gray
Write-Host "3. Check console logs for email sending details" -ForegroundColor Gray
Write-Host "4. Check Firebase Functions logs for errors" -ForegroundColor Gray

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
