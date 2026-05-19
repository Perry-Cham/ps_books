
## TODOS
### Bug Fixes

- Fix google drive auth on android by adding clientid (somewhere beats me)
- add a download provider changer for libgen, zlib and standard ebooks, 
- Add a copyright disclaimer saying that this is an education project< I do not own own any of the books and that users should check copyright laws
- Add currently reading section in library page
- Add black overlay on download books in download page so text doesn't blend into images
- Rewire the study form so that it takes in TimeOfDays rather than plain text strings as session times so that the notifications work or work better
- Add reworked microsoft viewer package to pubspec.yaml to fix rendering issue on desktop

### Features To Implement
- Complete fb2 reader using katbook ebook reader as inspiration
- Implement mobi reader using dart_mobi_reader as the base then implement custom renderer using katbook epub reader as inspiration
- Light Mode support with a toggle in settings if I feel so inspired