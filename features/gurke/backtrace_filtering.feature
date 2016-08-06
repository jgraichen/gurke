Feature: Backtrace filtering
  As a developer
  In order to faster find the backtrace lines
  I want to see modified backtraces with only non-library calls

  Background:
    And a file "features/test.feature" with the following content exists
      """
      Feature: F
        Scenario: Scenario A
          Given there is an error

      """
    And a file "features/support/steps/test_steps.rb" with the following content exists
      """
      module TestSteps
        step("there is an error") { raise RuntimeError }
      end
      Gurke.configure{|c| c.include TestSteps }
      """

  Scenario: See backtrace without line from libraries
    When I run the tests
    Then the program output should include "features/support/steps/test_steps.rb:2"
    Then the program output should not include "gurke/lib/gurke/runner.rb"

  Scenario: See backtrace when run with --backtrace
    When I run the tests with "--backtrace"
    Then the program output should include "features/support/steps/test_steps.rb:2"
    Then the program output should include "gurke/lib/gurke/runner.rb"

  Scenario: See backtrace when run with -b
    When I run the tests with "-b"
    Then the program output should include "features/support/steps/test_steps.rb:2"
    Then the program output should include "gurke/lib/gurke/runner.rb"
