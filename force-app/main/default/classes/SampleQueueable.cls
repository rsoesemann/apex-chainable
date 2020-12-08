public class SampleQueueable extends ChainableQueueable {

	public static Integer methodCalls = 0;


	protected override void execute(Chainable.Context ctx) {
		methodCalls++;
	}
}