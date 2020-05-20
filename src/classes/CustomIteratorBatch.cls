public class CustomIteratorBatch extends Chainable {

    private List<Object> values;

    public CustomIteratorBatch(List<Object> values) {
        this.values = values;
    }


    protected override Iterable<Object> start(Chainable.Context ctx) {
        return values;
    }


    protected override void execute(Chainable.Context ctx, Iterable<Object> scope) {
        for(String country : (List<String>) scope) {
            // Do somethings smart...
        }
    }


    protected override void finish(Chainable.Context ctx) {}


    protected override Integer batchSize() {
        return 1;
    }
}