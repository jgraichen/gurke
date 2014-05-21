Feature: Use gurke
  As a developer
  In order to run my feature definitions
  I want to use the gurke command line program

  Scenario: Run a passing feature file
    Given a file "features/test.features" with the following content exists
      """
      Feature: F
        Scenario: Scenario A
          Given everything is ok

      """
    And a file "features/support/steps/test_steps.rb" with the following content exists
      """
      module TestSteps
        step("everything is ok") { }
      end
      Gurke.configure{|c| c.include TestSteps }
      """
    When I execute "bundle exec gurke"
    Then the program exit code should be "0"

  Scenario: Run a failing feature file
    Given a file "features/test.features" with the following content exists
      """
      Feature: F
        Scenario: Scenario A
          Given nothing is ok

      """
    And a file "features/support/steps/test_steps.rb" with the following content exists
      """
      module TestSteps
        step("nothing is ok") { raise RuntimeError }
      end
      Gurke.configure{|c| c.include TestSteps }
      """
    When I execute "bundle exec gurke"
    Then the program exit code should be "1"
