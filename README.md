# Apex Chainable Batch [![Codacy Badge](https://api.codacy.com/project/badge/Grade/3814b20244d14e3d846ff05dfd3c2e2a)](https://www.codacy.com/app/rsoesemann/apex-chainable-batch?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=rsoesemann/apex-unified-logging&amp;utm_campaign=Badge_Grade)

Apex Batches can be chained by calling the successor batch from the `finish()` method of the previous batch. But such hardcoding makes this model inflexible. It's hard to build the chain from outside, neighter from a central class nor on runtime dependant on business logic.

<a href="https://githubsfdeploy.herokuapp.com?owner=rsoesemann&repo=apex-chainable-batch">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

## With `Chainable`

The `Chainable` wrapper class of this repository overcomes those drawbacks.

 - No need to hardcode successor batch in `finish()` method
 - Created batch chains of arbitrary length without changing existing Batch classes
 - Allows asynchronous and synchronous testing of Batch chains

```java
      new SecondBatch()
            .then(FirstBatch())
            .then(ThirdBatch())
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
class SecondBatch implements Batchable<SObject> {
    Iterator<SObject> start(BatchableContext ctx) { ... }

    void execute(BatchableContext ctx, List<Account> scope) { ... }

    void finish(BatchableContext ctx) {
        Database.enqueueBatch(new ThirdBatch()); 
    }
}
```




