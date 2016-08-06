Feature: Include by tags
  As a developer
  In order to be flexible with my step names
  I want to include some steps only to scenarios with a specific tags

  Background:
    And a file "features/test_a.feature" with the following content exists
      """
      @step1a
      Feature: Feature 1

        @step2a
        Scenario: Scenario 1
          Given this is the feature step
          And this is the scenario step
      """
    And a file "features/test_b.feature" with the following content exists
      """
      @step1b
      Feature: Feature 2

        @step2b
        Scenario: Scenario 2
          Given this is the feature step
          And this is the scenario step
      """
    And a file "features/support/steps/test_steps_1a.rb" with the following content exists
      """
      module Test1ASteps
        Given("this is the feature step") { puts "DO STEP 1A" }
      end

      Gurke.config.include Test1ASteps, tags: :step1a
      """
    And a file "features/support/steps/test_steps_2a.rb" with the following content exists
      """
      module Test2ASteps
        Given("this is the scenario step") { puts "DO STEP 2A" }
      end

      Gurke.config.include Test2ASteps, tags: :step2a
      """
    And a file "features/support/steps/test_steps_1b.rb" with the following content exists
      """
      module Test1BSteps
        Given("this is the feature step") { puts "DO STEP 1B" }
      end

      Gurke.config.include Test1BSteps, tags: :step1b
      """
    And a file "features/support/steps/test_steps_2b.rb" with the following content exists
      """
      module Test2BSteps
        Given("this is the scenario step") { puts "DO STEP 2B" }
      end

      Gurke.config.include Test2BSteps, tags: [:step2b, :anotherTag]
      """

  Scenario: It should include the matching step definitions
    When I run the tests
    Then the program output should include "DO STEP 1A"
    Then the program output should include "DO STEP 2A"
    Then the program output should include "DO STEP 1B"
    Then the program output should include "DO STEP 2B"
