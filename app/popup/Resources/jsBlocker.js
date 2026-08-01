
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

const JSBlocker = {

    LOCAL_STORAGE_KEY: 'JSBlockerData',
    DELAY_FOR_PAGE_RELOAD: 500,
    DELAY_BEFORE_RECHECK_STATE: 2000,

    get dateNow() {
        return Math.floor(Date.now() / 1000);
    },

    isMainFrame: (() => {
        try {
            return window.parent === window;
        } catch (e) {
            return false;
        }
    })(),

    isLocalStorageAvailable: (() => {
        try {
            const value = Math.random().toString(36).slice(2);
            const key = `test_${value}`;
            window.localStorage.setItem(key, value);
            const storageValue = window.localStorage.getItem(key);
            window.localStorage.removeItem(key);
            return storageValue === value;
        } catch (e) {
            return false;
        }
    })(),

    domainName: (() => {
        var result;

        try {
            result = window.location && window.location.hostname;
        } catch (e) {
            return null;
        }

        if (typeof result !== 'string' || result.length === 0) {
            return null;
        }

        return result;
    })(),

    getLocalStorageValue: function(isRaw = true) {
        try {
            const JSONData = window.localStorage.getItem(this.LOCAL_STORAGE_KEY);
            console.log(
                `JS Blocker on "${this.domainName}"\n` +
                `Get LocalStorage value "${this.LOCAL_STORAGE_KEY}": ${JSONData}`
            );
            if (isRaw) {
                return JSONData;
            }
            if (JSONData !== null) {
                const parsed = JSON.parse(JSONData);
                if (parsed && typeof parsed === 'object' && !Array.isArray(parsed)) {
                    return parsed;
                }
            }
            return null;
        } catch (e) {
            return null;
        }
    },

    setLocalStorageValue: function(JSONData) {
        try {
            window.localStorage.setItem(this.LOCAL_STORAGE_KEY, JSONData);
            console.log(
                `JS Blocker on "${this.domainName}"\n` +
                `Set LocalStorage value "${this.LOCAL_STORAGE_KEY}": ${JSONData}`
            );
            return true;
        } catch (e) {
            return false;
        }
    },

    sanitize: function() {
        const sanitizer = new MutationObserver(mutations => {
            mutations.forEach(mutation => {
                [...mutation.addedNodes].forEach(node => {
                    if (node.nodeType === Node.ELEMENT_NODE) {
                        switch (node.tagName) {
                            case 'SCRIPT': /* removing <script> */
                                console.log(`JS Blocker on "${this.domainName}": remove <SCRIPT src="${node.src}">`);
                                node.remove();
                                break;
                            default: /* removing <… on…="…" …> */
                                [...node.attributes].forEach(attribute => {
                                    if (attribute.name.startsWith('on')) {
                                        console.log(`JS Blocker on "${this.domainName}": remove attribute "${attribute.name}" in <${node.tagName}>`);
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
        console.log(`JS Blocker on "${this.domainName}": the DOM Tree cleaning process starts…`);
        sanitizer.observe(document.documentElement, {
            subtree  : true,
            childList: true
        });
    },

    pageRequestMatch: function(domainName) {
        safari.extension.dispatchMessage('onChangeMatch', {
            'forDomain': domainName
        });
    },

    pageReload: function(delay = this.DELAY_FOR_PAGE_RELOAD) {
        setTimeout(() => {
            window.location.reload();
        }, delay);
    }

}
