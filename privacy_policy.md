
# Privacy Policy

The source code of the application is open and available in the repository
for review and analysis at "https://github.com/maxrys/js-blocker".


## Application structure

The application is a bundle of two parts:
- main application `JS Blocker`;
- Safari extension `JS Blocker Extension`.

The main application consists of:
- the main `JS Blocker` window (in which the user manages the list of domains
  on which JavaScript is allowed to run: deletion, import, and export).

The Safari extension consists of:
- A pop-up window (in which the user can add or remove a rule for the current domain).
  This window appears when clicking the `JS` button in the Safari toolbar.
- A local `script.js` file. Its primary purpose is to disable JavaScript on the
  selected domain (by default) or enable it at the user's request.
  It is transparent to analysis and is necessary for the application to function.

The `JS Blocker Extension` extension can only be launched on domains
approved by the user (via Safari settings).


## Modifying the file system

The application does not work with the file system - it does not write
or read any data.


## Data storage

The application uses the standard `Core Data` mechanism to store
the "list of allowed domains" in the local database.

This list is generated at the user's request for the application
to function.

When you enable the "Experimental / Enable CloudKit" option,
syncing with iCloud occurs.


## Other activities

Application:
- runs in an isolated OS environment (sandbox);
- does not register user clicks;
- does not have access to the clipboard;
- does not add events to DOM elements;
- does not send or receive data over the network;
- does not collect or store personal data;
- does not transfer data to third parties;
- does not include external JavaScript files.
