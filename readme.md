

This open-source extension blocks JavaScript on all websites. Using an "Allowed list", the user determines which websites are allowed to run JavaScript.


## Exterior

![main popup image](https://raw.githubusercontent.com/maxrys/js-blocker/refs/heads/main/screens/screen-1.png "main popup")
![main popup image](https://raw.githubusercontent.com/maxrys/js-blocker/refs/heads/main/screens/screen-2.png "main popup")
![main popup image](https://raw.githubusercontent.com/maxrys/js-blocker/refs/heads/main/screens/screen-3.png "main popup")
![main application image](https://raw.githubusercontent.com/maxrys/js-blocker/refs/heads/main/screens/screen-4.png "main application")
![main application image](https://raw.githubusercontent.com/maxrys/js-blocker/refs/heads/main/screens/screen-5.png "main application")
![main application image](https://raw.githubusercontent.com/maxrys/js-blocker/refs/heads/main/screens/screen-6.png "main application")


## Description

If this Safari extension is enabled for any websites (extension operating mode "For other websites = Allow"), then by default it blocks JavaScript on any websites. This is the recommended operating mode.

If this Safari extension is enabled for selected websites only, then by default it blocks JavaScript only on the selected websites.

Using the extension settings, the user can add a website to the "Allowed list".
A websites from the "Allowed list" can use JavaScript.

You can also add a website to the "Allowed list" temporarily, for the following periods:
- 1 minute;
- 5 minutes;
- 1 hour;
- 1 day;
- 1 week.

When you open an unknown website, you can be sure that no JavaScript will be executed on it until you approve it (if you selected the extension's operating mode "For other websites = Allow").
This ensures that potential miners, keyloggers or any other malicious programs written in JavaScript cannot run unless you approve it.
Please note that this extension is not able to determine whether a JavaScript is malicious.

By default, the following types of JavaScript will be blocked for the current website:
1) any external JavaScript from the current website;
2) any external JavaScript from other websites;
3) any embedded JavaScript (can be located directly in the HTML document, in the `script` tags);
4) any inline (events) JavaScript (can be located directly in the HTML document, in attributes with names starting with `on…=…`);
5) JavaScript in a frame/iframe, of any of the above types, from any website.

Once a site is added to the "Allowed List", all the above JavaScript blocking will not be applied.

This extension supports the following types of addresses (domain names) in Safari:
- short local (for example, `http://localhost`);
- classic (for example, `http://example.com`);
- classic with subdomains (for example, `http://subdomain.example.com`);
- international (for example, `http://пример.com` = `http://xn--e1afmkfd.com`);
- international full (for example, `http://пример.ком` = `http://xn--e1afmkfd.xn--j1aef`);
- in the form of an IPv4 address (for example, `http://127.0.0.1`).

IPv6 addresses are not supported.
The port number in the address is ignored.

Support for the following macOS versions:
- 11 (Big Sur)
- 12 (Monterey)
- 13 (Ventura)
- 14 (Sonoma)
- 15 (Sequoia)
- 26 (Tahoe)
and later.

It is open-source software.  
Free from subscription model.  
Free from AI-generated code.
