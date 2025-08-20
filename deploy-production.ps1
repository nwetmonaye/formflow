# Production Deployment Script for FormFlow
# Run this script from the project root directory

Write-Host "🚀 Starting FormFlow Production Deployment..." -ForegroundColor Green

# Step 1: Build Flutter Web App
Write-Host "📱 Building Flutter Web App..." -ForegroundColor Yellow
flutter build web --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Flutter build completed successfully" -ForegroundColor Green

# Step 2: Install Firebase Functions Dependencies
Write-Host "📦 Installing Firebase Functions dependencies..." -ForegroundColor Yellow
Set-Location functions
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ NPM install failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Dependencies installed successfully" -ForegroundColor Green

# Step 3: Build Firebase Functions
Write-Host "🔨 Building Firebase Functions..." -ForegroundColor Yellow
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Functions build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Functions build completed successfully" -ForegroundColor Green

# Step 4: Return to project root
Set-Location ..

# Step 5: Deploy to Firebase
Write-Host "🚀 Deploying to Firebase..." -ForegroundColor Yellow
firebase deploy --only hosting,functions,firestore:rules
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Firebase deployment failed!" -ForegroundColor Red
    exit 1
}

Write-Host "🎉 Production deployment completed successfully!" -ForegroundColor Green
Write-Host "🌐 Your app is now live at: https://your-project-id.web.app" -ForegroundColor Cyan
Write-Host "📧 Check Firebase Console for function logs and monitoring" -ForegroundColor Cyan
