# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.4.0] - 2024-08-28

### Added

- Support expectations in step hooks

## [3.3.5] - 2023-10-28

### Changed

- Test with Ruby 2.7, 3.0, 3.1, and 3.2
- Upgrade to Ruby 2.7+
- Fix required `StringIO` usage
- Fix `send :include`

## [3.3.4] - 2018-10-26

### Changed

- Replace renamed trollop dependency with optimist

## [3.3.3] - 2018-07-27

### Changed

- Fix a TC reporter issues reporting all scenarios as aborted

## [3.3.2] - 2018-07-27

### Changed

- Fix TeamCity and compact reporter

## [3.3.1] - 2018-07-26

### Changed

- Add option for default retry of failed scenarios
- Make number of default and flaky retries configurable

## [3.2.2] - 2018-04-11

### Changed

- Fix some default reporter formatting issues

## [3.2.1] - 2018-04-11

### Changed

- Reset world between retried scenario runs

## [3.2.0] - 2018-04-11

### Changed

- Add `@flaky` tag support for retrying flaky scenarios once

## [3.1.0] - 2018-02-26

### Changed

- Update TeamCity formatter to extend default formatter

## [3.0.0] - 2018-02-26

### Changed

- Drop support for MRI < 2.3

## [2.4.2] - 2016-05-10

## [2.4.1] - 2016-02-10

## [2.4.0] - 2015-05-28

## [2.3.0] - 2014-02-26

### Changed

- Step inclusion can be scoped to specific tags (45cea9ab)

## [2.2.2] - 2014-07-02

### Changed

- `TeamCityReporter`: Fixing mark test as pending

## [2.2.1] - 2014-06-27

### Changed

- Bug fix (missing argument in `cli.rb`)
- Bug fix in after_feature hook call (missing feature argument)

## [2.2.0] - 2014-06-27

### Changed

- Support executing all features inside one directory
- Support reporter selection via CLI
- Add `TeamCityReporter` (`gurke --formatter team_city`)
- Support string as step definitions correctly
- Smaller bug fix in improved exception formatting

## [2.1.0] - 2014-06-27

### Changed

- Improve exception formatting

## [2.0.3] - 2014-06-24

## [2.0.2] - 2014-06-24

## [2.0.1] - 2014-06-18

## [2.0.0] - 2014-06-06

## [1.0.1] - 2014-01-22

## [1.0.0] - 2013-12-04

[Unreleased]: https://github.com/jgraichen/gurke/compare/v3.4.0...HEAD
[3.4.0]: https://github.com/jgraichen/gurke/compare/v3.3.5...v3.4.0
[3.3.5]: https://github.com/jgraichen/gurke/compare/v3.3.4...v3.3.5
[3.3.4]: https://github.com/jgraichen/gurke/compare/v3.3.3...v3.3.4
[3.3.3]: https://github.com/jgraichen/gurke/compare/v3.3.2...v3.3.3
[3.3.2]: https://github.com/jgraichen/gurke/compare/v3.3.1...v3.3.2
[3.3.1]: https://github.com/jgraichen/gurke/compare/v3.2.2...v3.3.1
[3.2.2]: https://github.com/jgraichen/gurke/compare/v3.2.1...v3.2.2
[3.2.1]: https://github.com/jgraichen/gurke/compare/v3.2.0...v3.2.1
[3.2.0]: https://github.com/jgraichen/gurke/compare/v3.1.0...v3.2.0
[3.1.0]: https://github.com/jgraichen/gurke/compare/v3.0.0...v3.1.0
[3.0.0]: https://github.com/jgraichen/gurke/compare/v2.4.2...v3.0.0
[2.4.2]: https://github.com/jgraichen/gurke/compare/v2.4.1...v2.4.2
[2.4.1]: https://github.com/jgraichen/gurke/compare/v2.4.0...v2.4.1
[2.4.0]: https://github.com/jgraichen/gurke/compare/v2.3.0...v2.4.0
[2.3.0]: https://github.com/jgraichen/gurke/compare/v2.2.2...v2.3.0
[2.2.2]: https://github.com/jgraichen/gurke/compare/v2.2.1...v2.2.2
[2.2.1]: https://github.com/jgraichen/gurke/compare/v2.2.0...v2.2.1
[2.2.0]: https://github.com/jgraichen/gurke/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/jgraichen/gurke/compare/v2.0.3...v2.1.0
[2.0.3]: https://github.com/jgraichen/gurke/compare/v2.0.2...v2.0.3
[2.0.2]: https://github.com/jgraichen/gurke/compare/v2.0.1...v2.0.2
[2.0.1]: https://github.com/jgraichen/gurke/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/jgraichen/gurke/compare/v1.0.1...v2.0.0
[1.0.1]: https://github.com/jgraichen/gurke/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/jgraichen/gurke/tree/v1.0.0
