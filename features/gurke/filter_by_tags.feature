Feature: Backtrace filtering
  In order to not always run every fukcin long scenario
  As a tester
  I want to filter features and scenarios by tags to only run a subset

  Background:
    Given I am in a project using gurke
    And a file "features/support/steps/test_steps.rb" with the following content exists
      """
      module TestSteps
        step("everything's ok") { true && true }
      end
      Gurke.configure{|c| c.include TestSteps }
      """
    And a file "features/feature_flag_a.feature" with the following content exists
      """
      @a @c @d
      Feature: Feature Flagged little-A
        Scenario: Best Scenario evvvarrr
          Then everything's ok
      """
    And a file "features/feature_flag_b.feature" with the following content exists
      """
      @b @c @d
      Feature: Feature Flagged little-B
        Scenario: Best Scenario evvvarr, the second
          Then everything's ok
      """
    And a file "features/feature_flag_wip.feature" with the following content exists
      """
      @wip
      Feature: Feature Flagged little-WIP
        Scenario: Best Scenario evvarr, the second
          Then everything's ok
      """

  Scenario: Do not run @wip by default
    When I execute "bundle exec gurke"
    Then the program output should include "Feature Flagged little-A"
    And the program output should include "Feature Flagged little-B"
    And the program output should not include "Feature Flagged little-WIP"
    And the program output should include "2 scenarios"

  Scenario: Filter with positive tag match
    When I execute "bundle exec gurke --tags a"
    Then the program output should include "Feature Flagged little-A"
    And the program output should not include "Feature Flagged little-B"
    And the program output should not include "Feature Flagged little-WIP"
    And the program output should include "1 scenarios"

  Scenario: Filter with negative tag match
    When I execute "bundle exec gurke -t ~b"
    Then the program output should include "Feature Flagged little-A"
    And the program output should not include "Feature Flagged little-B"
    And the program output should include "Feature Flagged little-WIP"
    And the program output should include "2 scenarios"

  Scenario: Filter with multiple tag match and'ed
    When I execute "bundle exec gurke --tags c,d"
    Then the program output should include "Feature Flagged little-A"
    And the program output should include "Feature Flagged little-B"
    And the program output should not include "Feature Flagged little-WIP"
    And the program output should include "2 scenarios"

  Scenario: Filter with multiple tag match or'ed
    When I execute "bundle exec gurke --tags b --tags wip"
    Then the program output should not include "Feature Flagged little-A"
    And the program output should include "Feature Flagged little-B"
    And the program output should include "Feature Flagged little-WIP"
    And the program output should include "2 scenarios"
