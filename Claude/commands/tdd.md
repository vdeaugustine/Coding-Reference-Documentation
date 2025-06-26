We want to implement the following feature or task using Test Driven Development:
$ARGUMENTS

This is the flow you should follow to do that:

Write Tests First
Start by writing unit, integration, or end-to-end tests based on clearly defined input/output behavior. Do not generate any implementation code at this stage. This is a test-driven development (TDD) workflow.

Verify Tests Fail
Run the test suite and confirm that the new tests fail. This confirms the tests are valid and that the functionality does not yet exist.

Commit the Tests
Once the failing tests are confirmed and correct, commit them with a message indicating the feature or behavior being tested.

Implement to Pass the Tests
Write only the minimal code required to make the tests pass. Do not modify the tests during this phase.

Run Tests Again
Execute the full test suite after each implementation step to verify progress.

Iterate Until All Tests Pass
Continue making incremental changes and rerunning tests until all tests pass successfully.

Verify Generalization
Optionally, use separate sub-agents or secondary checks to ensure the implementation isn’t overfitting to the current test cases.

Commit the Working Code
Once all tests pass and the implementation is verified, commit the changes with a message summarizing the completed functionality.
