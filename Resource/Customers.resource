*** Settings ***
Library    SeleniumLibrary
Library    DateTime
Library    Collections
Variables    ../Variables/customers.py
Resource    App.resource

*** Keywords ***
Open Create Modal
    Click Element    //a[text()="Create"]
    Wait Until Element Is Visible    //h6[descendant::span[text()="Create Customer"]]

Add User
    [Arguments]    ${count}
    FOR    ${i}    IN RANGE    0    ${count}
        Add A Customer    ${USERS[${i-1}]}
        Verify If Customer Is Added In The Table    ${USERS[${i-1}]}
        Verify Customer Identity Details    ${USERS[${i-1}]}
    END

Add A Customer
    [Arguments]    ${user}
    Navigate    Customers
    Open Create Modal

    &{fields}=    Create Dictionary    ${customers_txt_first_name}=${user['first_name']}    ${customers_txt_last_name}=${user['last_name']}    ${customers_txt_email}=${user['email']}    ${customers_txt_birthday}=${user['birthday']}    ${customers_txt_address}=${user['address']['street']} ${user['address']['suite']}
    ...    ${customers_txt_city}=${user['address']['city']}    ${customers_txt_stateAbbr}=${user['address']['stateAbbr']}    ${customers_txt_zipcode}=${user['address']['zipcode']}    ${customers_txt_password}=${user['password']}    ${customers_txt_confirm_password}=${user['password']}
    
    FOR    ${locator}    ${value}    IN    &{fields}
        Wait Until Element Is Visible    ${locator}
        Input Text    ${locator}    ${value}
    END

    Click Element    ${customers_btn_save}
    Wait Until Element Is Visible    //div[text()="Customer created"]

Format Birthday
    [Arguments]    ${date}
    ${formatted}    Evaluate    "/".join("${date}".split("-")[1:]+["${date}".split("-")[0]])
    RETURN    ${formatted}

