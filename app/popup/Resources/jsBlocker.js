
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

    get isJSEnabled() {
        const url = new URL(window.location.href, document.baseURI);
        return url.searchParams.get('isJSEnabled') != 'false';
    },

    get isTopFrame() {
        try {
            return window.top === window;
        } catch (e) {
            return false;
        }
    },

    get isStorageAvailable() {
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
    },

    get domainName() {
        return (typeof window !== 'undefined' && window.location.hostname) || null;
    },

    getStorageValue: function(isRaw = true) {
        try {
            const JSONData = window.localStorage.getItem(this.LOCAL_STORAGE_KEY);
            console.log(
                `JS Blocker on "${this.domainName}"\n` +
                `Get Storage value "${this.LOCAL_STORAGE_KEY}": ${JSONData}`
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

    setStorageValue: function(JSONData) {
        try {
            window.localStorage.setItem(this.LOCAL_STORAGE_KEY, JSONData);
            console.log(
                `JS Blocker on "${this.domainName}"\n` +
                `Set Storage value "${this.LOCAL_STORAGE_KEY}": ${JSONData}`
            );
            return true;
        } catch (e) {
            return false;
        }
    },

    prepareFramesForBlockJS: function() {
        console.log(`JS Blocker on "${this.domainName}": prepare starts…`);
        const observer = new MutationObserver(mutations => {
            mutations.forEach(mutation => {
                [...mutation.addedNodes].forEach(node => {
                    if (node.nodeType === Node.ELEMENT_NODE) {
                        if (node.tagName === 'IFRAME' || node.tagName === 'FRAME') {
                            if (node.src) {
                                const url = new URL(node.src, document.baseURI);
                                url.searchParams.set('isJSEnabled', 'false');
                                node.src = url.toString();
                                console.log(`JS Blocker on "${this.domainName}": prepare <${node.tagName} src="${node.src}">`)
                            }
                        }
                    }
                });
            });
        });
        observer.observe(document.documentElement, {
            subtree  : true,
            childList: true,
        });
    },

    sanitize: function() {
        console.log(`JS Blocker on "${this.domainName}": sanitize starts…`);
        const observer = new MutationObserver(mutations => {
            mutations.forEach(mutation => {
                [...mutation.addedNodes].forEach(node => {
                    if (node.nodeType === Node.ELEMENT_NODE) {
                        switch (node.tagName) {
                            case 'SCRIPT': /* removing <script> */
                                console.log(`JS Blocker on "${this.domainName}": sanitize <SCRIPT src="${node.src}">`)
                                node.remove();
                                break;
                            default: /* removing <… on…="…" …> */
                                [...node.attributes].forEach(attribute => {
                                    if (attribute.name.startsWith('on')) {
                                        console.log(`JS Blocker on "${this.domainName}": sanitize <${node.tagName}> attribute "${attribute.name}"`)
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
        observer.observe(document.documentElement, {
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
    },

    pageReloadWhenExpired: function(domainName, expiresAt) {
        if (expiresAt > this.dateNow) {
            const lifeTime = (expiresAt - this.dateNow) * 1000
            setTimeout(() => { this.pageRequestMatch(domainName); },
                lifeTime + this.DELAY_BEFORE_RECHECK_STATE
            );
        }
    }

}
