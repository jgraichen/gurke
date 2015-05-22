Feature: Run specific features or scenarios
  In order to get faster test results
  As a user
  I want run only a specific set of files or lines

  Background:
    Given I am in a project using gurke
    Given a file "features/a.feature" with the following content exists
      """
      Feature: F
        Bla blub, a longer description.
        Dadada.

        Scenario: Scenario A1
          Given I am "John"
          When I am "John"
          Then I am "John"

        Scenario: Scenario A2
          Given I am "John"
          When I am "John"
          Then I am "John"
      """
    Given a file "features/b.feature" with the following content exists
      """
      # Comment.
      Feature: F
        Bla blub, a longer description.

        Dadada.

        Scenario: Scenario B1
          Given I am "John"
          When I am "John"
          Then I am "John"

        Scenario: Scenario B2
          Given I am "John"
          When I am "John"
          Then I am "John"

        Scenario: Scenario B3
          Given I am "John"
          When I am "John"
          Then I am "John"
      """
    And a file "features/support/steps/test_steps.rb" with the following content exists
      """
      require 'test/unit/assertions'

      module Steps
        include Test::Unit::Assertions

        Given(/^I am "(.+)"$/) do |name|
          @me = name
        end

        When(/^I am "(.+)"$/) do |name|
          @copy = @me
        end

        Then(/^I am "(.+)"$/) do |name|
          assert name == @copy, "Expected #{name.inspect} but #{@me.inspect} given."
        end
      end
      Gurke.world.send :include, Steps
      """

  Scenario: Run specific file (I)
    When I execute "bundle exec gurke features/a.feature"
    And the program output should include "2 scenarios: 0 failing, 0 pending"

  Scenario: Run specific file (II)
    When I execute "bundle exec gurke features/b.feature"
    And the program output should include "3 scenarios: 0 failing, 0 pending"

  Scenario: Run specific line of a scenario (I)
    When I execute "bundle exec gurke features/b.feature:7"
    And the program output should include "Scenario: Scenario B1"
    And the program output should include "1 scenarios: 0 failing, 0 pending"

  Scenario: Run specific line of a scenario (II)
    When I execute "bundle exec gurke features/b.feature:7:19"
    And the program output should include "Scenario: Scenario B1"
    And the program output should include "Scenario: Scenario B3"
    And the program output should include "2 scenarios: 0 failing, 0 pending"

  Scenario: Run specific line of a scenario (III)
    When I execute "bundle exec gurke features/a.feature:11 features/b.feature:7:19"
    And the program output should include "Scenario: Scenario A2"
    And the program output should include "Scenario: Scenario B1"
    And the program output should include "Scenario: Scenario B3"
    And the program output should include "3 scenarios: 0 failing, 0 pending"