Verify Customer Identity Details
    [Arguments]    ${user}
    ${user_row}    Get Customer Row    ${user}
    Wait Until Element Is Visible    ((//tbody//tr)[${user_row}]//td)[2]
    Click Element    ((//tbody//tr)[${user_row}]//td)[2]
    Wait Until Element Is Visible    ${customers_txt_first_name}

    ${locators}    Create List    ${customers_txt_first_name}    ${customers_txt_last_name}    ${customers_txt_email}    ${customers_txt_birthday}    ${customers_txt_address}    ${customers_txt_city}    ${customers_txt_stateAbbr}    ${customers_txt_zipcode}    ${customers_txt_password}    ${customers_txt_confirm_password}
    ${expected_values}    Create List    ${user["first_name"]}    ${user["last_name"]}    ${user["email"]}    ${user['birthday']}    ${user["address"]["street"]} ${user["address"]["suite"]}    ${user["address"]["city"]}    ${user["address"]["stateAbbr"]}    ${user["address"]["zipcode"]}    ${user["password"]}    ${user["password"]}

    FOR    ${i}    ${locator}    IN ENUMERATE    @{locators}
        Mouse Over    ${locator}
        ${value_text}    Get Value    ${locator}
        IF    '${locator}'=='${customers_txt_birthday}'
            ${value_text}    Format Birthday    ${value_text}
        END
        
        Should Be Equal As Strings    ${expected_values[${i}]}    ${value_text}
    END

Get Customer Row
    [Arguments]    ${user}
    Navigate    Customers
    ${web_elems}    Get WebElements    //tbody//tr
    FOR    ${i}    ${elem}    IN ENUMERATE    @{web_elems}
        ${name}    Get Text    ((//tbody//tr)[${i+1}]//td)[2]
        ${name}    Clean Text    ${name}
        Return From Keyword If    "${user['first_name']} ${user['last_name']}"=="${name}"    ${i+1}
    END

    RETURN    None
    
Clean Text
    [Arguments]    ${text}
    IF    "\\n" in """${text}"""
        ${text}    Evaluate    """${text}""".replace("\\n","")[1:]
    ELSE IF    "$" or "," in """${text}"""
        ${text}    Evaluate    """${text}""".replace("$","").replace(",","")
    END
    Return From Keyword    ${text}
    

Verify If Customer Is Added In The Table
    [Arguments]    ${user}
    ${user_row}    Get Customer Row    ${user}
    Should Not Be Equal As Strings    None    ${user_row}

Update Customer
    [Arguments]    ${count}
    FOR    ${i}    IN RANGE    0    ${count}
        Update Customer Details    ${USERS[${i}+5]}    ${i+5}
        Verify If Customer Is Added In The Table    ${USERS[${i}+5]}
        Verify Customer Identity Details    ${USERS[${i}+5]}
    END

Update Customer Details
    [Arguments]    ${user}    ${index}
    Navigate    Customers
    Click Element    (//tbody//tr)[${index+1}]
    Wait Until Element Is Visible    ${customers_txt_first_name}

    &{field_map}=    Create Dictionary    ${customers_txt_first_name}=${user['first_name']}    ${customers_txt_last_name}=${user['last_name']}    ${customers_txt_email}=${user['email']}    ${customers_txt_birthday}=${user['birthday']}    ${customers_txt_address}=${user['address']['street']} ${user['address']['suite']}
    ...    ${customers_txt_city}=${user['address']['city']}    ${customers_txt_stateAbbr}=${user['address']['stateAbbr']}    ${customers_txt_zipcode}=${user['address']['zipcode']}    ${customers_txt_password}=${user['password']}    ${customers_txt_confirm_password}=${user['password']}
    
    FOR    ${index}    ${locator}    ${value}    IN ENUMERATE    &{field_map}
        IF    ${index}<3
            Press Keys    ${locator}    CTRL+a    BACKSPACE
        END
        Input Text    ${locator}    ${value}
    END
    
    Click Element    ${customers_btn_save}
    Wait Until Element Is Visible    //div[text()="Customer updated"]

Retrieve Customer Data
    Navigate    Customers
    ${web_elems}    Get WebElements    //tbody//tr
    ${users}    Create List
    FOR    ${i}    ${elem}    IN ENUMERATE    @{web_elems}
        ${name}    Get Text    ((//tbody//tr)[${i+1}]//td)[2]
        ${name}    Clean Text    ${name}
        ${last_seen}    Get Text    ((//tbody//tr)[${i+1}]//td)[3]
        ${orders}    Get Text    ((//tbody//tr)[${i+1}]//td)[4]
        ${total_spent}    Get Text    ((//tbody//tr)[${i+1}]//td)[5]
        ${latest_purchase}    Get Text    ((//tbody//tr)[${i+1}]//td)[6]
        ${news}    Get Element Attribute    ((//tbody//tr)[${i+1}]//td)[7]//*[name()='svg']    aria-label
        ${segments}    Get WebElements    ((//tbody//tr)[${i+1}]//td)[8]//span
        ${segment_list}    Create List
        
        FOR    ${segment}    IN    @{segments}
            ${single_segment}    Get Text    ${segment}
            Append To List    ${segment_list}    ${single_segment}
        END
        
        &{user}    Create Dictionary    name=${name}   last_seen=${last_seen}    orders=${orders}    total_spent=${total_spent}    latest_purchase=${latest_purchase}    news=${news}    segments=${segment_list}
        Append To List    ${users}    ${user}
    END
    RETURN    ${users}

Log Customer Data
    ${users}    Retrieve Customer Data
    Log To Console    ${EMPTY}
    FOR    ${i}    ${user}    IN ENUMERATE   @{users}
        Log To Console    ====== USER ${i+1} ======
        Log To Console    Last seen: ${user['last_seen']}
        Log To Console    Orders: ${user['orders']}
        Log To Console    Total Spent: ${user['total_spent']}
        IF    $user['latest_purchase']
            Log To Console    Latest purchase: ${user['latest_purchase']}
        END
        Log To Console    News.: ${user['news']}
        ${segment_length}    Get Length    ${user['segments']}
        IF    ${segment_length}>0
            FOR    ${single_seg}    IN    @{user['segments']}
                ${segments}    Evaluate    ", ".join(${user['segments']})
            END
            Log To Console    Segments: ${segments}
        END
        Log To Console    ${EMPTY}
    END

Get Users With Spending
    ${users}    Retrieve Customer Data
    ${users_with_spending}    Evaluate    [u for u in $users if u['total_spent'] != '$0.00']
    RETURN    ${users_with_spending}

Display Users With Spending
    ${users}    Get Users With Spending
    Log To Console    ${EMPTY}
    FOR    ${i}    ${user}   IN ENUMERATE    @{users}
        Log To Console    ${i+1}. ${user['name']}: ${user['total_spent']}
    END
    Log To Console    ${EMPTY}

Calculate Total Spending
    ${users}    Get Users With Spending
    ${total}    Evaluate    sum(float(u['total_spent'].replace('$', '').replace(',', '')) for u in $users)
    ${formatted_sum}    Format Amount    ${total}
    RETURN    ${formatted_sum}

Display Total Spending
    ${amount}    Calculate Total Spending
    Log To Console    ======================\nTotal Customer Spending: $${amount}\n======================

Format Amount
    [Arguments]    ${amount}
    ${formatted_value}    Evaluate    f"{${amount}:,.2f}"
    RETURN    ${formatted_value}

Validate Total Spending
    ${total_amount}    Calculate Total Spending
    IF    ${total_amount.replace(',', '')} < 3500
        Log To Console    FAIL: Total spending ($${total_amount}) is below minimum threshold ($3,500)
        Fail    Test execution
    ELSE
        Log To Console    PASS: Total spending ($${total_amount}) meets minimum threshold ($3,500)
    END

Analyze Spending Of Customers
    Display Users With Spending
    Display Total Spending
    Validate Total Spending