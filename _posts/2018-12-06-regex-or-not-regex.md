---
layout: post
title: Regex or not regex
author: Kraiss
tags: Java regex Pattern
---

## Regex should be your last resort

### Regex can go very very bad 

Ok, so before we go in the today example. Let's agree that you should not use regex when possible.

If you are not convince yet, check this. Do you think this take long to execute ?

```java
"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa!".matches("a+");
```

This takes millis to execute and now, what about this one ?

```java
"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa!".matches("(a+)+");
```

This takes seconds ! Regex is a powerful tool but it hides high complexity, a simpler solution is always better

### Example from a real case

Our case, a REST endpoint with really bad performance. Around 1 second for "simple operations". 

The request go through around 2000 lines of code. When analysing it, I felt on this piece of code.

```java
private boolean matches(
            final String partId,
            final Collection<String> prefixes,
            final Collection<String> suffixes) {
			
        final List<Pattern> pattern =
                prefixes.stream()
                        .map(s -> Pattern.compile(String.format("^%1$s(#.*)?$", s)))
                        .collect(Collectors.toList());

        return patterns.stream().anyMatch(pattern -> pattern.matcher(partId).matches()) &&
                (suffixes.isEmpty() || suffixes.stream().anyMatch(partId::endsWith));
    }
```

After wiping off the blood under my eyes and the vomit on my keyboard, I tried to improve this a bit.

#### First, remove the String format

This is a simple string concatenation and `String.format(..)` cost A LOT for nothing here

```java
private boolean matches(
            final String partId,
            final Collection<String> prefixes,
            final Collection<String> suffixes) {
			
        final List<Pattern> pattern =
                prefixes.stream()
                        .map(s -> Pattern.compile("^" + s+ "(#.*)?$"))
                        .collect(Collectors.toList());

        return patterns.stream().anyMatch(pattern -> pattern.matcher(partId).matches()) &&
                (suffixes.isEmpty() || suffixes.stream().anyMatch(partId::endsWith));
    }
```

#### Second, remove the Patterns

If we look closer at the regex/pattern/stream thing, we see that we create regex to check if
 * `^abc$` the string is equal to `abc` 
 * `^abc#.*$` the string starts by `abc` followed by a hash sign and maybe other chars.

So the regex `^abc(#.*)?$` as instance, can be replaced by the condition `String.equals("abc") || String.startsWith("abc#")` because we don't care what comes after the hash sign.

Let's refactor our example with this

```java
private boolean matches(
            final String partId,
            final Collection<String> prefixes,
            final Collection<String> suffixes) {
	boolean start = prefixes.stream().anyMatch(prefix -> partId.equals(prefix) || partId.startsWith(prefix + "#"))
        return start && (suffixes.isEmpty() || suffixes.stream().anyMatch(partId::endsWith));
    }
```

Ok, it's better. We removed the worst things of this piece of code. At this point the REST endpoint takes around 300ms. Yes, I'm not kidding, apart from all the other things this endpoint is doing, this piece of code was 2/3 of the endpoint processing.

But it's not finished we can do a bit better.

#### Third, split the condition

What's the problem. Actually there is two
 * If 'partId' is not equal to prefix we loop over the string two times. One for the `String.equals`, one for the `String.startsWith`.
 * We are concatening 'prefix' with a hash sign creating a temporary String. This costs a bit of process and memory we can avoid. 

So in both we want to see if the string starts with the prefix, then two cases, the string ends here or is followed by a hash sign

Let's translate it to code.

```java
private boolean matches(
            final String partId,
            final Collection<String> prefixes,
            final Collection<String> suffixes) {
	boolean start = prefixes.stream().anyMatch(
	    prefix -> partId.startsWith(prefix) && 
	    (partId.length() == prefix.length() || partId.charAt(prefix.length()) == '#')
        );
        return start && (suffixes.isEmpty() || suffixes.stream().anyMatch(partId::endsWith));
    }
```

Now we come down to around 250ms, congrats to us! :p

This is not really nice to read/understand so we need to refactor it a bit, add comments maybe, but it's the easy part (is it? :p)
