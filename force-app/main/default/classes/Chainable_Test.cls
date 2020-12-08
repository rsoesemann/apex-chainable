@IsTest
private class Chainable_Test {


	@IsTest
	private static void fullChain() {

		// Setup
		insert new Account(Name='Acme');


		// Execute
		new SampleSchedulable()
					.name('myName')
					.cron('10 0 0 ? * * *')

				.then( new SampleRecordBatch()
								.batchSize(1) )

				.then( new SampleIteratorBatch(new List<String>{ 'France', 'Spain', 'Germany' })
								.batchSize(1) )

				.then( new SampleQueueable() )

				.synchronouslyInTests()
				.execute();


		// Verify
		System.assertEquals(1, SampleSchedulable.methodCalls);
		System.assertEquals(1, SampleQueueable.methodCalls);
		System.assertEquals(1 + 1 + 1, SampleRecordBatch.methodCalls);
		System.assertEquals(1 + 1 + 1, SampleIteratorBatch.methodCalls);
	}
}