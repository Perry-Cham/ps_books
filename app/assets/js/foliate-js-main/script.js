import './view.js';
import { createTOCView } from './ui/tree.js';
import { createMenu } from './ui/menu.js';
import { Overlayer } from './overlayer.js';

const getCSS = ({ spacing, justify, hyphenate }) => `
    @namespace epub "http://www.idpf.org/2007/ops";
    html {
        color-scheme: light dark;
    }
    @media (prefers-color-scheme: dark) {
        a:link {
            color: lightblue;
        }
    }
    p, li, blockquote, dd {
        line-height: ${spacing};
        text-align: ${justify ? 'justify' : 'start'};
        -webkit-hyphens: ${hyphenate ? 'auto' : 'manual'};
        hyphens: ${hyphenate ? 'auto' : 'manual'};
        -webkit-hyphenate-limit-before: 3;
        -webkit-hyphenate-limit-after: 2;
        -webkit-hyphenate-limit-lines: 2;
        hanging-punctuation: allow-end last;
        widows: 2;
    }
    [align="left"] { text-align: left; }
    [align="right"] { text-align: right; }
    [align="center"] { text-align: center; }
    [align="justify"] { text-align: justify; }
    pre {
        white-space: pre-wrap !important;
    }
    aside[epub|type~="endnote"],
    aside[epub|type~="footnote"],
    aside[epub|type~="note"],
    aside[epub|type~="rearnote"] {
        display: none;
    }
`;

const $ = document.querySelector.bind(document);

const locales = 'en';
const percentFormat = new Intl.NumberFormat(locales, { style: 'percent' });
const listFormat = new Intl.ListFormat(locales, { style: 'short', type: 'conjunction' });

const formatLanguageMap = x => {
    if (!x) return '';
    if (typeof x === 'string') return x;
    const keys = Object.keys(x);
    return x[keys[0]];
};

const formatOneContributor = contributor => typeof contributor === 'string'
    ? contributor : formatLanguageMap(contributor?.name);

const formatContributor = contributor => Array.isArray(contributor)
    ? listFormat.format(contributor.map(formatOneContributor))
    : formatOneContributor(contributor);

class MobiReader {
    #tocView;
    style = { spacing: 1.4, justify: true, hyphenate: true };
    annotations = new Map();
    annotationsByValue = new Map();

    constructor() {
        this.view = null;

        $('#side-bar-button').addEventListener('click', () => {
            $('#dimming-overlay').classList.add('show');
            $('#side-bar').classList.add('show');
        });
        $('#dimming-overlay').addEventListener('click', () => this.closeSideBar());

        const menu = createMenu([
            {
                name: 'layout',
                label: 'Layout',
                type: 'radio',
                items: [
                    ['Paginated', 'paginated'],
                    ['Scrolled', 'scrolled'],
                ],
                onclick: value => {
                    this.view?.renderer.setAttribute('flow', value);
                },
            },
        ]);
        menu.element.classList.add('menu');
        $('#menu-button').append(menu.element);
        $('#menu-button > button').addEventListener('click', () =>
            menu.element.classList.toggle('show'));
        menu.groups.layout.select('paginated');
    }

    closeSideBar() {
        $('#dimming-overlay').classList.remove('show');
        $('#side-bar').classList.remove('show');
    }

    // -----------------------------------------------------------------------
    // Flutter bridge
    // -----------------------------------------------------------------------
    //
    // The Dart side registers a JavaScriptChannel named `flutterChannel` on
    // its WebViewController. Flutter injects a global `window.flutterChannel`
    // object whose `.postMessage(string)` is forwarded to the Dart
    // `onMessageReceived` callback.
    //
    // We always JSON-encode the payload so the Dart side can `jsonDecode`
    // it uniformly and dispatch on the `type` field.
    //
    // The Dart side never injects this object — if the channel isn't
    // registered (e.g. when the HTML is opened in a regular browser), the
    // calls are silently no-ops thanks to optional chaining.
    _postToFlutter(type, payload = {}) {
        try {
            const msg = JSON.stringify({ type, ...payload });
            window.flutterChannel.postMessage?.(msg);
        } catch (e) {
            console.error('Failed to post to flutterChannel:', e);
        }
    }

