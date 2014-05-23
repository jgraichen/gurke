Feature: Backtrace filtering
  As a developer
  In order to faster find the backtrace lines
  I want to see modified backtraces with only non-library calls

  Background:
    Given I am in a project using gurke
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

  Scenario: See backtrace no library backtrace line
    When I execute "bundle exec gurke"
    Then the program output should include "features/support/steps/test_steps.rb:2"
    Then the program output should not include "gurke/lib/gurke/runner.rb"
