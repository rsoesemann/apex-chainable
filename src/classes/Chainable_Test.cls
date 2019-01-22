@IsTest
private class Chainable_Test {

	@IsTest
	private static void runAsBatch() {

		// Setup
		insert new Account(Name='Acme', AnnualRevenue=1000);


		// Exercise
		Test.startTest();

		new SetIndustryBatch('Automotive')
						.then(new AddPhoneBatch())
						.then(new MultiplyRevenueBatch(2))

						.execute();

		Test.stopTest();


		// Verify
		Account a = [SELECT Industry, Phone, AnnualRevenue FROM Account LIMIT 1];

		System.assertEquals('Automotive', a.Industry);
		System.assertNotEquals(null, a.Phone);
		System.assertEquals(2000, a.AnnualRevenue);
	}


	@IsTest
	private static void runSynchronously() {

		// Setup
		insert new Account(Name='Acme', AnnualRevenue=1000);


		// Exercise
		new SetIndustryBatch('Automotive')
					.then(new AddPhoneBatch())
					.then(new MultiplyRevenueBatch(2))

					.synchronouslyInTests()

					.execute();


		// Verify
		Account a = [SELECT Industry, Phone, AnnualRevenue FROM Account LIMIT 1];

		System.assertEquals('Automotive', a.Industry);
		System.assertNotEquals(null, a.Phone);
		System.assertEquals(2000, a.AnnualRevenue);
	}
}