# robotframework_cruz
This project uses Robot Framework to automate a website's customer list. It logs in, adds new customers, updates their information, and checks if the total amount of money they spent is at least $3,500.

## What it does:
1. **Add Users:** Automatically types in and saves custom number of new customers (Custom = Accepts no. to add based on argument).
2. **Update Users:** Changes the information for custom number of existing customers (Custom = Accepts no. to add based on argument).
3. **Log Data:** Reads the table and prints every user's details to the console.
4. **Data Check:** Totals the spending of all users and fails if it's under $3,500.
