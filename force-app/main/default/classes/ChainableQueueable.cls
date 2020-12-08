public abstract class ChainableQueueable extends Chainable implements Queueable {

    // ABSTRACT

    protected abstract void execute(Context ctx);


    // PUBLIC

    public void execute(QueueableContext ctx) {
        execute(new Context(ctx));

        executeNext();
    }


    // OVERRIDE

    public override void executeAsynchronously() {
        System.enqueueJob(this);
    }


    public override void executeSynchronously() {
        execute(new Context());
    }
}
