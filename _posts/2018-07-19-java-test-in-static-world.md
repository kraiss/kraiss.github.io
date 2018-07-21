---
layout: post
title: Tests in 'static' world
author: Kraiss
tags: Java Test
---

## Or How to write unit tests when the code base is full of static calls

Recently I had to make a fix in legacy Java code. 
Problem, this code is not tested and cannot be tested easily because of static calls. 
Something like this

```java
public class A {
    public static AwesomeData awork(AwesomeParameters params) {
        // Doing stuff with 'params' to get parameters to call B.bwork(..) 
        AwesomeData data = B.bwork(params);
        // Doing stuff with 'data' to generate result
        return result;
    }
}

public class B {
    public static AwesomeData bwork(AwesomeParameters params) {
        // Do stuff with static calls
    }
}
```

Current code is not tested so I don't want to alter this to much, only the thing I need to fix the issue. 
So how to 1) fix the issue, 2) unit test the new code 3) with the less effort possible ?

This includes :
* Not adding new mocking dependency to the project. The project uses Mockito, which is great but cannot mock static calls.
* Not refactoring code around and keeping current "style" (aka static calls ftw) 

## #1 Make my awork(..) method non-static

To achieve this, I create an inner instance and hide the implementation in.

```java
public class A {
    private static final A instance = new A();
    private A() {}
    
    public static AwesomeData awork(AwesomeParameters params) {
        return instance.nonstatic_awork(params);
    }
    
    private AwesomeData nonstatic_awork(AwesomeParameters params) {
        // Doing stuff with 'params' to get parameters to call B.bwork(..) 
        AwesomeData data = B.bwork(params);
        // Doing stuff with 'data' to generate result
        return result;
    }
}
```

This way, calls to `A.awork(..)` from others classes are still static. 

## #2 Make the call to B override-able

I extract the call to B in a method to be able to mock the call

```java
public class A {
    private static final A instance = new A();
    A() {}
    
    public static AwesomeData awork(AwesomeParameters params) {
        return instance.nonstatic_awork(params);
    }
    
    AwesomeData nonstatic_awork(AwesomeParameters params) {
        // Doing stuff with 'params' to get parameters to call B.bwork(..) 
        AwesomeData data = callToB(params);
        // Doing stuff with 'data' to generate result
        return result;
    }
    
    AwesomeData callToB(AwesomeParameters params) {
        return B.bwork(params);
    }
}
```

## #3 Write tests for awork(..) with calls to B mocked

To keep the example simple, I didn't use any mocking framework in the example

```java
public class ATest {
    private A service;
    
    @Before
    public void before() {
        service = new A() {
            AwesomeData callToB(AwesomeParameters params) {
                // Code to create the data to return for my tests
            }
        };
    }
    
    // Tests nonstatic_awork(..) with calls to B mocked yeah!!
}
```

## #4 Fix awork(..)

Finally I update the tests to the behaviour I want after the fix and I fix the code.

The impacts are only located to class A and I have tests for my changes. Great!
