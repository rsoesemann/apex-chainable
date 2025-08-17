@IsTest 
public with sharing class Error_Test {

	private static final String CALL_LOG = 'calls';
	private static List<Object> deferredCalls;

	@TestSetup
	private static void prepareData() {
		insert new Account(Name = 'Acme'); // Note: SampleBatch iterates over Accounts
	}

	@IsTest
	private static void showErrorDuringTest() {		

		// Execute
		Chainable chain = new SampleInternalErrorDuringTest()
									.setShared(CALL_LOG, new List<String>())
									.execute();

	}

}