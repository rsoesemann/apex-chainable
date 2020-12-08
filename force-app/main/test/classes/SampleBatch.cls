public class SampleBatch extends ChainableBatch {

	protected override Iterable<Object> start(Context ctx) {
		Chainable_Test.log(this);

        return (Iterable<Object>) [SELECT Phone FROM Account];
	}


	protected override void execute(Context ctx, Iterable<Object> scope) {
		Chainable_Test.log(this);
	}


	protected override void finish(Context ctx) {
		Chainable_Test.log(this);
	}
}