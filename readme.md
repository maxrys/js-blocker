

This open-source extension blocks JavaScript on all domains. Using an "allowed list", the user determines which domains are allowed to run JavaScript.


## Exterior

![main popup image](https://raw.githubusercontent.com/maxrys/js-blocker/refs/heads/main/screens/screen-1.png "main popup")
![main popup image](https://raw.githubusercontent.com/maxrys/js-blocker/refs/heads/main/screens/screen-2.png "main popup")


## Description

If this Safari extension is enabled for any domains, then by default it blocks JavaScript code on any domains (the recommended mode of operation).

If this Safari extension is enabled for selected domains only, then by default it blocks JavaScript code only on the selected domains.

Using the extension settings, the user can add a domain to the "allowed list". A domain from the "allowed list" can use JavaScript.

When you open an unknown domain, you can be sure that no JavaScript code will be executed on it until you approve it (if you previously selected the recommended operating mode). This ensures that potential miners, keyloggers or any other malicious programs written in JavaScript cannot run unless you approve it. Please note that this extension is not able to determine whether a JavaScript program is malicious.

By default, the following types of JavaScript will be blocked for the current domain:
1) any external JavaScript from the current domain;
2) any external JavaScript from a third party;
3) any embedded JavaScript (can be located directly in the HTML document, in the `script` tags);
4) any inline (events) JavaScript (can be located directly in the HTML document, in attributes with names starting with `on…=…`);
5) JavaScript in a frame/iframe, of any of the above types, from any domain.

Once a domain is added to the "allowed list", the following types of JavaScript will be enabled within the current domain:
1) any external JavaScript from the current domain;
2) any external JavaScript from a third party;
3) any embedded JavaScript (can be located directly in the HTML document, in the `script` tags);
4) any inline (events) JavaScript (can be located directly in the HTML document, in attributes with names starting with `on…=…`);
5) JavaScript in a frame/iframe, of any of the above types, from any domain.

When Safari uses Private Window mode, storing app settings in Safari's local storage becomes unavailable. In this case:
1) any external JavaScript from the current domain will not be blocked;
2) any external JavaScript from a third party will not be blocked;
3) any embedded JavaScript will be blocked (can be located directly in the HTML document, in the `script` tags);
4) any inline (event) JavaScript will be blocked (can be located directly in the HTML document, in attributes with names starting with `on…=…`);
5) JavaScript in frame/iframe will be blocked in the same way.

This extension supports the following types of addresses (domain names) in Safari:
- short local (for example, `http://localhost`);
- classic (for example, `http://example.com`);
- classic with subdomains (for example, `http://subdomain.example.com`);
- international (for example, `http://пример.com` = `http://xn--e1afmkfd.com`);
- international full (for example, `http://пример.ком` = `http://xn--e1afmkfd.xn--j1aef`);
- in the form of an IPv4 address (for example, `http://127.0.0.1`).

IPv6 addresses are not supported.
The port number in the address is ignored.
