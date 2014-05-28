Feature: Step keyword specific definitions
  In order to allow documentary style scenarios
  As a user
  I want to define same steps with different step keywords

  Background:
    Given I am in a project using gurke

  Scenario: Use same step definition with different keyword
    Given a file "features/test.feature" with the following content exists
      """
      Feature: F
        Scenario: Scenario A
          Given I am "John"
          When I am "John"
          Then I am "John"

      """
    And a file "features/support/steps/test_steps.rb" with the following content exists
      """
      require 'test/unit/assertions'

      module Steps
        include MiniTest::Assertions

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
    When I execute all scenarios
    Then all scenarios have passed
