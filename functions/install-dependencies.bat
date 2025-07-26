@echo off
echo Installing Firebase Cloud Functions dependencies...
echo.

echo Installing main dependencies...
npm install firebase-functions firebase-admin nodemailer cors express uuid

echo.
echo Installing dev dependencies...
npm install --save-dev typescript @types/node @types/nodemailer @types/cors @types/express @types/uuid

echo.
echo Building TypeScript...
npm run build

echo.
echo Installation complete!
echo You can now deploy your functions with: firebase deploy --only functions
pause 