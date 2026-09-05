
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

    /* TOP FRAME + FRAMES */

    let isDOMLoad = false;

    document.addEventListener('DOMContentLoaded', () => {
        isDOMLoad = true
    });

    safari.self.addEventListener('message', event => {
        if (event.name === 'js:getScripts.request') {
            console.log(
                        `JS Blocker on "${domainName}"\n` +
                        `Receive Event: "${event.name}"`
                        );
            JSBlocker.doAfterCondition(
                                       () => isDOMLoad,
                                       () => {
                                           const scriptsString = scripts.join('\n');
                                           console.log(
                                                       `JS Blocker on "${domainName}"\n` +
                                                       `Send Event: "js:getScripts.response"\n` +
                                                       `Scripts: ${scriptsString}`
                                                       );
                                           safari.extension.dispatchMessage('js:getScripts.response', {
                                               'domainName': domainName,
                                               'scripts': scriptsString
                                           });
                                       }
                                       );
        }
    });

    /* TOP FRAME */

    if (isTopFrame === true) {

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

        const value = JSBlocker.parseJSON(
                                          JSBlocker.getSettings()
                                          );

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
                const oldSettings = JSBlocker.getSettings();
                const newSettings = event.message.match;
                const isRequiredUpdate = oldSettings === null ||
                (oldSettings !== null && newSettings !== oldSettings);
                console.log(
                            `JS Blocker on "${domainName}"\n` +
                            `Receive Event: "${event.name}"\n` +
                            `Old ${JSBlocker.SETTINGS_STORAGE_KEY}: ${oldSettings}\n` +
                            `New ${JSBlocker.SETTINGS_STORAGE_KEY}: ${newSettings}\n` +
                            `Update is required: ${isRequiredUpdate ? "yes" : "no"}`
                            );
                if (isRequiredUpdate) {
                    JSBlocker.setSettings(newSettings);
                    JSBlocker.pageReload();
                }
            }
        });

        document.addEventListener('DOMContentLoaded', () => {
            if (scripts.length) {
                JSBlocker.pageScriptsNotify();
            }
        });

        JSBlocker.detectScripts();

        /* ====================================================================== */

        if (value === null) { /* after cache clear… */
            JSBlocker.sanitize();
            JSBlocker.prepareFramesForBlockJS();
            JSBlocker.pageRequestMatch();
            return;
        }

        if (value.match === JSBlocker.MATCH_TYPE_STRING_NO_ONE) {
            JSBlocker.sanitize();
            JSBlocker.prepareFramesForBlockJS();
            return;
        }

        if (value.match === JSBlocker.MATCH_TYPE_STRING_EXACT ||
            value.match === JSBlocker.MATCH_TYPE_STRING_WILDCARD) {
            if (value.item.expiresAt !== 0) {
                JSBlocker.pageReloadWhenExpired(value.item.expiresAt);
            }
            return;
        }

        if (value.match === JSBlocker.MATCH_TYPE_STRING_EXACT_SCRIPT ||
            value.match === JSBlocker.MATCH_TYPE_STRING_WILDCARD_SCRIPT) {
            JSBlocker.prepareFramesForBlockJS(
                (value.scripts ?? []).reduce((result, script) => {
                    result[script.frameDomain] ??= []
                    result[script.frameDomain].push(
                        JSBlocker.crc32(script.url)
                    )
                    return result
                }, {})
            );
            if (value.item.expiresAt !== 0) {
                JSBlocker.pageReloadWhenExpired(value.item.expiresAt);
            }
            return;
        }

    }

    /* FRAME */

    if (isTopFrame !== true) {

        const isJSEnabled = JSBlocker.isJSEnabledFromURL;
        const scripts     = JSBlocker.scriptsFromURL;

        console.log(
            `JS Blocker on "${domainName}" has been started\n` +
            `Extension URL: "${safari.extension.baseURI}"\n` +
            `URL: "${window.location.href}"\n` +
            `Is Top Frame: no\n` +
            `Param "isJSEnabled": ${isJSEnabled ? "yes" : "no"}`
        );

        document.addEventListener('DOMContentLoaded', () => {
            if (scripts.length) {
                JSBlocker.pageScriptsNotify();
            }
        });

        JSBlocker.detectScripts();

        if (!isJSEnabled) {
            JSBlocker.sanitize();
            return;
        }

    }

})();
