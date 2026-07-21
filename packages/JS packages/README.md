# JS Packages

Unlike the Flutter/Dart packages in this workspace, the JavaScript packages 
here are direct mirrors of their upstream counterparts with minimal to no 
modifications.

## Contents

- **pptx/** — Source entry for building `@aiden0z/pptx-renderer` into a minified ES module.
- **docx/** — Source entry for building `docx-preview` into a minified IIFE bundle.
- **foliate-js/** — Mirror of [foliate-js](https://github.com/johnfactotum/foliate-js) 
  (upstream git source), a JS library for rendering e-book formats (EPUB, MOBI, 
  FB2, PDF, CBZ) in the browser.

## Build

```bash
pnpm install
pnpm build:all
```

This produces the minified JS files in `app/assets/pptx/`, `app/assets/docx/`, 
and populates the `foliate-js/vendor/` directory with bundled dependencies 
(zip.js, fflate, pdfjs-dist).
