Feature: Retry scenarios
  In order to fail less often with flaky scenarios
  As a CI administrator and tester
  I want to have all scenarios retried

  Background:
    Given a file "features/support/steps/test_steps.rb" with the following content exists
      """
      $try = 0

      module TestSteps
        step("I fail the first time") do
          fail 'first time' if ($try += 1) < 2
        end

        step("I fail always") do
          fail 'always'
        end

        step("I do not fail") do
          # noop
        end
      end

      Gurke.configure do |c|
        c.include TestSteps
        c.default_retries = 1
      end
      """

  Scenario: Retry a failed scenario
    Given a file "features/test.feature" with the following content exists
      """
      Feature: F
        Scenario: Scenario Failure
          Given I fail the first time
      """
    When I run the tests
    Then the program exit code should be null
    And the program output should include "Given I fail the first time (failure)"
    And the program output should include "Given I fail the first time (passed)"
    And the program output should include "Retry scenario due to previous failure:"
    And the program output should include "1 scenarios: 0 failing, 0 pending"

  Scenario: Run an always failing scenario
    Given a file "features/test.feature" with the following content exists
      """
      Feature: F
        Scenario: Scenario Failure
          Given I fail always
      """
    When I run the tests
    Then the program exit code should be non-null
    And the program output should include "Given I fail always (failure)"
    And the program output should include "Retry scenario due to previous failure:"
    And the program output should not include "Given I fail always (passed)"
    And the program output should include "1 scenarios: 1 failing, 0 pending"

  Scenario: Run a passing scenario
    Given a file "features/test.feature" with the following content exists
      """
      Feature: F
        Scenario: Scenario Failure
          Given I do not fail
      """
    When I run the tests
    Then the program exit code should be null
    And the program output should include "Given I do not fail (passed)"
    And the program output should not include "Retry scenario due to previous failure:"
    And the program output should include "1 scenarios: 0 failing, 0 pending"
