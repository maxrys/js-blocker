
/////////////////////////////////////////////////////////////
/// Copyright © 2024 Maxim Rysevets. All rights reserved. ///
/////////////////////////////////////////////////////////////

(function(){

    let extensionName = 'JS Blocker';
    let thisDomain = window.location.hostname;

    if (!thisDomain) {

        console.log(
            `Content blocker "${extensionName}" error: unknown domain`
        );

    } else {

        let updateInterval = 500;
        let isMainFrame = window.parent === window;
        let isJSAllowed = null;
        let isLocalStorageAvailable = true;

        try {
            isJSAllowed = window.localStorage.getItem('isJSAllowed');
            if (isJSAllowed === 'true' ) isJSAllowed = true;
            if (isJSAllowed === 'false') isJSAllowed = false;
        } catch (e) {
            isLocalStorageAvailable = false;
        }

        console.log(`Content blocker "${extensionName}" on "${thisDomain}" has been started`);
        console.log(`Content blocker "${extensionName}" on "${thisDomain}" base URL: "${safari.extension.baseURI}"`);
        console.log(`Content blocker "${extensionName}" on "${thisDomain}" LocalStorage is available: "${isLocalStorageAvailable}"`);
        console.log(`Content blocker "${extensionName}" on "${thisDomain}" get LocalStorage value: "isJSAllowed" = "${isJSAllowed}"`);

        /* ======================== */
        /* main object of sanitizer */
        /* ======================== */

        let jsBlockerSanitizer = new MutationObserver(mutations => {
            mutations.forEach(mutation => {
                [...mutation.addedNodes].forEach(node => {
                    if (node.nodeType === Node.ELEMENT_NODE) {
                        switch (node.tagName) {
                            case 'SCRIPT': /* removing embedded javascript */
                                if (!node.getAttribute('src')) {
                                    console.log(`Content blocker "${extensionName}" on "${thisDomain}" prevented display of embedded script`);
                                    node.remove();
                                }
                                break;
                            default: /* removing inline javascript (event handlers) */
                                [...node.attributes].forEach(attribute => {
                                    if (attribute.name.startsWith('on')) {
                                        console.log(`Content blocker "${extensionName}" on "${thisDomain}" prevented display of inline script: <${node.tagName} ${attribute.name}="…">`);
                                        node.removeAttribute(
                                            attribute.name
                                        );
                                    }
                                });
                        }
                    }
                });
            });
        });

        /* ================================================ */
        /* Safari normal mode: block / not block JavaScript */
        /* ================================================ */

        if (isLocalStorageAvailable === true) {

            if (isJSAllowed === true) {
                /* JavaScript enabled everywhere */
            }

            if (isJSAllowed === false || isJSAllowed === null) { /* block JavaScript by default */
                console.log(`Content blocker "${extensionName}" on "${thisDomain}" will block embedded and inline scripts`);
                jsBlockerSanitizer.observe(document.documentElement, {
                    subtree  : true,
                    childList: true
                });
            }

            if (isJSAllowed === null) { /* after cache clear...: request current state */
                safari.extension.dispatchMessage('isJSAllowedMsg', {
                    'fromDomain': thisDomain
                });
                safari.self.addEventListener('message', event => {
                    if (event.name === 'isJSAllowedMsg') {
                        console.log(`Content blocker "${extensionName}" on "${thisDomain}" capture "isJSAllowedMsg" event with response: domain = ${event.message.domain} | result = ${event.message.result} | timestamp = ${event.message.timestamp}`);
                        console.log(`Content blocker "${extensionName}" on "${thisDomain}" set LocalStorage value: "isJSAllowed" = "${event.message.result}"`);
                        window.localStorage.setItem('isJSAllowed', event.message.result);
                        setTimeout(() => {
                            window.location.reload();
                        }, updateInterval);
                    }
                });
            }

            /* ==================================== */
            /* request and update the changed state */
            /* ==================================== */

            let isFocused = false;
            window.addEventListener('blur' , () => { isFocused = false; });
            window.addEventListener('focus', () => {
                if (isFocused !== true) {
                    console.log(`Content blocker "${extensionName}" on "${thisDomain}" capture focus`);
                    safari.extension.dispatchMessage('reloadPageIfUpdatedMsg', {
                        'fromDomain': thisDomain
                    });
                }
                isFocused = true;
            });
            safari.self.addEventListener('message', event => {
                if (event.name === 'reloadPageIfUpdatedMsg') {
                    if (isJSAllowed !== event.message.result) {
                        console.log(`Content blocker "${extensionName}" on "${thisDomain}" capture "reloadPageIfUpdatedMsg" event with response: domain = ${event.message.domain} | result = ${event.message.result} | timestamp = ${event.message.timestamp}`);
                        console.log(`Content blocker "${extensionName}" on "${thisDomain}" update is required`);
                        console.log(`Content blocker "${extensionName}" on "${thisDomain}" get LocalStorage value: "isJSAllowed" = "${isJSAllowed}"`);
                        console.log(`Content blocker "${extensionName}" on "${thisDomain}" set LocalStorage value: "isJSAllowed" = "${event.message.result}"`);
                        window.localStorage.setItem('isJSAllowed', event.message.result);
                        if (isMainFrame) {
                            setTimeout(() => {
                                window.location.reload();
                            }, updateInterval);
                        }
                    } else {
                        console.log(`Content blocker "${extensionName}" on "${thisDomain}" capture "reloadPageIfUpdatedMsg" event with response: domain = ${event.message.domain} | result = ${event.message.result} | timestamp = ${event.message.timestamp}`);
                        console.log(`Content blocker "${extensionName}" on "${thisDomain}" update is not required`);
                    }
                }
            });

            /* =================================== */
            /* incoming request to reload the page */
            /* =================================== */

            safari.self.addEventListener('message', event => {
                if (event.name === 'reloadPageMsg') {
                    console.log(`Content blocker "${extensionName}" on "${thisDomain}" capture "reloadPageMsg" event with response: domain = ${event.message.domain} | result = ${event.message.result} | timestamp = ${event.message.timestamp}`);
                    console.log(`Content blocker "${extensionName}" on "${thisDomain}" set LocalStorage value: "isJSAllowed" = "${event.message.result}"`);
                    window.localStorage.setItem('isJSAllowed', event.message.result);
                    if (isMainFrame) {
                        setTimeout(() => {
                            window.location.reload();
                        }, updateInterval);
                    }
                }
            });

        }

        /* ================================================== */
        /* Safari high security mode: always block JavaScript */
        /* ================================================== */

        if (isLocalStorageAvailable === false) {

            console.log(`Content blocker "${extensionName}" on "${thisDomain}" (LocalStorage is off) will block embedded and inline scripts`);
            jsBlockerSanitizer.observe(document.documentElement, {
                subtree  : true,
                childList: true
            });

            /* =================================== */
            /* incoming request to reload the page */
            /* =================================== */

            if (isMainFrame) {
                safari.self.addEventListener('message', event => {
                    if (event.name === 'reloadPageMsg') {
                        console.log(`Content blocker "${extensionName}" on "${thisDomain}" capture "reloadPageMsg" event`);
                        setTimeout(() => {
                            window.location.reload();
                        }, updateInterval);
                    }
                });
            }

        }

    }

})();