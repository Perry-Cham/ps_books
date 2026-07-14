## TODOS
### Bug Fixes

- Make light mode look nicer
- Wire up the mobireader so that it send progress data back to flutter
- Eventually move the reading logic of mobis and ppts files to the index.html file so that all the js can be bundled

### Improvements
- Create a zlib scraper
- Incorporate standard ebooks scraper into the download function. 
- Create a helper for the standard ebooks scraper that fetches the initial page to get reccomended titles

### Features To Implement
- Implement targets syncing with the p's books backend

### Completed
- Data export/import system: `.pbf` backup archives with selective export for timetable, targets, notes, and full app data; UUID-based conflict resolution on reimport

### Experiments 
- Make the reader Widget support dual reading on desktop
- Add a function to call AI from the reader, or perhaps wikipedia maybe both, why not.

