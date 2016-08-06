Feature: Access context in hooks
  In order to setup specific things
  As a developer
  I want to access meta data of the context in hooks

  Background:
    And a file "features/test.feature" with the following content exists
      """
      Feature: A
        @tag
        Scenario: A
          Then the scenario has tag "tag"

      """
    And a file "features/support/steps/test_steps.rb" with the following content exists
      """
      require 'test/unit/assertions'

      module TestSteps
        include Test::Unit::Assertions

        Then("the scenario has tag \"tag\"") do
          assert @before_tags.include? "tag"
          assert @around_tags.include? "tag"
        end
      end

      Gurke.configure do |c|
        c.include TestSteps

        c.before(:each) { |s| @before_tags = s.tags }
        c.around(:each) { |s| @around_tags = s.tags; s.call }
      end
      """

  Scenario: Assertions should pass
    When I run the tests
    Then all scenarios have passed
