@IsTest
public class Chainable_Test {

	private static final String CALL_LOG = 'calls';
	private static List<Object> deferredCalls;

	@TestSetup
	private static void prepareData() {
		insert new Account(Name = 'Acme'); // Note: SampleBatch iterates over Accounts
	}

	@IsTest
	private static void fullChain() {		

		// Execute
		Chainable chain = new SampleSchedulable()
									.setShared(CALL_LOG, new List<String>())

									.then( new SampleBatch() )
									.then( new SampleQueueable() )

									.execute();

		// Verify
		Iterator<Object> calls = ((List<Object>) chain.getShared(CALL_LOG)).iterator();
		System.assertEquals('SampleSchedulable.execute', (String)calls.next());
		System.assertEquals('SampleBatch.start', (String)calls.next());
		System.assertEquals('SampleBatch.execute', (String)calls.next());
		System.assertEquals('SampleBatch.finish', (String)calls.next());
		System.assertEquals('SampleQueueable.execute', (String)calls.next());
	}


	@isTest
	private static void deferredChains() {

		Test.startTest();

		// Execute
		Chainable chain = new SampleSchedulable()
									.setShared(CALL_LOG, new List<String>())
									.defer();

		Chainable chain2 = new SampleBatch()

									.then( new SampleQueueable() )
									.then( new SampleDeferArgQueueable(true) )

									.defer();

		Test.stopTest();

		// Verify
		Iterator<Object> calls = deferredCalls.iterator();
		System.assertEquals('SampleSchedulable.execute', (String)calls.next());
		System.assertEquals('SampleBatch.start', (String)calls.next());
		System.assertEquals('SampleBatch.execute', (String)calls.next());
		System.assertEquals('SampleBatch.finish', (String)calls.next());
		System.assertEquals('SampleQueueable.execute', (String)calls.next());
	}
	

	@isTest
	private static void failDeferChainableFault() {

		Test.startTest();

		// Execute
		try {
			Chainable chain = new SampleFailDefer()
										.defer();

			System.assert(false);
		}
		catch(Exception e) {
			System.assert(e instanceof Chainable.DeferUnlinkException);
		}

		Test.stopTest();
	}


	@isTest static void failRebuild() {

		String errorMsg = 'fail to rebuild';
		
		Test.startTest();

		List<ChainableDeferredEvent__e> unlinkEvents = new SampleFailRebuild(errorMsg)
																.unlink();

		System.assertEquals(1, unlinkEvents.size());

		DeferredChainableBuilder.DeferredChainLink param = new DeferredChainableBuilder.DeferredChainLink();
		param.deferEvent = unlinkEvents[0];

		List<DeferredChainableBuilder.DeferRebuildResult> results = DeferredChainableBuilder.rebuildAndExecuteChain(new DeferredChainableBuilder.DeferredChainLink[]{param});

		Test.stopTest();

		System.assert(!results[0].success);
		System.assertEquals(errorMsg, results[0].error);
	}

	@isTest static void failRebuildNoFound() {

		Test.startTest();

		List<ChainableDeferredEvent__e> unlinkEvents = new SampleFailRebuildInner()
																.unlink();

		System.assertEquals(1, unlinkEvents.size());

		DeferredChainableBuilder.DeferredChainLink param = new DeferredChainableBuilder.DeferredChainLink();
		param.deferEvent = unlinkEvents[0];

		List<DeferredChainableBuilder.DeferRebuildResult> results = DeferredChainableBuilder.rebuildAndExecuteChain(new DeferredChainableBuilder.DeferredChainLink[]{param});

		Test.stopTest();

		System.assert(!results[0].success);
		System.assert(results[0].error.startsWith(DeferredChainableBuilder.INVALID_CLASS_MSG));
	}

	// HELPER

	public static void log(Chainable chainable) {
		List<Object> calls = (List<Object>) chainable.getShared(CALL_LOG);
		calls.add(callLocation());
		deferredCalls = calls;
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

	private class SampleFailDefer extends ChainableQueueable {
		protected override String getDeferArgs() {
			throw new Chainable.DeferUnlinkException();
		}

		protected override void execute(Context ctx) {}
	}

	private class SampleFailRebuildInner extends ChainableQueueable {
		protected override void execute(Context ctx) {}
	}
}