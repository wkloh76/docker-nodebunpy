# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2025-08-11

### Summary

- Design docker images which will able deploy the project in `NodeJS` , `BunJS` or `Python3` design.

### Added

- Upgrade bun.js version to 1.2.20 and nodejs version 20.19.4. Completed on 2025-08-11
- Add tar package. Completed on 2025-08-15
### Changed

### Deprecated

### Removed

### Fixed

### Security

[1.0.1]: https://github.com/wkloh76/docker-nodebunpy/releases/tag/1.0.1

## [1.0.0] - 2025-04-11

### Summary

- Design docker images which will able deploy the project in `NodeJS` , `BunJS` or `Python3` design.

### Added

- Add `MAIN_APP` docker environment variable which will design the interpreter engine run script base on setting. Completed on 2025-04-14
- Upgrade bun.js version to 1.2.17 and nodejs version 20.19.2. Completed on 2025-06-23
- Add `SYNO` environment variable to decide which method to build node_modules. Completed on 2025-06-24

### Changed

- Update container service `nodebun-deploy` to `nodebun_deploy` at docker-compose.yml file. Completed on 2025-04-11
- Remove create symbolic link in `install_modules.js` after node_modules finish establish. Completed on 2025-06-24

### Deprecated

### Removed

### Fixed

- Remove `strict` from `install_modules.js`.Completed on 2025-04-11
- Fix missing `/build` folder. Completed on 2025-06-23

### Security

[1.0.0]: https://github.com/wkloh76/docker-nodebunpy/releases/tag/1.0.0
