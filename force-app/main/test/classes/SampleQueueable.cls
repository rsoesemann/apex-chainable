public class SampleQueueable extends ChainableQueueable {

	protected override void execute(Context ctx) {
		Chainable_Test.log(this);
	}
}