import { PptxViewer, RECOMMENDED_ZIP_LIMITS } from "./aiden0z-pptx-renderer.es.js";

class pptViewer {
  constructor() {
    this.container = document.getElementById("reader");
  }

  async loadPPT(filePath) {
    const resp = await fetch(filePath);

    const viewer = await PptxViewer.open(await resp.arrayBuffer(), this.container, {
      zipLimits: RECOMMENDED_ZIP_LIMITS,
      listOptions: { windowed: true },
    });
  }
}

window.pptViewer = new pptViewer();
window.pptViewer.loadPPT("/get_file");
