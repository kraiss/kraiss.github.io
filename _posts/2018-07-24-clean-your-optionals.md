---
layout: post
title: Don't use Optional.isPresent()!
author: Kraiss
tags: Java Optional
---

Yes, exactly! If you are using `Optional.isPresent()`, you are using Optional wrong. Shame on you! ...

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

This is classic code you can see after a moving from null check to Optional. 
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

This is not "that" bad but the aim of Optional is not to replace null by Optional. 
The aim is to provide a structure to avoid having to deal with null and, this way, write code more concise and more meaningful.

Let's simplify the example above using `Optional.map(..)` :

```java
    public Optional<Data> myAwesomeOptionalMethod() {
        return resultOfSomeMethod()
            .map(data -> service.process(data));
    }
```

So if you see `Optional.isPresent()` in your code, take a look at the method provided by Optional and you will find something to make it more fluent to write and to read
