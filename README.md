# Apex Chainable [![Codacy Badge](https://app.codacy.com/project/badge/Grade/7024ec2e01c24c03a323e565e029a5a6)](https://www.codacy.com/gh/rsoesemann/apex-chainable/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=rsoesemann/apex-chainable&amp;utm_campaign=Badge_Grade)

<a href="https://githubsfdeploy.herokuapp.com?owner=rsoesemann&repo=apex-chainable-batch">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

Apex Batches can be chained by calling the successor batch from the `finish()` method of the previous batch. 
But such hardcoding makes this model inflexible. It's hard to build the chain from outside, neighter from a central class 
nor on runtime dependant on business logic.

The same applies when the `execute()` method of `Schedulable` or `Queueable` classes call other classes.

## With `Chainable`

The `Chainable` wrapper class of this repository overcomes those drawbacks.

 - No need to hardcode successor batch in `finish()` method
 - Created batch chains of arbitrary length without changing existing Batch classes
 - Support `Batchable`, `Queueable` and `Schedulable` classes as chain members
 - Allows sharing and passing of variables between chain members

```java
      new FirstBatch().setShared('result', new Money(0))
            .then(AnotherBatch())
            .then(QueueableJob())
            .then(ScheduledJob())
            ...
            .execute();
```

## Without `Chainable`

```java
class FirstBatch implements Batchable<SObject> {
    Iterator<SObject> start(BatchableContext ctx) { ... }

    void execute(BatchableContext ctx, List<Account> scope) { ... }

    void finish(BatchableContext ctx) {
        Database.enqueueBatch(new SecondBatch()); 
    }
}
```

```java
class AnotherBatch implements Batchable<SObject> {
    Iterator<SObject> start(BatchableContext ctx) { ... }

    void execute(BatchableContext ctx, List<Account> scope) { ... }

    void finish(BatchableContext ctx) {
        System.schedule('name', cron, new ScheduledJob()); 
    }
}
```

## Deferring

There are some use cases on which all the "links" in the chain are not completely identified beforehand in order to assemble them in a single chain and trigger its execution, such as when different automations are triggered in the same transaction and for which it might result on separate chainable async processes launched in parallel. This could then not only generate race conditions but also violate async jobs governor limits and therefore make difficult to decouple all the links in the chain when there's not a single orchestrator process.

To mitigate these pitfalls, the `Chainable` framework enables a way to *defer* the processes to be executed when the transaction ends, this means that all chainable processes that have been *deferred* will be automatically chained together in a **single** chain and executed sequentually, therefore promoting the decoupling of unrelated processes but still respecting the principle and benefits of being chainable.

```java

// automation 1
new FirstBatch()
        .then(AnotherBatch())
        .setShared('result', new Money(0)) // shared variables will be available across other following deferred chainables
        .executeDeferred();

// automation 2
new QueueableJob()
            .then(ScheduledJob())
            ...
            .executeDeferred();


```

### Considerations

In order to leverage the deferring of the Chainable instances there are some nuances compared to its direct execution.

#### Deferring arguments

If the Chainable class receives external input before its execution via constructor parameters or setters, you must override the `getDeferArgs` method to serialize them so the arguments are not lost during deferring. Similarly you'll need to override the `setDeferredArgs` method so when the deferred instance is rebuilt the instance can reassign its arguments based on what was originally returned from `getDeferArgs`. See the `SampleDeferArgQueueable` as an example.

#### Parametrized constructors

Any Chainable that supports deferring must have a no-arg constructor (otherwise it cannot be instatiated dynamically during rebuilding, at least not with what is available today in Apex). If no explicit constructor exists, the default implicit one will be used.

#### Deferring shared variables

Similar behaviour as deferring arguments but for shared variables (by overriding the `getDeferShared` and `setDeferredShared` methods), although for these there's a default behaviour implemented in the Chainable main class that relies on basic JSON seralization an untyped deserialization.

Shared variables are shared among all deferred chainable instances, even if those were not originally part of the same chain.

#### Chainable must not be an inner class

Considering that is not currently feasible to dynamically get the name of the class when is an inner class, therefore the rebuilding of the insance after deferring would fail.

#### Instance defer error handling

It could happen that the deferring process fails because of the the following:

* Transactional governor limits violation
* Platform event publishing issues (mechanism used to defer the process)
* Exceptions in the deferring of arguments or shared variables

You can override the `handleDeferException` in your Chainable subclass to implement your own error handling logic, by default an exception with be thrown.

#### Instance rebuild error handling

Similar to the above, when rebuilding the deferred chainables instances after the main transaction has finished, the rebuilding of the instances could fail, if you want to handle the errors gracefully you can take the rebuilding Apex action output in the `ChainableDeferredListener` flow and process it accordingly.