---
title: "Android Jetpack"
date: 2020-04-09T21:48:44+02:00
tags: [android, programming]
draft: true
---

Android Jetpack is a new library that makes android development easier.



## View Binding
We can replace `findViewById()` with the view binding library. Instead of having to look 
up every view, we can use view binding to look up *every* view. They are held in a 
binding object. 
```kotlin
val binding = MyBinding.inflate(...)
binding.greeting.text = "Less boilerplate"
binding.subtitle?.let {
	it.text = "and Null-safe too!"
}
```

