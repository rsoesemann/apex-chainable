public class SampleInternalErrorDuringTest extends ChainableBatch {

	protected override Iterable<Object> start(Context ctx) {
		Chainable_Test.log(this);

        return Database.getQueryLocator([SELECT Phone FROM Account]);
	}


	protected override void execute(Context ctx, Iterable<Object> scope) {
		Chainable_Test.log(this);
	}


	protected override void finish(Context ctx) {
		Chainable_Test.log(this);
	}
}