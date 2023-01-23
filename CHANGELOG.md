# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).


## [Unreleased]
### Added
- Pre-installation of platforms declared in `default.yml`

### Changed

### Deprecated

### Removed

### Fixed

### Security


## [0.1.3] - 2013-01-13
### Changed
- Now uses `arduino_ci` [version `1.3.0`](https://github.com/Arduino-CI/arduino_ci/blob/master/CHANGELOG.md#130---2021-01-13)

### Removed
- The use of `SKIP_LIBRARY_PROPERTIES`


## [0.1.2] - 2021-01-06
### Added
- Publish docker image to GitHub packages on `latest` branch and after tagging
- Instructions for testing locally with Docker
- Adopt new `arduino_ci` version that enables `CUSTOM_INIT_SCRIPT` and `USE_SUBDIR` environment variables
- Python dependencies for espXX board compilation (unfortunately assumed to be present in image, not installed by board manager)
- Instructions for new environment variable `SKIP_LIBRARY_PROPERTIES`


## [0.1.1] - 2020-12-02
### Added
* Instructions for the new environment variables `EXPECT_EXAMPLES` and `EXPECT_UNITTESTS`
* Documentation now links to unit testing information and `.arduino-ci.yaml`

### Changed
* Use non-interactive frontend for `apt-get install`
* Arduino libraries directory is now pre-existing in the image
* Clarified instructions about badges


## [0.1.0] - 2020-11-29
### Added
- Initial implementation of action


[Unreleased]: https://github.com/Arduino-CI/action/compare/v0.1.3...HEAD
[0.1.3]: https://github.com/Arduino-CI/arduino_ci/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/Arduino-CI/arduino_ci/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/Arduino-CI/arduino_ci/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/Arduino-CI/arduino_ci/compare/v0.0.0...v0.1.0
