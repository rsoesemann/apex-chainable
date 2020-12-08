public abstract class Chainable {

	private Chainable next;
	private Boolean synchronouslyInTests = false;


	// ABSTRACT

	protected abstract void executeAsynchronously();
	protected abstract void executeSynchronously();

	
	// PUBLIC

	public Chainable then(Chainable successor) {
		if(next != null) {
			next.then(successor);
		}
		else {
			next = successor;
		}

		return this;
	}


	public Chainable synchronouslyInTests() {
		synchronouslyInTests = true;
		return this;
	}


	public void execute() {
		if(Test.isRunningTest() && synchronouslyInTests) {
			executeSynchronously();
			executeNext();
		}
		else {
			executeAsynchronously();
		}
	}
	
	// PROTECTED
	
	protected void executeNext() {
		if(next != null) {
			next.synchronouslyInTests = synchronouslyInTests;
			next.execute();
		}
	}


	// INNER

	public class Context {

		private Object original;

		public Context() {}

		public Context(Database.BatchableContext ctx) {
			original = ctx;
		}

		public Context(QueueableContext ctx) {
			original = ctx;
		}

		public Context(SchedulableContext ctx) {
			original = ctx;
		}

		public Object getOriginal() {
			return original;
		}
	}
}
