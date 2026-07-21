class DocxViewer {
  constructor() {
    this.container = document.getElementById("docx-container");
    this.zoomLevel = 1.0;
    this.zoomLevelDisplay = document.getElementById("zoom-level");

    document.getElementById("zoom-in").addEventListener("click", () => this.zoom(0.1));
    document.getElementById("zoom-out").addEventListener("click", () => this.zoom(-0.1));
  }

  async loadDocx(filePath) {
    const resp = await fetch(filePath);
    const blob = await resp.blob();
    await docx.renderAsync(blob, this.container, null, {
      useMathML: false,
      experimental: false,
    });
    this.container.style.transform = `scale(${this.zoomLevel})`;
    this.container.style.transformOrigin = "top left";
  }

  zoom(delta) {
    this.zoomLevel = Math.max(0.5, Math.min(3.0, this.zoomLevel + delta));
    this.container.style.transform = `scale(${this.zoomLevel})`;
    this.container.style.transformOrigin = "top left";
    this.zoomLevelDisplay.textContent = `${Math.round(this.zoomLevel * 100)}%`;
  }
}

window.docxViewer = new DocxViewer();
window.docxViewer.loadDocx("/get_file");
