
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

(() => {

    const domainName = JSBlocker.domainName;

    if (!domainName) {
        console.log(`JS Blocker error: unknown domain`);
        return;
    }

    const isMainFrame = JSBlocker.isMainFrame;
    const isLocalStorageAvailable = JSBlocker.isLocalStorageAvailable;

    console.log(
        `JS Blocker on "${domainName}" has been started\n` +
        `Base URL: "${safari.extension.baseURI}"\n` +
        `Is main frame: "${isMainFrame}"\n` +
        `Is LocalStorage available: "${isLocalStorageAvailable}"`
    );

    if (isLocalStorageAvailable === false) {
        console.log(
            `JS Blocker on "${domainName}"\n` +
            `LocalStorage is unavailable - block all scripts`
        );
        JSBlocker.sanitize();
        return;
    }

    const value = JSBlocker.getLocalStorageValue(false);

    /* MARK: registrate event listeners */

    let isFocused = false;

    window.addEventListener('blur', () => {
        isFocused = false;
    });

    window.addEventListener('focus', () => {
        if (isFocused !== true) {
            isFocused = true;
            console.log(`JS Blocker on "${domainName}": capture focus`);
            JSBlocker.pageRequestMatch(domainName);
        }
    });

    safari.self.addEventListener('message', event => {
        if (event.name === 'onChangeMatch') {
            const oldValue = JSBlocker.getLocalStorageValue(true)
            const newValue = event.message.match
            const isRequiredUpdation = oldValue === null ||
                                      (oldValue !== null && newValue !== oldValue)
            console.log(
                `JS Blocker on "${domainName}"\n` +
                `Event: "onChangeMatch"\n` +
                `Old Match: ${oldValue}\n` +
                `New Match: ${newValue}\n` +
                `Updation is required: ${isRequiredUpdation}`
            );
            if (isRequiredUpdation) {
                JSBlocker.setLocalStorageValue(event.message.match);
                if (isMainFrame) {
                    JSBlocker.pageReload();
                }
            }
        }
    });

    /* ====================================================================== */

    if (value === null) { /* after cache clear… */
        JSBlocker.sanitize();
        JSBlocker.pageRequestMatch(domainName);
        return;
    }

    if (value.match === "noOne") {
        JSBlocker.sanitize();
        return;
    }

    if (value.match === "exact" || value.match === "wildcard") {
        return;
    }

})();
