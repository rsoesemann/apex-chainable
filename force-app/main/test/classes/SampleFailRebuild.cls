public class SampleFailRebuild extends ChainableQueueable {
    
    private String errorToThrow;

		public SampleFailRebuild() {}
		public SampleFailRebuild(String msg) {
			errorToThrow = msg;
		}

		protected override String getDeferArgs() {
			return errorToThrow;
		}
		public override void setDeferredArgs(String serializedArgs) {
			throw new Chainable.DeferUnlinkException(serializedArgs);
		}

		protected override void execute(Context ctx) {}
}