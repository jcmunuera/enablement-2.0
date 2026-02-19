# File: customer-core/customer.feature
# Source: aggregate-definitions.yaml (context: customer-core, aggregate: customer)
# Tracing: scenario-tracing.yaml

Feature: Customer Management
  As the Customer Core domain
  I want to manage customer lifecycle and personal data
  So that customer data is accurate, consistent, and compliant

  # ============================================================
  # HAPPY PATH — Commands
  # ============================================================

  Scenario: Register a new customer with valid data
    Given no customer exists with email "john.doe@example.com"
    When a CreateCustomer command is submitted with:
      | field       | value                  |
      | firstName   | John                   |
      | lastName    | Doe                    |
      | email       | john.doe@example.com   |
      | dateOfBirth | 1990-05-15             |
    Then a new customer is created with status ACTIVE
    And a CustomerCreated event is published

  Scenario: Update customer personal data
    Given a customer exists with id "cust-001"
    When an UpdateCustomer command is submitted with:
      | field     | value           |
      | firstName | Jonathan        |
      | address   | 123 Main St, Springfield |
    Then the customer data is updated
    And a CustomerUpdated event is published

  Scenario: Change customer status to DORMANT
    Given a customer exists with id "cust-001" and status ACTIVE
    When a ChangeCustomerStatus command is submitted with:
      | field     | value                    |
      | newStatus | DORMANT                  |
      | reason    | No activity for 12 months |
    Then the customer status changes to DORMANT
    And a CustomerStatusChanged event is published

  # ============================================================
  # HAPPY PATH — Queries
  # ============================================================

  Scenario: Retrieve an existing customer by ID
    Given a customer exists with id "cust-001"
    When a GetCustomer query is submitted for id "cust-001"
    Then the customer details are returned

  Scenario: List customers with pagination
    Given 25 customers exist in the system
    When a ListCustomers query is submitted with page 1 and size 10
    Then 10 customers are returned
    And pagination metadata indicates 3 total pages

  Scenario: Search customer by email
    Given a customer exists with email "john.doe@example.com"
    When a SearchCustomerByEmail query is submitted for "john.doe@example.com"
    Then the matching customer is returned

  # ============================================================
  # VALIDATION ERRORS
  # ============================================================

  Scenario: Reject customer creation with missing required fields
    When a CreateCustomer command is submitted without email
    Then the command is rejected with error INVALID_INPUT
    And the error indicates "email is required"

  Scenario: Reject customer update for non-existent customer
    Given no customer exists with id "nonexistent"
    When an UpdateCustomer command is submitted for id "nonexistent"
    Then the command is rejected with error CUSTOMER_NOT_FOUND

  # ============================================================
  # BUSINESS RULE VIOLATIONS (Invariants)
  # ============================================================

  Scenario: Reject duplicate customer email
    Given a customer already exists with email "john.doe@example.com"
    When a CreateCustomer command is submitted with email "john.doe@example.com"
    Then the command is rejected with error DUPLICATE_EMAIL
    And the error indicates "a customer with this email already exists"

  Scenario: Reject invalid status transition
    Given a customer exists with id "cust-001" and status CLOSED
    When a ChangeCustomerStatus command is submitted with newStatus ACTIVE
    Then the command is rejected with error INVALID_TRANSITION
    And the error indicates "invalid status transition from CLOSED to ACTIVE"

  Scenario: Reject activation without verified KYC
    Given a customer exists with id "cust-001" and kycStatus PENDING
    When a ChangeCustomerStatus command is submitted with newStatus ACTIVE
    Then the command is rejected with error KYC_NOT_VERIFIED
    And the error indicates "customer cannot be activated without verified KYC"

  Scenario: Reject underage customer registration
    Given today's date is "2026-02-16"
    When a CreateCustomer command is submitted with dateOfBirth "2010-06-01"
    Then the command is rejected with error UNDERAGE
    And the error indicates "customer must be at least 18 years old"

  # ============================================================
  # NOT FOUND
  # ============================================================

  Scenario: Return error when customer does not exist
    Given no customer exists with id "nonexistent"
    When a GetCustomer query is submitted for id "nonexistent"
    Then a CUSTOMER_NOT_FOUND error is returned

  # ============================================================
  # INTEGRATION (System API)
  # ============================================================

  Scenario: Customer data persisted via Parties system API
    Given the Parties system API is available
    When a CreateCustomer command is processed successfully
    Then customer data is transformed to the Parties format
    And persisted via the Parties system API

  Scenario: Customer data retrieved from Parties system API
    Given the Parties system API is available
    When a GetCustomer query is processed
    Then data is retrieved from the Parties system API
    And transformed from Parties format to domain model
