![Banner](docs/banner.png)


# BeaverMeter

Utility tracking app that uses OCR technology to scan and monitor electricity, water, and gas consumption. It offers customizable meter setups, historical tracking, and consumption trends for efficient resource management, with the diligence of a beaver.

## Features

- 📷 **OCR Meter Scanning:** Automatically scan and log meter readings using your phone's camera.
- 🔌💧🔥 **Multi-Meter Support**: Track multiple meters (electricity, water, gas) from different locations.
- 📈 **Usage Trends & Graphs**: Visualize consumption patterns over time with simple charts.

## Technologies and tools
- [Flutter](https://flutter.dev) — Framework for building cross-platform mobile apps.
- [SQLite](https://www.sqlite.org/index.html) — Lightweight database engine for local storage.
- [Tesseract OCR](https://github.com/tesseract-ocr/tesseract) — Optical Character Recognition engine for text extraction.

## Todo

- [x] App idea and features list — *Completed*
- [x] Wireframes/app structure — *Completed*
- [ ] UI implementation and navigation - *In progress*
  - [x] Main page - navigation bar to meters, history, trends and setting
  - [x] Meters page 
    - [x] Meter list page - see statitics and actions to add reading, update prices 
    - [x] Meter details page
    - [x] Update / create meter pages
    - [x] Prices page 
    - [x] Update / create prices pages 
    - [x] Create reading page 
    - [ ] Meters page cleanup
  - [ ] History page - readings history
  - [ ] Trends page - dashboard with graphs
  - [ ] Settings page - notification settings
- [ ] Data persistence (DB layer) — *Pending*
- [ ] OCR feature — *Pending*
- [ ] App design — *Pending*
- [ ] Testing and deployment — *Pending*
