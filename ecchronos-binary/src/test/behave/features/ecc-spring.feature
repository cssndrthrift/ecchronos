Feature: ecc-spring

  Scenario: RestServer health check returns UP
    Given I use the url localhost:8080/actuator/health
    When I send a GET request
    Then the response is successful
    And the status is UP

  Scenario: RestServer returns metrics
    Given I use the url localhost:8080/metrics
    When I send a GET request
    Then the response is successful