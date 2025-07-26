Write-Host "Installing Firebase Cloud Functions dependencies..." -ForegroundColor Green
Write-Host ""

Write-Host "Installing main dependencies..." -ForegroundColor Yellow
npm install firebase-functions firebase-admin nodemailer cors express uuid

Write-Host ""
Write-Host "Installing dev dependencies..." -ForegroundColor Yellow
npm install --save-dev typescript @types/node @types/nodemailer @types/cors @types/express @types/uuid

Write-Host ""
Write-Host "Building TypeScript..." -ForegroundColor Yellow
npm run build

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host "You can now deploy your functions with: firebase deploy --only functions" -ForegroundColor Cyan
Read-Host "Press Enter to continue" 