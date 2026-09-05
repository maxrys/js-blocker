
/* ################################################################## */
/* ### Copyright © 2024—2026 Maxim Rysevets. All rights reserved. ### */
/* ################################################################## */

var scripts = [];

const JSBlocker = {

    MATCH_TYPE_STRING_NO_ONE: 'noOne',
    MATCH_TYPE_STRING_EXACT: 'exact',
    MATCH_TYPE_STRING_EXACT_SCRIPT: 'exactScript',
    MATCH_TYPE_STRING_WILDCARD: 'wildcard',
    MATCH_TYPE_STRING_WILDCARD_SCRIPT: 'wildcardScript',
    SETTINGS_STORAGE_KEY: 'JSBlockerSettings',
    DELAY_FOR_PAGE_RELOAD: 500,
    DELAY_BEFORE_RECHECK_STATE: 2000,

    get dateNow() {
        return Math.floor(Date.now() / 1000);
    },

    get isJSEnabled() {
        const url = new URL(window.location.href, document.baseURI);
        return url.searchParams.get('isJSEnabled') !== 'false';
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
        return (typeof window !== 'undefined' && window.location?.hostname) || null;
    },

    clearURL(URLString) { /* extract only "protocol://domain/path" */
        const url = new URL(URLString);
        return url.origin + url.pathname;
    },

    parseJSON(JSONstring) {
        try {
            if (JSONstring !== null) {
                const parsed = JSON.parse(JSONstring);
                if (parsed && typeof parsed === 'object' && !Array.isArray(parsed)) {
                    return parsed;
                }
            }
            return null;
        } catch {
            return null;
        }
    },

    getSettings() {
        try {
            const JSONstring = window.localStorage.getItem(this.SETTINGS_STORAGE_KEY);
            console.log(
                `JS Blocker on "${this.domainName}"\n` +
                `Get ${this.SETTINGS_STORAGE_KEY}: ${JSONstring}`
            );
            return JSONstring;
        } catch (e) {
            return null;
        }
    },

    setSettings(JSONstring) {
        try {
            window.localStorage.setItem(this.SETTINGS_STORAGE_KEY, JSONstring);
            console.log(
                `JS Blocker on "${this.domainName}"\n` +
                `Set ${this.SETTINGS_STORAGE_KEY}: ${JSONstring}`
            );
            return true;
        } catch (e) {
            return false;
        }
    },

    detectScripts() {
        console.log(`JS Blocker on "${this.domainName}": detection scripts starts…`);
        const observer = new MutationObserver(mutations => {
            mutations.forEach(mutation => {
                [...mutation.addedNodes].forEach(node => {
                    if (node.nodeType === Node.ELEMENT_NODE) {
                        if (node.tagName === 'SCRIPT') {
                            if (node.src) {
                                const clearURL = this.clearURL(node.src)
                                scripts.push(clearURL);
                                console.log(`JS Blocker on "${this.domainName}": detected external script "${clearURL}"`);
                            }
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

    prepareFramesForBlockJS() {
        console.log(`JS Blocker on "${this.domainName}": preparation frames starts…`);
        const observer = new MutationObserver(mutations => {
            mutations.forEach(mutation => {
                [...mutation.addedNodes].forEach(node => {
                    if (node.nodeType === Node.ELEMENT_NODE) {
                        if (node.tagName === 'IFRAME' || node.tagName === 'FRAME') {
                            if (node.src) {
                                const url = new URL(node.src, document.baseURI);
                                url.searchParams.set('isJSEnabled', 'false');
                                node.src = url.toString();
                                console.log(`JS Blocker on "${this.domainName}": prepared ${node.tagName} "${node.src}"`);
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

    sanitize() {
        console.log(`JS Blocker on "${this.domainName}": sanitization scripts starts…`);
        const observer = new MutationObserver(mutations => {
            mutations.forEach(mutation => {
                [...mutation.addedNodes].forEach(node => {
                    if (node.nodeType === Node.ELEMENT_NODE) {
                        if (node.tagName === 'SCRIPT') { /* removing <script> */
                            const src = node.src;
                            node.remove();
                            if (src) { console.log(`JS Blocker on "${this.domainName}": sanitized external script "${src}"`); }
                            else     { console.log(`JS Blocker on "${this.domainName}": sanitized internal script`); }
                        } else { /* removing <… on…="…" …> */
                            [...node.attributes].forEach(attribute => {
                                if (attribute.name.startsWith('on')) {
                                    node.removeAttribute(attribute.name);
                                    console.log(`JS Blocker on "${this.domainName}": sanitized attribute "${attribute.name}" on ${node.tagName}`);
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

    pageScriptsNotify() {
        safari.extension.dispatchMessage('js:setScripts.request', {
            'domainName': this.domainName,
            'scripts': scripts.join('\n')
        });
    },

    pageRequestMatch() {
        safari.extension.dispatchMessage('js:getMatch.request', {
            'domainName': this.domainName
        });
    },

    pageReload(delay = this.DELAY_FOR_PAGE_RELOAD) {
        setTimeout(() => {
            window.location.reload();
        }, delay);
    },

    pageReloadWhenExpired(expiresAt) {
        if (expiresAt > this.dateNow) {
            const lifeTime = (expiresAt - this.dateNow) * 1000;
            setTimeout(() => { this.pageRequestMatch(); },
                lifeTime + this.DELAY_BEFORE_RECHECK_STATE
            );
        }
    },

    doAfterCondition(condition, action, interval = 500) {
        const check = () => {
            if (condition()) {
                action();
            } else {
                setTimeout(check, interval);
            }
        };
        check();
    }

};
