Feature: Pending Steps

  Scenario: Use same step definition with different keyword
    Given a file "features/test.feature" with the following content exists
      """
      Feature: F
        Scenario: Scenario A
          Given I am "John"

      """
    When I run the tests
    Then the program exit code should be null
    And the program output should include "1 pending"
