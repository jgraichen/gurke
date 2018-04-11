# Changelog

## 3.2.1

* Reset world between retried scenario runs

## 3.2.0

* Add @flaky tag support for retrying flaky scenarios once

## 3.1.0

* Update TeamCity formatter to extend default formatter

## 3.0.0

* Drop support for MRI < 2.3

## 2.3.0

* Step inclusion can be scoped to specific tags (45cea9ab)

## 2.2.2

* TeamCityReporter: Fixing mark test as pending

## 2.2.1

* BugFix (missing argument in cli.rb)
* BugFix in after_feature hook call (missing feature argument)

## 2.2.0

+ Support executing all features inside one directory
+ Support reporter selection via cli
+ Add TeamCityReporter (`gurke --formatter team_city`)
* Support string as step definitions correctly
* Smaller bugfix in improved exception formatting


## 2.1.0

* Improve exception formating

## 2.0.0

* Project start
