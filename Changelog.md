# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2025-10-03

### Summary

- Design docker images which will able deploy the project in `NodeJS` , `BunJS` or `Python3` design.
- Security release addressing CVE-2026-111497.

### Added

- ~~Upgrade bun.js version to 1.2.23 and nodejs version 24.9.0. Completed on 2025-10-03~~
- ~~Upgrade bun.js version to 1.3.1 and nodejs version 24.11.0. Completed on 2025-11-05~~
- Upgrade bun.js version to 1.3.14 and nodejs version 24.18.0. Completed on 2026-07-03
- Add `lsiown` script instead downloand from linuxserver.io due to github not found issue. Completed on 2026-07-09
- Upgrade nodejs version to 24.22.1 and bun.js version to 1.4.3. Completed on 2026-10-22
- Upgrade base image from Alpine 3.22 to Alpine 3.24. Completed on 2026-10-22

### Changed

### Deprecated

### Removed

### Fixed

- Fix Node.js install layer failing with `gpg: not found` — `gnupg` added to `.build-deps` and Node.js release keys imported before decrypting `SHASUMS256.txt.asc`. Completed on 2026-10-22

### Security

- Address CVE-2026-111497 (HIGH): out-of-bounds write in the Node.js Brotli decoder permitting remote code execution, affecting Node.js 22.x, 24.x and 26.x. Fixed by upgrading to Node.js 24.22.1, the patched release line ([Node.js October 2026 security releases](https://nodejs.org/en/blog/vulnerability/october-2026-security-releases)). Completed on 2026-10-22

[1.0.2]: https://github.com/wkloh76/docker-nodebunpy/releases/tag/1.0.2

## [1.0.1] - 2025-08-19

### Summary

- Design docker images which will able deploy the project in `NodeJS` , `BunJS` or `Python3` design.

### Added

- Upgrade bun.js version to 1.2.20 and nodejs version 20.19.4. Completed on 2025-08-19
- Implement `uv` intead python-pip3 to manage python packages include install,add and remove. Completed on 2025-08-19
- Upgrade bun.js version to 1.2.21 and nodejs version 20.19.5. Completed on 2025-09-09

### Changed

### Deprecated

### Removed

### Fixed

- Fix the environment variable `PYVENV` no declare will not activate the process. Completed on 2025-08-20

### Security

[1.0.1]: https://github.com/wkloh76/docker-nodebunpy/releases/tag/1.0.1

## [1.0.0] - 2025-04-11

### Summary

- Design docker images which will able deploy the project in `NodeJS` , `BunJS` or `Python3` design.

### Added

- Add `MAIN_APP` docker environment variable which will design the interpreter engine run script base on setting. Completed on 2025-04-14

### Changed

- Update container service `nodebun-deploy` to `nodebun_deploy` at docker-compose.yml file. Completed on 2025-04-11

### Deprecated

### Removed

### Fixed

- Remove `strict` from `install_modules.js`.Completed on 2025-04-11

### Security

[1.0.0]: https://github.com/wkloh76/docker-nodebunpy/releases/tag/1.0.0
