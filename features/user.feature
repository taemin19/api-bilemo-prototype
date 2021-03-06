Feature: User
  In order to use the API
  As an API client
  I need to be able to retrieve one user / a collection of users
  I need to be able to create / delete an user

  @loginAsClient1
  Scenario: Retrieve one user
    Given the following users exist for client1:
      | firstname | lastname | email        |
      | john      | doe      | john@doe.com |
    When I send a "GET" request to "/users/1"
    Then the response status code should be 200
    And the header "Content-Type" should be equal to "application/hal+json"
    And the response should be in JSON
    And the JSON node "id" should contain "1"
    And the JSON node "firstname" should contain "john"
    And the JSON node "lastname" should contain "doe"
    And the JSON node "email" should contain "john@doe.com"
    And the JSON node "_links.self.href" should contain "/users/1"
    And the JSON node "_links.delete.href" should contain "/users/1"

  @loginAsClient1
  Scenario: Retrieve a collection of users
    Given the following users exist for client1:
      | firstname | lastname | email        |
      | john      | doe      | john@doe.com |
      | jane      | doe      | jane@doe.com |
    When I send a "GET" request to "/users"
    Then the response status code should be 200
    And the header "Content-Type" should be equal to "application/hal+json"
    And the response should be in JSON
    And the JSON node " " should have 2 elements
    And the JSON node "[0].id" should contain "1"
    And the JSON node "[0].firstname" should contain "john"
    And the JSON node "[0].lastname" should contain "doe"
    And the JSON node "[0].email" should contain "john@doe.com"
    And the JSON node "[0]._links.self.href" should contain "/users/1"
    And the JSON node "[0]._links.delete.href" should contain "/users/1"
    And the JSON node "[1].id" should contain "2"
    And the JSON node "[1].firstname" should contain "jane"
    And the JSON node "[1].lastname" should contain "doe"
    And the JSON node "[1].email" should contain "jane@doe.com"
    And the JSON node "[1]._links.self.href" should contain "/users/2"
    And the JSON node "[1]._links.delete.href" should contain "/users/2"

  @loginAsClient1
  Scenario: Create an user
    When I send a "POST" request to "/users" with body:
    """
    {
      "firstname": "john",
      "lastname": "doe",
      "email": "john@doe.com"
    }
    """
    Then the response status code should be 201
    And the header "Content-Type" should be equal to "application/hal+json"
    And the header "Location" should be equal to "http://127.0.0.1:8000/users/1"
    And the response should be in JSON
    And the JSON node "id" should contain "1"
    And the JSON node "firstname" should contain "john"
    And the JSON node "lastname" should contain "doe"
    And the JSON node "email" should contain "john@doe.com"
    And the JSON node "_links.self.href" should contain "/users/1"
    And the JSON node "_links.delete.href" should contain "/users/1"

  @loginAsClient1
  Scenario: Delete an user
    Given the following users exist for client1:
      | firstname | lastname | email        |
      | john      | doe      | john@doe.com |
    When I send a "DELETE" request to "/users/1"
    Then the response status code should be 204
    And the response should be empty

  @loginAsClient1
  Scenario: Proper 404 exception if an users list is empty
    When I send a "GET" request to "/users"
    Then the response status code should be 404
    And the header "Content-Type" should be equal to "application/problem+json"
    And the response should be in JSON
    And the JSON node "status" should contain "404"
    And the JSON node "type" should contain "about:blank"
    And the JSON node "title" should contain "Not Found"
    And the JSON node "detail" should contain 'No users created.'

  @loginAsClient1
  Scenario Outline: Proper 404 exception if an user is not found
    When I send a "<method>" request to "<url>"
    Then the response status code should be 404
    And the header "Content-Type" should be equal to "application/problem+json"
    And the response should be in JSON
    And the JSON node "status" should contain "404"
    And the JSON node "type" should contain "about:blank"
    And the JSON node "title" should contain "Not Found"
    And the JSON node "detail" should contain 'No user found with id "0"'

    Examples:
      | url      | method |
      | /users/0 | GET    |
      | /users/0 | DELETE |

  @loginAsClient1
  Scenario: Proper 400 exception if validation failed on user creation
    When I send a "POST" request to "/users" with body:
    """
    {
      "firstname": "",
      "lastname": "",
      "email": "johndoe.com"
    }
    """
    Then the response status code should be 400
    And the header "Content-Type" should be equal to "application/problem+json"
    And the JSON node "status" should contain "400"
    And the JSON node "type" should contain "validation-error"
    And the JSON node "title" should contain "Validation error(s) found"
    And the JSON node "invalid-params" should exist
    And the JSON node "invalid-params[0].firstname" should contain "This value should not be blank."
    And the JSON node "invalid-params[1].lastname" should contain "This value should not be blank."
    And the JSON node "invalid-params[2].email" should contain "This value is not a valid email address."

  @loginAsClient1
  Scenario: Proper 400 exception if invalid body on user creation
    When I send a "POST" request to "/users" with body:
    """
    """
    Then the response status code should be 400
    And the header "Content-Type" should be equal to "application/problem+json"
    And the JSON node "status" should contain "400"
    And the JSON node "type" should contain "invalid-body-format"
    And the JSON node "title" should contain "Invalid JSON format sent"

  @loginAsClient1
  Scenario: Proper 403 exception if client1 try accessing to an user of client2
    Given the following users exist for client2:
      | firstname | lastname | email        |
      | john      | doe      | john@doe.com |
    When I send a "GET" request to "/users/1"
    Then the response status code should be 403
    And the header "Content-Type" should be equal to "application/problem+json"
    And the JSON node "status" should contain "403"
    And the JSON node "type" should contain "about:blank"
    And the JSON node "title" should contain "Forbidden"
    And the JSON node "detail" should contain "Access Denied."
