public class SampleIteratorBatch extends ChainableBatch {

    public static Integer methodCalls = 0;

    private List<Object> values;


    // CTOR

    public SampleIteratorBatch(List<Object> values) {
        this.values = values;
        batchSize = 1;
    }


    // PUBLIC

    protected override Iterable<Object> start(Chainable.Context ctx) {
        methodCalls++;
        return values;
    }


    protected override void execute(Chainable.Context ctx, Iterable<Object> scope) {
        methodCalls++;
    }


    protected override void finish(Chainable.Context ctx) {
        methodCalls++;
    }
}