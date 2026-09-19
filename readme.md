

JS Blocker is an open-source Safari extension. It blocks JavaScript on selected websites. The user determines on which websites JavaScript execution is allowed.


## Exterior

![Main Popup image](https://raw.githubusercontent.com/maxrys/js-blocker/refs/heads/main/screens/screen-1.png "Main Popup")
![Main Popup image](https://raw.githubusercontent.com/maxrys/js-blocker/refs/heads/main/screens/screen-2.png "Main Popup")
![Main Popup image](https://raw.githubusercontent.com/maxrys/js-blocker/refs/heads/main/screens/screen-3.png "Main Popup")
![Main Application image](https://raw.githubusercontent.com/maxrys/js-blocker/refs/heads/main/screens/screen-4.png "Main Application")
![Main Application image](https://raw.githubusercontent.com/maxrys/js-blocker/refs/heads/main/screens/screen-5.png "Main Application")
![Main Application image](https://raw.githubusercontent.com/maxrys/js-blocker/refs/heads/main/screens/screen-6.png "Main Application")


## Description

JS Blocker is an extension for the Safari browser. JS Blocker blocks JavaScript on selected websites by default. You can be sure that JavaScript will not run on it until you allow its execution (see the "Extension operating modes in Safari" section for details). The block prevents potential miners, keyloggers, and other malicious JavaScript programs from running without your permission. JS Blocker cannot determine whether JavaScript is malicious!

To allow JavaScript execution on a specific website, the user adds that website to the allowlist using the JS Blocker pop-up.

You can also add a website to the allowed list temporarily, for one of the following periods: 1 minute, 5 minutes, 1 hour, 1 day, or 1 week. Selective JavaScript activation is also supported—you specify exactly which JavaScript is unblocked in which window.

### Operating Modes in JS Blocker

JS Blocker supports 4 operating modes:

- allow JavaScript on the site: `JavaScript on the Domain`;
- allow JavaScript on the site, separately by script: `JavaScript on the Domain ` + `Allow JS separately by script` option;
- allow JavaScript on the site and its domains: `JavaScript on the Domain + Subdomains`;
- allow JavaScript on the site and its domains, separately by script: `JavaScript on the Domain + Subdomains` + `Allow JS separately by script ` option.

### Operating Modes in JS Blocker Safari Extension

If the settings for this extension in Safari are configured as `Site N = Allow / For other sites = Allow`, then JavaScript will be blocked on all websites and in all their windows. This is the recommended and most reliable operating mode.

If the Safari settings for this extension are configured as `Site N = Allow / Other websites = Deny`, then JavaScript will be blocked only on the selected websites. If windows from other websites—where this extension was not enabled—are open on such sites, the JavaScript in those windows will continue to execute, as the extension will be unable to access them and block the JavaScript.

### Types of blocked JavaScript

The extension blocks the following types of JavaScript:

- any external JavaScript loaded from the current website;
- any external JavaScript loaded from other websites;
- any embedded JavaScript located directly within the HTML document inside `script` tags;
- any inline JavaScript in attributes whose names begin with `on…=…` (such attributes are removed);
- any inline JavaScript in attributes whose values begin with `javascript:` (such attributes are removed);
- any iframe with a `srcdoc` attribute is removed;
- any iframe with a `src` attribute whose value begins with `data:text/html` is removed;
- any iframe with a `src` attribute whose value begins with `data:application/xhtml+xml` is removed;
- any iframe with a `src` attribute whose value starts with `blob:` is removed.

If a website contains windows that contain any of the types of JavaScript listed above, the same blocking rules apply to that JavaScript.

Please note that enabled JavaScript can dynamically include other JavaScript from any website or dynamically create windows. JS Blocker does not track these actions, as it considers such JavaScript trusted and all its subsequent actions permitted and user-approved.

Once a website is added to the allowlist, the JavaScript restrictions listed above no longer apply to it.

### Supported addresses

JS Blocker supports the following types of addresses (domain names) in Safari:

- short local (e.g., `http://localhost`);
- classic (e.g., `http://example.com`);
- classic with subdomains (e.g., `http://subdomain.example.com`);
- internationalized domain names (e.g., `http://пример.com` = `http://xn--e1afmkfd.com`);
- internationalized domain names with internationalized domain zones (e.g., `http://пример.ком` = `http://xn--e1afmkfd.xn--j1aef`);
- as an IPv4 address (e.g., `http://127.0.0.1`);
- as an IPv6 address (e.g., `http://[::1]`).

The port number in the address is ignored.

### Supported Operating Systems

The following versions of macOS are supported:

- 11 (Big Sur);
- 12 (Monterey);
- 13 (Ventura);
- 14 (Sonoma);
- 15 (Sequoia);
- 26 (Tahoe) and newer versions.

### Additional information

JS Blocker is open-source software.  
JS Blocker does not use a subscription model.  
JS Blocker does not contain AI-generated code.
