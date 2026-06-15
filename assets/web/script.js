import { PptxViewer, RECOMMENDED_ZIP_LIMITS } from "./aiden0z-pptx-renderer.es";

class pptViewer {
  constructor() {
    this.container = document.getElementById("reader");
  }

  async loadPPT(filePath) {
    const resp = await fetch(filePath);

    // One-liner: parse, build model, and render
    const viewer = await PptxViewer.open(await resp.arrayBuffer(), container, {
      zipLimits: RECOMMENDED_ZIP_LIMITS,
      listOptions: { windowed: true },
    });
  }
}

window.pptViewer = pptViewer;