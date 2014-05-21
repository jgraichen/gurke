Feature: Backtrace filtering
  As a developer
  In order to faster find the backtrace lines
  I want to see modified backtraces with DSL calls included

  Background:
    Given a file "features/test.features" with the following content exists
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

  Scenario: See backtrace from feature file
    When I execute "bundle exec gurke"
    Then the program output should include "features/test.features:3:in `Given there is an error'"

  Scenario: See backtrace from step definition
    When I execute "bundle exec gurke"
    Then the program output should include "features/support/steps/test_steps.rb:2:in `there is an error'"
