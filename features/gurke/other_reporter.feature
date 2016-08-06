Feature: Other Reporter
  As a developer
  In order to adjust the output to my requirements (e.g. inside a CI)
  I want to pass a command line argument to change the reporter

  Background:
    And a file "features/test.feature" with the following content exists
      """
      Feature: F
        Scenario: Scenario A
          Given this is a success

      """
    And a file "features/support/steps/test_steps.rb" with the following content exists
      """
      module TestSteps
        step("This is a success") { }
      end
      Gurke.configure{|c| c.include TestSteps }
      """

  Scenario: Use the default reporter without addition arguments
    When I run the tests
    Then the program output should not include "##teamcity"

  Scenario: Use specified reporter when run with --formatter
    When I run the tests with "--formatter team_city"
    Then the program output should include "##teamcity[testStarted name='Scenario A']"
    Then the program output should include "##teamcity[testFinished name='Scenario A']"

  Scenario: Use specified reporter when run with -f
    When I run the tests with "-f team_city"
    Then the program output should include "##teamcity[testStarted name='Scenario A']"
    Then the program output should include "##teamcity[testFinished name='Scenario A']"
