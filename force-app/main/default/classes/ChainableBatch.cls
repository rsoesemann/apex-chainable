public abstract class ChainableBatch extends Chainable implements Database.Batchable<Object>, Database.Stateful {

    protected Integer batchSize  = 200;


    // ABSTRACT

    protected abstract Iterable<Object> start(Context ctx);
    protected abstract void execute(Context ctx, Iterable<Object> scope);
    protected abstract void finish(Context ctx);


    // PUBLIC

    public Iterable<Object> start(Database.BatchableContext ctx) {
        return start(new Context(ctx));
    }


    public void execute(Database.BatchableContext ctx, Iterable<Object> scope) {
        execute(new Context(ctx), scope);
    }


    public void finish(Database.BatchableContext ctx) {
        finish(new Context(ctx));

        executeNext();
    }

    public virtual ChainableBatch batchSize(Integer value) {
        batchSize = value;
        return this;
    }


    public override void executeAsynchronously() {
        Database.executeBatch(this, batchSize);
    }


    public override void executeSynchronously() {
        Context nullCtx = new Context();
        Iterable<Object> fullScope = start(nullCtx);

        if(fullScope.iterator().hasNext()) {
            execute(nullCtx, fullScope);
            finish(nullCtx);
        }
    }
}
