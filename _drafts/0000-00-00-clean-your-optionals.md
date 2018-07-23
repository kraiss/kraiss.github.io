---
layout: post
title: Don't use Optional.isPresent()!
author: Kraiss
tags: Java Optional
---

Yes, excatly! If you are using Optional.isPresent(), you are using Optional wrong. Shame on you! ...

Ok I get carried away a bit. But if you see this call, you can improve it. As instance:

```java
    public Optional<Data> myAwesomeOptionalMethod() {
        Optional<Data> data = resultOfSomeMethod();
        if (!data.isPresent()) {
            return Optional.empty();
        }

        return service.process(data.get());
    }
```

This is classic code you can see after a change from null check to Optional. 
If I look in Git history, the previous version was:

```java
    public Data myAwesomeOptionalMethod() {
        Data data = resultOfSomeMethod();
        if (data == null) {
            return null;
        }

        return service.process(data);
    }
```

## And what's the problem with that?

This is not "that" bad but Optional gives you really nice method to improve this.

Our example can be simplified to:

```java
    public Optional<Data> myAwesomeOptionalMethod() {
        return resultOfSomeMethod()
            .map(service::process);
    }
```

So if you are using isPresent in your code, take a look at the method provided by Optional an you will find something to make it more fluent to write and to read
