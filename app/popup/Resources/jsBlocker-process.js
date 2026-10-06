
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

(() => {

    const domain = JSBlocker.domain;

    if (!domain) {
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
                `JS Blocker on "${domain}"\n` +
                `Receive Event: "${event.name}"`
            );
            JSBlocker.doAfterCondition(
                () => isDOMLoad,
                () => {
                    JSBlocker.msg_getScriptsResponse();
                    console.log(
                        `JS Blocker on "${domain}"\n` +
                        `Send Event: "js:getScripts.response"\n` +
                        `Scripts: ${JSBlocker.scriptsToString}`
                    );
                }
            );
        }
    });

    /* TOP FRAME */

    if (isTopFrame === true) {

        const isStorageAvailable = JSBlocker.isStorageAvailable;

        console.log(
            `JS Blocker on "${domain}" has been started\n` +
            `Extension URL: "${safari.extension.baseURI}"\n` +
            `Is Top Frame: yes\n` +
            `Is Storage available: ${isStorageAvailable ? "yes" : "no"}`
        );

        if (isStorageAvailable === false) {
            console.log(
                `JS Blocker on "${domain}"\n` +
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
                console.log(`JS Blocker on "${domain}": capture focus`);
                JSBlocker.msg_getMatchRequest();
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
                    `JS Blocker on "${domain}"\n` +
                    `Receive Event: "${event.name}"\n` +
                    `Old ${JSBlocker.STORAGE_KEY_FOR_SETTINGS}: ${oldSettings}\n` +
                    `New ${JSBlocker.STORAGE_KEY_FOR_SETTINGS}: ${newSettings}\n` +
                    `Update is required: ${isRequiredUpdate ? "yes" : "no"}`
                );
                if (isRequiredUpdate) {
                    JSBlocker.setSettings(newSettings);
                    JSBlocker.pageReload();
                }
            }
        });

        document.addEventListener('DOMContentLoaded', () => {
            if (scripts.size) {
                JSBlocker.msg_setScriptsRequest();
            }
        });

        JSBlocker.detectScripts();

        /* ====================================================================== */

        if (value === null) { /* after cache clear… */
            JSBlocker.sanitize();
            JSBlocker.prepareFramesForBlockJS();
            JSBlocker.msg_getMatchRequest();
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
            JSBlocker.sanitize(
                (value.scripts ?? []).reduce((result, script) => {
                    if (script.frameDomain == domain) {
                        result.push(
                            JSBlocker.CRC32(script.url)
                        )
                    }
                    return result
                }, [])
            );
            JSBlocker.prepareFramesForBlockJS(
                (value.scripts ?? []).reduce((result, script) => {
                    result[script.frameDomain] ??= []
                    result[script.frameDomain].push(
                        JSBlocker.CRC32(script.url)
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

        const scriptsCRC32s = JSBlocker.scriptsCRC32sFromURL;

        console.log(
            `JS Blocker on "${domain}" has been started\n` +
            `Extension URL: "${safari.extension.baseURI}"\n` +
            `URL: "${window.location.href}"\n` +
            `Is Top Frame: no\n` +
            `Scripts CRC32 from URL: ${scriptsCRC32s}`
        );

        document.addEventListener('DOMContentLoaded', () => {
            if (scripts.size) {
                JSBlocker.msg_setScriptsRequest();
            }
        });

        JSBlocker.detectScripts();

        if (scriptsCRC32s === null) {
            return;
        }

        if (scriptsCRC32s.length === 0) {
            JSBlocker.sanitize();
            return;
        }

        if (scriptsCRC32s.length > 0) {
            JSBlocker.sanitize(scriptsCRC32s);
            return;
        }

    }

})();
