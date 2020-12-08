@IsTest
public class Chainable_Test {

	private static final String CALL_LOG = 'calls';


	@IsTest
	private static void fullChain() {

		// Setup
		insert new Account(Name = 'Acme'); // Note: SampleBatch iterates over Accounts


		// Execute
		Chainable chain = new SampleSchedulable()
									.setShared(CALL_LOG, new List<String>())

									.then( new SampleBatch() )
									.then( new SampleQueueable() )

									.execute();

		// Verify
		Iterator<String> calls = ((List<String>) chain.getShared(CALL_LOG)).iterator();
		System.assertEquals('SampleSchedulable.execute', calls.next());
		System.assertEquals('SampleBatch.start', calls.next());
		System.assertEquals('SampleBatch.execute', calls.next());
		System.assertEquals('SampleBatch.finish', calls.next());
		System.assertEquals('SampleQueueable.execute', calls.next());
	}


	// HELPER

	public static void log(Chainable chainable) {
		List<String> calls = (List<String>) chainable.getShared(CALL_LOG);
		calls.add(callLocation());
	}


	// Note: Idea taken from https://salesforce.stackexchange.com/questions/153835
	private static String callLocation() {
		Pattern STACK_LINE = Pattern.compile('^(?:Class\\.)?([^.]+)\\.?([^\\.\\:]+)?[\\.\\:]?([^\\.\\:]*): line (\\d+), column (\\d+)$');

		for(String line : new DmlException().getStackTraceString().split('\n')) {
			Matcher matcher = STACK_LINE.matcher(line);

			if(matcher.find() && !line.startsWith('Class.' + Chainable_Test.class.getName() + '.')) {
				return matcher.group(1) + '.' + matcher.group(2);
			}
		}

		return null;
	}
}