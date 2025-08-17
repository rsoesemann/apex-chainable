public abstract class ChainableDataBatch extends Chainable
                                     implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    // ABSTRACT

    protected abstract Database.QueryLocator start(Context ctx);
    protected abstract void execute(Context ctx, List<SObject> scope);
    protected abstract void finish(Context ctx);


    // PUBLIC

    public Database.QueryLocator start(Database.BatchableContext ctx) {
        return start( new Context(ctx) );
    }


    public void execute(Database.BatchableContext ctx, List<SObject> scope) {
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
        Database.QueryLocator fullScope = start(ctx);
        Database.QueryLocatorIterator iterator = fullScope.iterator();
        List<SObject> batchedList = new List<SObject>();
        Integer batchIndex = 0;

        while(iterator.hasNext()) {
            batchedList.add(iterator.next());
            if(batchedList.size() == batchSize()) {
                batchIndex++;
                execute(ctx, batchedList);
                batchedList.clear();
            }
            if (Test.isRunningTest() && batchIndex == 1) {
                break;
            }
        }
        if(!batchedList.isEmpty()) {
            execute(ctx, batchedList);
        }

        finish(ctx);
    }
}