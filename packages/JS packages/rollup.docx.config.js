import { nodeResolve } from '@rollup/plugin-node-resolve';
import commonjs from '@rollup/plugin-commonjs';
import terser from '@rollup/plugin-terser';

export default {
  input: 'src/docx/entry.js',
  output: {
    file: '../../app/assets/docx/docx-preview.min.js',
    format: 'iife',
    name: 'DocxPreview',
    sourcemap: false,
  },
  plugins: [commonjs(), nodeResolve(), terser()],
};
