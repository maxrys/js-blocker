
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

(() => {

    const domainName = JSBlocker.domainName;

    if (!domainName) {
        console.log(`JS Blocker: unknown domain (probably IFRAME with empty SRC)`);
        return;
    }

    const isTopFrame = JSBlocker.isTopFrame;

    /* TOP FRAME */

    if (isTopFrame == true) {

        const isStorageAvailable = JSBlocker.isStorageAvailable;

        console.log(
            `JS Blocker on "${domainName}" has been started\n` +
            `Extension URL: "${safari.extension.baseURI}"\n` +
            `Is Top Frame: yes\n` +
            `Is Storage available: ${isStorageAvailable ? "yes" : "no"}`
        );

        if (isStorageAvailable === false) {
            console.log(
                `JS Blocker on "${domainName}"\n` +
                `Storage is unavailable - block all scripts`
            );
            JSBlocker.sanitize();
            return;
        }

        const value = JSBlocker.getStorageValue(false);

        /* ====================================================================== */

        let isFocused = false;

        window.addEventListener('blur', () => {
            isFocused = false;
        });

        window.addEventListener('focus', () => {
            if (isFocused !== true) {
                isFocused = true;
                console.log(`JS Blocker on "${domainName}": capture focus`);
                JSBlocker.pageRequestMatch();
            }
        });

        safari.self.addEventListener('message', event => {
            if (event.name === 'js:setMatch' ||
                event.name === 'js:getMatch.response') {
                const oldValue = JSBlocker.getStorageValue(true);
                const newValue = event.message.match;
                const isRequiredUpdate = oldValue === null ||
                                        (oldValue !== null && newValue !== oldValue);
                console.log(
                    `JS Blocker on "${domainName}"\n` +
                    `Receive Event: "${event.name}"\n` +
                    `Old Match: ${oldValue}\n` +
                    `New Match: ${newValue}\n` +
                    `Update is required: ${isRequiredUpdate ? "yes" : "no"}`
                );
                if (isRequiredUpdate) {
                    JSBlocker.setStorageValue(newValue);
                    JSBlocker.pageReload();
                }
            }
        });

        /* ====================================================================== */

        if (value === null) { /* after cache clear… */
            JSBlocker.sanitize();
            JSBlocker.prepareFramesForBlockJS();
            JSBlocker.pageRequestMatch();
            return;
        }

        if (value.match === "noOne") {
            JSBlocker.sanitize();
            JSBlocker.prepareFramesForBlockJS();
            return;
        }

        if (value.match === "exact") {
            if (value.item.expiresAt !== 0) {
                JSBlocker.pageReloadWhenExpired(value.item.expiresAt);
            }
            return;
        }

        if (value.match === "wildcard") {
            if (value.item.expiresAt !== 0) {
                JSBlocker.pageReloadWhenExpired(value.item.expiresAt);
            }
            return;
        }

    }

    /* FRAME */

    if (isTopFrame != true) {

        const isJSEnabled = JSBlocker.isJSEnabled;

        console.log(
            `JS Blocker on "${domainName}" has been started\n` +
            `Extension URL: "${safari.extension.baseURI}"\n` +
            `URL: "${window.location.href}"\n` +
            `Is Top Frame: no\n` +
            `Param "isJSEnabled": ${isJSEnabled ? "yes" : "no"}`
        );

        if (!isJSEnabled) {
            JSBlocker.sanitize();
            return;
        }

    }

})();
