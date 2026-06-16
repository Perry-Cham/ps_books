import './view.js';

class MobiReader {
  constructor() {
    this.view = null;
  }

  async open() {
    this.view = document.createElement('foliate-view');
    document.body.append(this.view);

    this.view.addEventListener('relocate', (e) => {
      const { fraction, section, location, time, tocItem, pageItem, cfi } = e.detail;
      PsBooksReader.postMessage(JSON.stringify({
        type: 'relocate',
        cfi,
        fraction,
        section,
        location,
        time,
        tocItem,
        pageItem,
      }));
    });

    await this.view.open('/get_file');

    PsBooksReader.postMessage(JSON.stringify({ type: 'load' }));
  }

  async goTo(target) {
    if (this.view) {
      await this.view.goTo(target);
    }
  }
}

const mobiReader = new MobiReader();
mobiReader.open().catch(console.error);
