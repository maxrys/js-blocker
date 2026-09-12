
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
    STORAGE_KEY_FOR_SETTINGS: 'JSBlockerSettings',
    URL_KEY_FOR_JS_STATE: 'JSBlockerState',
    URL_INTERNAL_SCRIPT: 'internal://script',
    URL_INTERNAL_ATTRIBUTE_SCRIPT: "internal://script-attribute",
    DELAY_FOR_PAGE_RELOAD: 500,
    DELAY_BEFORE_RECHECK_STATE: 2000,

    get dateNow() {
        return Math.floor(Date.now() / 1000);
    },

    get jsStateFromURL() {
        const url = new URL(window.location.href, document.baseURI);
        const params = url.searchParams;
        if (!params.has(this.URL_KEY_FOR_JS_STATE)) {
            return null;
        }
        const scripts = params.get(this.URL_KEY_FOR_JS_STATE);
        if (scripts)
             { return scripts.split(',') }
        else { return [] }
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
            const JSONstring = window.localStorage.getItem(this.STORAGE_KEY_FOR_SETTINGS);
            console.log(
                `JS Blocker on "${this.domainName}"\n` +
                `Get ${this.STORAGE_KEY_FOR_SETTINGS}: ${JSONstring}`
            );
            return JSONstring;
        } catch (e) {
            return null;
        }
    },

    setSettings(JSONstring) {
        try {
            window.localStorage.setItem(this.STORAGE_KEY_FOR_SETTINGS, JSONstring);
            console.log(
                `JS Blocker on "${this.domainName}"\n` +
                `Set ${this.STORAGE_KEY_FOR_SETTINGS}: ${JSONstring}`
            );
            return true;
        } catch (e) {
            return false;
        }
    },

    prepareFramesForBlockJS(scriptsCrcByFrames = []) {
        console.log(`JS Blocker on "${this.domainName}": preparation frames starts…`);
        const observer = new MutationObserver(mutations => {
            mutations.forEach(mutation => {
                [...mutation.addedNodes].forEach(node => {
                    if (node.nodeType === Node.ELEMENT_NODE) {
                        if (node.tagName === 'IFRAME' || node.tagName === 'FRAME') {
                            if (node.src) {
                                const url = new URL(node.src, document.baseURI);
                                const frameDomain = url.hostname
                                const scripts = scriptsCrcByFrames[frameDomain] ?? []
                                if (scripts.length)
                                     { url.searchParams.set(this.URL_KEY_FOR_JS_STATE, scripts.join(',')); }
                                else { url.searchParams.set(this.URL_KEY_FOR_JS_STATE, ''); }
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
                            } else {
                                if (!scripts.includes(this.URL_INTERNAL_SCRIPT)) { scripts.push(this.URL_INTERNAL_SCRIPT); }
                                console.log(`JS Blocker on "${this.domainName}": detected internal script`);
                            }
                        }
                        /* attributes <… on…="…" …> */
                        [...node.attributes].forEach(attribute => {
                            if (attribute.name.startsWith('on')) {
                                if (!scripts.includes(this.URL_INTERNAL_ATTRIBUTE_SCRIPT)) { scripts.push(this.URL_INTERNAL_ATTRIBUTE_SCRIPT); }
                                console.log(`JS Blocker on "${this.domainName}": detected attribute "${attribute.name}" on ${node.tagName}`);
                            }
                        });
                    }
                });
            });
        });
        observer.observe(document.documentElement, {
            subtree  : true,
            childList: true,
        });
    },

    sanitize(scriptsCrc = []) {
        console.log(`JS Blocker on "${this.domainName}": sanitization scripts starts…`);
        const isAllowedInternalScripts          = scriptsCrc.includes(this.crc32(this.URL_INTERNAL_SCRIPT));
        const isAllowedInternalAttributeScripts = scriptsCrc.includes(this.crc32(this.URL_INTERNAL_ATTRIBUTE_SCRIPT));
        const observer = new MutationObserver(mutations => {
            mutations.forEach(mutation => {
                [...mutation.addedNodes].forEach(node => {
                    if (node.nodeType === Node.ELEMENT_NODE) {
                        if (node.tagName === 'SCRIPT') { /* removing <script> */
                            if (node.src) {
                                const crc32 = this.crc32(this.clearURL(node.src));
                                if (!scriptsCrc.includes(crc32)) {
                                    node.remove();
                                    console.log(`JS Blocker on "${this.domainName}": sanitized external script "${node.src}"`);
                                }
                            } else {
                                if (!isAllowedInternalScripts) {
                                    node.remove();
                                    console.log(`JS Blocker on "${this.domainName}": sanitized internal script`);
                                }
                            }
                        }
                        /* attributes <… on…="…" …> */
                        if (!isAllowedInternalAttributeScripts) {
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
            childList: true,
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
    },

    crc32(str) {
        const bytes = new TextEncoder().encode(str);
        let crc = 0xffffffff;
        for (const byte of bytes) {
            crc ^= byte;
            for (let i = 0; i < 8; i++) {
                crc = (crc >>> 1) ^ (crc & 1 ? 0xedb88320 : 0);
            }
        }
        return ((crc ^ 0xffffffff) >>> 0)
            .toString(16)
            .padStart(8, "0");
    }

};
