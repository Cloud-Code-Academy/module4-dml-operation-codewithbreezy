/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Briana Stout
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        Account acc = new Account ();// Create a new Account instance

        acc.Name = 'The Hardware Store' ; // Set some fields on the Account

       insert acc; // Insert the Account into the database

        // Return the Id of the newly created Account
        return acc.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
       Account acc = new Account (Name = name, Industry = industry); // Create a new Account and set the fields inline

       insert acc; // Insert the Account
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
      Contact con = new Contact ();  // Create a new Contact instance

        con.FirstName = 'Mickey';
        con.LastName = 'Mouse';
        con.AccountId = accountId;// Set some fields on the Contact
        // Set the AccountId field to the given accountId

       insert con; // Insert the Contact into the database

        // Return the Id of the newly created Contact
        return con.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database
        Contact con = [SELECT Id FROM Contact WHERE Id = :contactId LIMIT 1];

        con.LastName = newLastName;// Update the Contact's last name

        update con;// Update the Contact in the database
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Retrieve the Opportunity from the database
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :oppId LIMIT 1];

        opp.StageName = newStage;// Update the Opportunity's stage

       update opp; // Update the Opportunity in the database
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Query the account
        Account acc = [SELECT Id FROM Account WHERE Id = :accountId LIMIT 1];
    
        acc.Name= newName;
        acc.Industry = newIndustry;

         update acc;// Update the Account with the given Id with the new name and industry
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {

        for (Opportunity opp : opportunities) {// Loop through each Opportunity in the list
          opp.StageName = 'Qualification' ; // Set the Opportunity's Stage to Qualification
          opp.CloseDate = Date.today().addMonths(3); // Set the Opportunity's Close Date to 3 months from today
        opp.Amount = 50000; // Set the Opportunity's Amount to 50000
        }
       upsert opportunities; // Upsert the opportunities List so that records are either updated or created
    }

    /**
     * Question 8
     * Insert or update opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * HINT: The account may or may not exists in the database but is required for opportunity creation. Consider how upsert operation can help with this.
     * HINT: There should not be duplicate opportunites based on the name
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
 public static void upsertOpportunities(String accountName, List<String> oppNames) {
  
    List<Account> existingAccounts = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];

    Account acc;
    if (!existingAccounts.isEmpty()) {
        acc = existingAccounts[0];
    } else {
        acc = new Account(Name = accountName);
        insert acc;
    }


    Map<String, Opportunity> existingOppsMap = new Map<String, Opportunity>();
    for (Opportunity opp : [
        SELECT Id, Name FROM Opportunity 
        WHERE Name IN :oppNames AND AccountId = :acc.Id
    ]) {
        existingOppsMap.put(opp.Name, opp);
    }

    List<Opportunity> oppsToUpsert = new List<Opportunity>();
    for (String oppName : oppNames) {
        Opportunity opp;
        if (existingOppsMap.containsKey(oppName)) {
            // Update existing opportunity
            opp = existingOppsMap.get(oppName);
        } else {
            // Create new opportunity
            opp = new Opportunity();
            opp.Name = oppName;
        }

        opp.AccountId = acc.Id;
        opp.StageName = 'Prospecting';
        opp.CloseDate = Date.today().addMonths(3);

        oppsToUpsert.add(opp);
    }
    upsert oppsToUpsert;
}
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
		// Query for the Account
		List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName];

          Account acc = new Account();

  if (!accounts.isEmpty()) {
        // Account exists — update its description
        acc = accounts[0];
        acc.Description = 'Updated Account';
    } else {
        // No Account exists — create a new one
        acc = new Account(Name = accountName, Description = 'New Account');
    }

    // Upsert the Account
    upsert acc;

    return acc;
}


    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
		List<Contact> updatedContacts = new List<Contact>();

       for (Contact c : contactsToUpsert) {
            Account acc = upsertAccount(c.LastName); // Link to Account.Name = Contact.LastName
            c.AccountId = acc.Id;
            updatedContacts.add(c);
        }

        upsert updatedContacts;
    }
}
	

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {

        List<Lead> leadsToInsert = new List<Lead>();

         for (String name : leadNames) {
            leadsToInsert.add(new Lead (
                FirstName = 'John',
                LastName = 'Doe',
                Company = 'Test Company'
                ));
                
         }
         // Loop through each Lead name

        insert leadsToInsert;// Insert the Leads

    
        delete leadsToInsert;// Delete the Leads
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        
        List<Case> casesToInsert = new List<Case>();
        
        for (Integer i = 0; i < numOfCases; i++) {
            Case c = new Case(
                  Subject = 'Test Case ' + i,
                  Status = 'New',
                  Origin = 'Phone',
                  AccountId = accountId
            );
            casesToInsert.add(c);

            insert casesToInsert;

        delete casesToInsert;// Delete the cases
    }
}