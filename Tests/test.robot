*** Settings ***
Resource    ../Resource/App.resource
Resource    ../Resource/Customers.resource

Suite Setup    Suite Init
Suite Teardown    Capture Page Screenshot

*** Test Cases ***
TEST-1
    [Documentation]    Add First 5 Users
    Add User    5

TEST-2
    [Documentation]    Update Existing Customers
    Update Customer    5

TEST-3
    [Documentation]    Log Table Data
    Log Customer Data

TEST-4
    [Documentation]    Analyze User Spending
    Analyze Spending Of Customers

*** Keywords ***
Suite Init
    Launch Browser
    Login User
    ${users}    Get Users
    Set Suite Variable    ${USERS}    ${users}
