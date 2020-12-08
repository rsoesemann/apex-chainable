public abstract class ChainableBatch extends Chainable
                                     implements Database.Batchable<Object>, Database.Stateful, Database.AllowsCallouts {
    // ABSTRACT

    protected abstract Iterable<Object> start(Context ctx);
    protected abstract void execute(Context ctx, Iterable<Object> scope);
    protected abstract void finish(Context ctx);


    // PUBLIC

    public Iterable<Object> start(Database.BatchableContext ctx) {
        return start( new Context(ctx) );
    }


    public void execute(Database.BatchableContext ctx, Iterable<Object> scope) {
        execute( new Context(ctx), scope );
    }


    public void finish(Database.BatchableContext ctx) {
        finish( new Context(ctx) );

        executeNext();
    }


    protected virtual Integer batchSize() {
        return 200;
    }


    public override void executeAsynchronously() {
        Database.executeBatch(this, batchSize());
    }


    public override void executeSynchronously(Context ctx) {
        Iterable<Object> fullScope = start(ctx);

        if(fullScope.iterator().hasNext()) {
            execute(ctx, fullScope);
        }

        finish(ctx);
    }
}
