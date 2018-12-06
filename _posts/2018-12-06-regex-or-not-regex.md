---
layout: post
title: Regex or not regex
author: Kraiss
tags: Java regex Pattern
---

## Regex should be your last resort

### Show

```java
public static void main(String[] args) {
        String test = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa!";

        long before = System.currentTimeMillis();
        test.matches("a+");
        System.out.println("'a+' took " + (System.currentTimeMillis() - before) + "ms");

        before = System.currentTimeMillis();
        test.matches("(a+)+");
        System.out.println("'(a+)+' took " + (System.currentTimeMillis() - before) + "ms");
    }
```

### Current state

```java
private boolean matches(
            final MechanicalPart part,
            final Collection<String> prefixes,
            final Collection<String> suffixes) {
			
        final List<Pattern> pattern =
                prefixes.stream()
                        .map(s -> Pattern.compile("^" + s + "(#.+)?$"))
                        .collect(Collectors.toList());

        final String identity = part.getExtensionProperties().get(NFH_IDENTITY);
        final String partId = identity == null ? part.getId() : identity;
        return patterns.stream().anyMatch(pattern -> pattern.matcher(partId).matches()) &&
                (suffixes.isEmpty() || suffixes.stream().anyMatch(partId::endsWith));
    }
```

### A bit better

```java
    private boolean matches(
            final String partId,
            final Collection<String> prefixes,
            final Collection<String> suffixes) {
        boolean matchPrefix = prefixes.stream()
                .anyMatch(prefix -> partId.equals(prefix) || partId.startsWith(prefix + "#"));

        if (matchPrefix) {
            return suffixes.isEmpty() || suffixes.stream().anyMatch(partId::endsWith);
        }
        return false;
    }
```

### Really better

```java
    public static boolean matches(
            final String partId,
            final Collection<String> prefixes,
            final Collection<String> suffixes) {

        // Optimized predicate - partId should equals prefix OR partId starts by prefix following by '#' char
        boolean matchPrefix = prefixes.stream()
                .anyMatch(prefix -> partId.startsWith(prefix) && (partId.length() == prefix.length() || partId.charAt(prefix.length()) == '#'));

        if (matchPrefix) {
            return suffixes.isEmpty() || suffixes.stream().anyMatch(partId::endsWith);
        }
        return false;
    }
```
