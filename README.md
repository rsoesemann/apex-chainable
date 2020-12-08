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
 - Allows asynchronous and synchronous testing of Batch chains

```java
      new FirstBatch()
            .then(AnotherBatch().batchSize(1))
            .then(QueueableJob())
            .then(ScheduledJob().cron(...))
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





