import { nodeResolve } from '@rollup/plugin-node-resolve';
import commonjs from '@rollup/plugin-commonjs';
import terser from '@rollup/plugin-terser';

export default {
  input: 'src/pptx/entry.js',
  output: {
    file: '../../app/assets/pptx/aiden0z-pptx-renderer.es.js',
    format: 'esm',
    sourcemap: false,
  },
  plugins: [commonjs(), nodeResolve(), terser()],
};