    async open() {
        this.view = document.createElement('foliate-view');
        document.body.append(this.view);

        await this.view.open('/get_file');
        const { book } = this.view;

        this.view.addEventListener('load', this.#onLoad.bind(this));
        this.view.addEventListener('relocate', this.#onRelocate.bind(this));

        book.transformTarget?.addEventListener('data', ({ detail }) => {
            detail.data = Promise.resolve(detail.data).catch(e => {
                console.error(new Error(`Failed to load ${detail.name}`, { cause: e }));
                return '';
            });
        });

        this.view.renderer.setStyles?.(getCSS(this.style));
        this.view.renderer.next();

        $('#header-bar').style.visibility = 'visible';
        $('#nav-bar').style.visibility = 'visible';
        $('#left-button').addEventListener('click', () => this.view.goLeft());
        $('#right-button').addEventListener('click', () => this.view.goRight());

        const slider = $('#progress-slider');
        slider.dir = book.dir;
        slider.addEventListener('input', e =>
            this.view.goToFraction(parseFloat(e.target.value)));
        for (const fraction of this.view.getSectionFractions()) {
            const option = document.createElement('option');
            option.value = fraction;
            $('#tick-marks').append(option);
        }

        document.addEventListener('keydown', this.#handleKeydown.bind(this));

        const title = formatLanguageMap(book.metadata?.title) || 'Untitled Book';
        document.title = title;
        $('#side-bar-title').innerText = title;
        $('#side-bar-author').innerText = formatContributor(book.metadata?.author);
        Promise.resolve(book.getCover?.())?.then(blob =>
            blob ? $('#side-bar-cover').src = URL.createObjectURL(blob) : null);

        const toc = book.toc;
        if (toc) {
            this.#tocView = createTOCView(toc, href => {
                this.view.goTo(href).catch(e => console.error(e));
                this.closeSideBar();
            });
            $('#toc-view').append(this.#tocView.element);
        }

        const bookmarks = await book.getCalibreBookmarks?.();
        if (bookmarks) {
            const { fromCalibreHighlight } = await import('./epubcfi.js');
            for (const obj of bookmarks) {
                if (obj.type === 'highlight') {
                    const value = fromCalibreHighlight(obj);
                    const color = obj.style.which;
                    const note = obj.notes;
                    const annotation = { value, color, note };
                    const list = this.annotations.get(obj.spine_index);
                    if (list) list.push(annotation);
                    else this.annotations.set(obj.spine_index, [annotation]);
                    this.annotationsByValue.set(value, annotation);
                }
            }
            this.view.addEventListener('create-overlay', e => {
                const { index } = e.detail;
                const list = this.annotations.get(index);
                if (list) for (const annotation of list)
                    this.view.addAnnotation(annotation);
            });
            this.view.addEventListener('draw-annotation', e => {
                const { draw, annotation } = e.detail;
                const { color } = annotation;
                draw(Overlayer.highlight, { color });
            });
            this.view.addEventListener('show-annotation', e => {
                const annotation = this.annotationsByValue.get(e.detail.value);
                if (annotation.note) alert(annotation.note);
            });
        }

        try {
            const res = await fetch('/get_position');
            const { cfi } = await res.json();
            if (cfi) {
                await this.view.goTo(cfi);
            }
        } catch (e) {
            console.error('Failed to restore position:', e);
        }
    }

    #handleKeydown(event) {
        const k = event.key;
        if (k === 'ArrowLeft' || k === 'h') this.view.goLeft();
        else if (k === 'ArrowRight' || k === 'l') this.view.goRight();
    }

    #onLoad({ detail: { doc } }) {
        doc.addEventListener('keydown', this.#handleKeydown.bind(this));
    }

    getCFI() {
        return this.view?.lastLocation?.cfi || null;
    }

    setTheme(themeName) {
        const themeMap = {
            light: { bg: '#FFFFFFF8', fg: '#1A1A1A' },
            sepia: { bg: '#D4C4A8', fg: '#1A1A1A' },
            dark: { bg: '#04060F', fg: '#E8DCC8' },
        };
        const t = themeMap[themeName] || themeMap.light;
        const css = `
            html { background: ${t.bg} !important; color: ${t.fg} !important; }
            body { background: ${t.bg} !important; color: ${t.fg} !important; }
            * { color: ${t.fg} !important; }
            a:link { color: ${themeName === 'dark' ? 'lightblue' : '#2563EB'} !important; }
        `;
        this.view?.renderer?.setStyles?.(css);

        const styleId = 'reader-theme-override';
        let style = document.getElementById(styleId);
        if (!style) {
            style = document.createElement('style');
            style.id = styleId;
            document.head.prepend(style);
        }
        style.textContent = `
            :root { background: ${t.bg} !important; color: ${t.fg} !important; }
            html, body { background: ${t.bg} !important; color: ${t.fg} !important; }
        `;
    }

    #onRelocate({ detail }) {
        const { fraction, location, tocItem, pageItem, cfi, range } = detail;
        const percent = percentFormat.format(fraction);
        const loc = pageItem
            ? `Page ${pageItem.label}`
            : `Loc ${location.current}`;
        const slider = $('#progress-slider');
        slider.style.visibility = 'visible';
        slider.value = fraction;
        slider.title = `${percent} · ${loc}`;
        if (tocItem?.href) this.#tocView?.setCurrentHref?.(tocItem.href);

        // Push the new position to Flutter so the Dart side can persist it.
        this._postToFlutter('relocate', {
            cfi: cfi ?? null,
            fraction,
            label: tocItem?.label ?? loc,
            href: tocItem?.href ?? null,
            location: location?.current ?? null,
        });
    }

    async goTo(target) {
        if (this.view) {
           await this.view.goTo(target);
        }
    }

    // -----------------------------------------------------------------------
    // DestinationCapable — methods invoked from Dart via runJavaScript*
    // -----------------------------------------------------------------------

    /// Returns the document's TOC as a JSON string in the lingua-franca
    /// shape: `[{ label, locator, level, children: [...] }]`.
    ///
    /// The locator is the TOC entry's `href` — pass it back to
    /// [goToDestinationByLocator] to navigate.
    getDestinationsJSON() {
        const toc = this.view?.book?.toc ?? [];
        const map = (item, level) => ({
            label: item.label ?? item.title ?? '(untitled)',
            locator: item.href ?? item.url ?? '',
            level,
            children: (item.subitems ?? []).map(c => map(c, level + 1)),
        });
        return JSON.stringify(toc.map(i => map(i, 0)));
    }

    /// Navigates to a destination by its locator (the `href` produced by
    /// [getDestinationsJSON]). Wrapped around the existing [goTo] so the
    /// Dart side does not need to know about the underlying view API.
    async goToDestinationByLocator(locator) {
        if (!this.view || !locator) return;
        try {
            await this.view.goTo(locator);
        } catch (e) {
            console.error('goToDestinationByLocator failed:', e);
        }
    }

    /// Returns the current CFI (or null) — used by Dart on dispose to
    /// persist the last reading position.
    getCurrentCFI() {
        return this.view?.lastLocation?.cfi ?? null;
    }
}

window.mobiReader = new MobiReader();
window.mobiReader.open().catch(console.error);
