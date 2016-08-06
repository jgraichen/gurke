Feature: Use gurke
  As a developer
  In order to run my feature definitions
  I want to use the gurke command line program

  Scenario: Run a passing feature file
    Given a file "features/test.feature" with the following content exists
      """
      Feature: F
        Scenario: Scenario A
          Given everything is ok
      """
    And a file "features/support/steps/test_steps.rb" with the following content exists
      """
      module TestSteps
        step("everything is ok") { }
      end
      Gurke.configure{|c| c.include TestSteps }
      """
    When I run the tests
    Then the program exit code should be null
    And the program output should include "Feature: F"
    And the program output should include "Scenario: Scenario A"
    And the program output should include "Given everything is ok"
    And the program output should include "1 scenarios: 0 failing, 0 pending"

  Scenario: Run a failing feature file
    Given a file "features/test.feature" with the following content exists
      """
      Feature: F
        Scenario: Scenario A
          Given nothing is ok

      """
    And a file "features/support/steps/test_steps.rb" with the following content exists
      """
      module TestSteps
        step("nothing is ok") { raise RuntimeError }
      end
      Gurke.configure{|c| c.include TestSteps }
      """
    When I run the tests
    And the program output should include "1 scenarios: 1 failing, 0 pending"
    Then the program exit code should be non-null
