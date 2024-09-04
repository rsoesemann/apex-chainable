public with sharing class SampleDeferArgQueueable extends ChainableQueueable {
	
	private Boolean deferArg = false;

	public override void setDeferredArgs(String serializedArgs) {
		deferArg = Boolean.valueOf(serializedArgs);
	}

	protected override String getDeferArgs() {
		return String.valueOf(deferArg);
	}

	public SampleDeferArgQueueable() {}
	public SampleDeferArgQueueable(Boolean syncArg) {
		deferArg = syncArg;
	}

	protected override void execute(Context ctx) {
		if(deferArg) {
			Chainable_Test.log(this);
		}
	}
}