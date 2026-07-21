import { PptxViewer, RECOMMENDED_ZIP_LIMITS } from "./aiden0z-pptx-renderer.es.js";

class pptViewer {
  constructor() {
    // Core UI elements
    this.container = document.getElementById("reader");
    this.pageNumberDisplay = document.querySelector("#slide-input");
    this.slideCountDisplay = document.querySelector("#slide-count");

    // Sidebar & menu
    this.sidebar = document.querySelector("#sidebar");
    this.thumbnailList = document.querySelector('#thumbnail-list');
    this.menuButton = document.querySelector("#menu-button");
    this.closeButton = document.querySelector("#close-button");

    // Lazy thumbnail state
    this.thumbnailHandles = new Map();
    this.thumbnailObserver = null;

    // Debounce for slide input
    this._debounceTimer = null;
  }

  async loadPPT(filePath) {
    const resp = await fetch(filePath);

    // Open the PPTX via the external renderer library
    this.viewer = await PptxViewer.open(await resp.arrayBuffer(), this.container, {
      zipLimits: RECOMMENDED_ZIP_LIMITS,
      listOptions: { windowed: true },
    });

    // Show total slide count and sync input on navigation
    this.slideCountDisplay.innerText = `of ${this.viewer.slideCount}`;
    this.viewer.addEventListener("slidechange", (e) => {
      this.pageNumberDisplay.value = e.detail.index;
      this.markActiveThumbnail(e.detail.index);
    });

    // Debounced manual slide input (1s delay)
    this.pageNumberDisplay.addEventListener("input", () => {
      clearTimeout(this._debounceTimer);
      this._debounceTimer = setTimeout(() => {
        const slide = parseInt(this.pageNumberDisplay.value, 10);
        if (isNaN(slide)) return;
        this.viewer.goToSlide(slide);
      }, 1000);
    });

    // Build thumbnail strip and wire up the sidebar toggle
    this.setupThumbnails();
    this.setupMenuToggle();
  }

  // Tear down all thumbnail handles and the observer
  cleanupThumbnails() {
    if (this.thumbnailObserver) {
      this.thumbnailObserver.disconnect();
      this.thumbnailObserver = null;
    }
    for (const handle of this.thumbnailHandles.values()) {
      handle.dispose();
    }
    this.thumbnailHandles.clear();
  }

  // Create the full thumbnail list with lazy rendering via IntersectionObserver
  setupThumbnails() {
    this.cleanupThumbnails();
    this.thumbnailList.innerHTML = '';
    if (!this.viewer) return;

    // Observe each thumbnail frame; mount when scrolled near, unmount when far away
    this.thumbnailObserver = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          const frame = entry.target;
          const item = frame.closest('.thumbnail-item');
          const index = Number(item?.dataset.slideIndex ?? '-1');
          if (!Number.isInteger(index) || index < 0) continue;
          if (entry.isIntersecting) {
            this.mountThumbnail(index, frame);
          } else {
            this.unmountThumbnail(index, frame);
          }
        }
      },
      { root: this.thumbnailList, rootMargin: '180px 0px', threshold: 0 },
    );

    // Build one button per slide
    for (let i = 0; i < this.viewer.slideCount; i++) {
      const item = document.createElement('button');
      item.type = 'button';
      item.className = 'thumbnail-item';
      item.dataset.slideIndex = String(i);
      item.addEventListener('click', () => this.viewer.goToSlide(i, { behavior: 'smooth' }));

      const label = document.createElement('span');
      label.className = 'thumbnail-label';
      label.textContent = `Slide ${i + 1}`;

      const frame = document.createElement('div');
      frame.className = 'thumbnail-frame';
      frame.innerHTML = '<div class="thumbnail-placeholder">Pending</div>';

      item.append(label, frame);
      this.thumbnailList.appendChild(item);
      this.thumbnailObserver.observe(frame);
    }
    this.markActiveThumbnail(this.viewer.currentSlideIndex);
  }

  // Render a thumbnail into a frame container
  mountThumbnail(index, frame) {
    if (!this.viewer || this.thumbnailHandles.has(index)) return;
    frame.innerHTML = '';
    const handle = this.viewer.renderThumbnailToContainer(index, frame, { width: 96 });
    if (!handle) {
      frame.innerHTML = '<div class="thumbnail-placeholder">Error</div>';
      return;
    }
    this.thumbnailHandles.set(index, handle);
    handle.ready.catch(() => {
      frame.innerHTML = '<div class="thumbnail-placeholder">Error</div>';
    });
  }

  // Unmount a thumbnail and release its handle
  unmountThumbnail(index, frame) {
    const handle = this.thumbnailHandles.get(index);
    if (!handle) return;
    handle.dispose();
    this.thumbnailHandles.delete(index);
    frame.innerHTML = '<div class="thumbnail-placeholder">Pending</div>';
  }

  // Highlight the thumbnail matching the current slide
  markActiveThumbnail(index) {
    for (const item of this.thumbnailList.querySelectorAll('.thumbnail-item')) {
      item.classList.toggle('active', Number(item.dataset.slideIndex) === index);
    }
  }

  // Wire up the hamburger / close-button / click-outside to show/hide the sidebar
  setupMenuToggle() {
    this.menuButton.addEventListener("click", () => {
      this.sidebar.classList.toggle("open");
      this.menuButton.classList.toggle("hide");
      this.closeButton.classList.toggle("hide");
    });

    this.closeButton.addEventListener("click", () => {
      this.sidebar.classList.remove("open");
      this.menuButton.classList.toggle("hide");
      this.closeButton.classList.toggle("hide");
    });

    // Clicking outside the sidebar or menu button also closes it
    document.addEventListener("click", (e) => {
      if (
        this.sidebar.classList.contains("open") &&
        !this.sidebar.contains(e.target) &&
        !this.menuButton.contains(e.target)
      ) {
        this.sidebar.classList.remove("open");
        this.closeButton.style.display = "none";
      }
    });
  }
}

// Boot the viewer
window.pptViewer = new pptViewer();
window.pptViewer.loadPPT("/get_file");
