@wip
Feature: Step keyword specific definitions
  In order to allow documentary style scenarios
  As a user
  I want to define same steps with different step keywords

  Background:
    Given I am in a project using gurke

  Scenario: Use same step definition with different keyword
    And a file "features/test.feature" with the following content exists
      """
      Feature: F
        Scenario: Scenario A
          Given I am "John"
          Then I am "John"

      """
    And a file "features/support/steps/test_steps.rb" with the following content exists
      """
      module Steps
        Given(/^I am "(.+)"$/) do |name|
          @me = name
        end

        Then(/^I am "(.+)"$/) do |name|
          expect(@me).to eq name
        end
      end
      Gurke.world.include Steps
      """
    When I execute all scenarios
    Then all scenarios have passed
