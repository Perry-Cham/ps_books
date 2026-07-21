import { nodeResolve } from '@rollup/plugin-node-resolve';
import terser from '@rollup/plugin-terser';
import { copy } from 'fs-extra';

const copyPDFJS = () => ({
  name: 'copy-pdfjs',
  async writeBundle() {
    await copy('foliate-js/node_modules/pdfjs-dist/build/pdf.mjs', 'foliate-js/vendor/pdfjs/pdf.mjs');
    await copy('foliate-js/node_modules/pdfjs-dist/build/pdf.mjs.map', 'foliate-js/vendor/pdfjs/pdf.mjs.map');
    await copy('foliate-js/node_modules/pdfjs-dist/build/pdf.worker.mjs', 'foliate-js/vendor/pdfjs/pdf.worker.mjs');
    await copy('foliate-js/node_modules/pdfjs-dist/build/pdf.worker.mjs.map', 'foliate-js/vendor/pdfjs/pdf.worker.mjs.map');
    await copy('foliate-js/node_modules/pdfjs-dist/cmaps', 'foliate-js/vendor/pdfjs/cmaps');
    await copy('foliate-js/node_modules/pdfjs-dist/standard_fonts', 'foliate-js/vendor/pdfjs/standard_fonts');
  },
});

export default [
  {
    input: 'foliate-js/rollup/fflate.js',
    output: {
      dir: 'foliate-js/vendor/',
      format: 'esm',
    },
    plugins: [nodeResolve(), terser()],
  },
  {
    input: 'foliate-js/rollup/zip.js',
    output: {
      dir: 'foliate-js/vendor/',
      format: 'esm',
    },
    plugins: [nodeResolve(), terser(), copyPDFJS()],
  },
];
