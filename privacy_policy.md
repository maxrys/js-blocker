
# Privacy Policy

The source code of the application is open and available in the repository
for review and analysis at "https://github.com/maxrys/js-blocker".

The application is a bundle of three parts:
- main application;
- Safari browser extension "JS Blocker Extension";
- Safari browser extension "JS Blocker Rules".

The user himself determines on which domains (sites) the "JS Blocker Extension"
and "JS Blocker Rules" extensions will work.

The application does not work with the file system - it does not write or read any data.
The application uses the standard _Core Data_ mechanism to store a "list of allowed domains"
on the local file system. This list is generated at the user's request for the application
to function.

The application does not include external JavaScript files.
The "JS Blocker Extension" includes a local "script.js" file, which is transparent to analysis
and is necessary for the application to function. The main purpose of "script.js" is to
disable JavaScript on the selected domain (by default) or enable it at the user’s request.

Main application, "JS Blocker Extension" / "JS Blocker Rules" extensions, "script.js" file:
- do not register user clicks;
- do not have access to the clipboard;
- do not add events to DOM elements;
- do not send or receive data over the external network;
- do not collect or store any personal data;
- do not transfer any data to third parties.

The application runs in an isolated OS environment (sandbox) and is unable to affect
anything other than JavaScript in the Safari browser.
