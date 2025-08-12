# Form Flow Routing Debug Guide

## Issue Description
When copying a form link to another tab, the route should show the form submission screen (like Google Forms) but currently shows the form builder instead.

## What I've Fixed

### 1. Enhanced Route Handling
- Added better logging to `onGenerateInitialRoutes` and `onGenerateRoute`
- Added fallback handling in `onUnknownRoute` for form routes
- Added test routes for debugging: `/test-form`, `/debug-routing`
- Enhanced web-specific routing in `index.html`

### 2. Improved Form Loading
- Updated `FormSubmissionScreen` to use both Firebase and mock repository
- Added sample mock forms to `FormRepository` for local testing
- Enhanced error handling and loading states

### 3. Better Error Messages
- Added detailed error information when forms can't be loaded
- Added "Try Again" functionality
- Improved loading states with form ID display

## Testing Steps

### 1. Test Local Development
1. Run the app locally
2. Navigate to `/debug-routing` to see routing debug information
3. Use the test buttons to verify different route types
4. Check the console for routing logs

### 2. Test Form Links
1. Create a form in the app
2. Copy the share link (should look like `/form/{formId}`)
3. Paste it in a new tab
4. Check the console logs to see what route is being processed

### 3. Check Console Logs
Look for these log messages:
- `🔍 onGenerateInitialRoutes called with: {route}`
- `🔍 Initial route is a form route: {route}`
- `🔍 Routing to FormSubmissionScreen with formId: {formId}`
- `🔍 Web: Detected form route: {route}` (in browser console)

## Debug Routes Available

### `/debug-routing`
- Shows current routing information
- Provides test buttons for different route types
- Helps verify routing is working correctly

### `/test-form`
- Shows a sample form directly
- Bypasses all routing logic
- Good for testing form display

### `/form/sample-form-1`
- Tests form submission routing
- Should show the sample survey form
- Tests the main routing logic

### `/form/sample-form-1?view=true`
- Tests form preview routing
- Should show the form detail screen
- Tests query parameter handling

## Sample Mock Forms Available

### Form ID: `sample-form-1`
- Title: "Sample Survey Form"
- Includes: text, number, multiple choice, checkbox, dropdown, date fields

### Form ID: `sample-form-2`
- Title: "Customer Feedback Form"
- Includes: text, multiple choice fields

## Debugging Routes

### Test URLs to Try:
- `/debug-routing` - Shows routing debug information
- `/test-form` - Should show sample form
- `/form/sample-form-1` - Should show sample survey form
- `/form/sample-form-2` - Should show customer feedback form

### Expected Behavior:
1. **Form routes** (`/form/{id}`) should show the form submission screen
2. **View routes** (`/form/{id}?view=true`) should show the form detail screen
3. **Debug routes** should show debugging information
4. **Other routes** should show the appropriate screens or fall back to HomeScreen

## Common Issues

### 1. Firebase Not Initialized
- Check if Firebase is properly configured
- Look for "Firebase not initialized" messages in console
- App should fall back to mock repository

### 2. Form Not Found
- Check if the form ID exists in mock data
- Verify the route format is correct
- Check console for parsing errors

### 3. Routing Issues
- Ensure the route starts with `/form/`
- Check that the form ID is properly extracted
- Verify the route is being processed by the correct handler

### 4. Web-Specific Issues
- Check browser console for web routing logs
- Verify the URL is being parsed correctly
- Check if the route is being passed to Flutter

## Next Steps

1. **Start with debugging**: Navigate to `/debug-routing` to see routing state
2. **Test sample forms**: Try `/form/sample-form-1` to verify form loading
3. **Check console logs**: Look for routing decisions and any errors
4. **Test link copying**: Copy a form link to a new tab and check logs
5. **Verify web routing**: Check browser console for web-specific logs

## Console Commands

To see detailed routing logs, run the app and check the console output. All routing decisions are logged with the 🔍 emoji for easy identification.

### Browser Console
Look for logs starting with `🔍 Web:` to see web-specific routing information.

### Flutter Console
Look for logs starting with `🔍` to see Flutter routing decisions.

## Troubleshooting Checklist

- [ ] Can you access `/debug-routing`?
- [ ] Do the test buttons work in the debug route?
- [ ] Can you access `/form/sample-form-1`?
- [ ] Are there any console errors?
- [ ] Is the route being processed by `onGenerateInitialRoutes`?
- [ ] Is the form loading correctly?
- [ ] Are web console logs showing up? 