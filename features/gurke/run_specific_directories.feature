Feature: Run specific features or scenarios
  In order to get faster test results
  As a user
  I want run only feature files from one directory

  Background:
    Given I am in a project using gurke
    Given a file "features/odd/a.feature" with the following content exists
      """
      Feature: F
        Bla blub, a longer description.

        Scenario: Scenario A
          Given I am successful
      """
    Given a file "features/odd/c.feature" with the following content exists
      """
      Feature: F
        Bla blub, a longer description.

        Scenario: Scenario C
          Given I am successful
      """
    Given a file "features/even/b.feature" with the following content exists
      """
      Feature: F
        Bla blub, a longer description.

        Scenario: Scenario B
          Given I am successful
      """
    Given a file "trash/b.f" with the following content exists
      """
      Feature: F
        Bla blub, a longer description.

        Scenario: Scenario B
          Given I am successful
      """
    And a file "features/support/steps/test_steps.rb" with the following content exists
      """
      module TestSteps
        Given("I am successful") { true }
      end
      Gurke.configure{|c| c.include TestSteps }
      """

  Scenario: Run all features from on directory
    When I execute "bundle exec gurke features/odd"
    And the program output should include "2 scenarios: 0 failing, 0 pending"

  Scenario: Run all features from on directory (II)
    When I execute "bundle exec gurke features/even"
    And the program output should include "1 scenarios: 0 failing, 0 pending"

  Scenario: Run all features from on directory (with subdirectories)
    When I execute "bundle exec gurke features"
    And the program output should include "3 scenarios: 0 failing, 0 pending"

  Scenario: Run all features from on directory (based on feature pattern)
    When I execute "bundle exec gurke trash"
    And the program output should include "0 scenarios: 0 failing, 0 pending"
