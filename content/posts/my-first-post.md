---
title: "My First Post"
date: 2020-03-06T15:34:50+01:00
tags: [thoughts, article, hugo]
draft: false
---
Here's my first post on this site, built with Hugo.
This is where I'll collect my notes on all kinds of topics! I hope to be able to share all my different interests, such as

 - Programming
 - Security
 - Photography
 - Robotics
 - Karate
 - Architecture
 - FPGAs and Electronics

The site structure will have to come later..
It would also be interesting to see how tables look:

|  A  |  B  | A xor B |
|:---:|:---:|:-------:|
|  0  |  0  |    0    |
|  0  |  1  |    1    |
|  1  |  0  |    1    |
|  1  |  1  |    0    |

Also, I forked the m10c theme, because just adding the submodule apparently wasn't enough for github. Hope this works..
And later, we'll have to check out if we can activate KaTeX!

-----------------------------------------------------------------------------

### Hugo usage
Before I forget, I think I should write down how to use the Hugo framework.
Creating a new post:
```
$ cd <HUGO REPOSITORY PATH>
$ hugo new posts/<NEW POST NAME>
... <WRITE POST>
$ ./deploy.sh
```
Should do everything from updating the current repository, as well as updating the GitHub page.

------------------------------------------------------------------------------

Also, just for fun, let's see how hugo handles syntax highlighting in code

#### C/C++
```c
#include <stdio.h>

int
main(int argc, char **argv) 
{
    printf("Hello, World!\n");
    return 0;
}
```
#### Java
```java
class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
```
#### Python
```python
def foo():
    print("Hello, World!")


if __name__ == '__main__':
    foo()
```
#### Lisp
```lisp
(defun foo ()
    (format t "Hello, World!~%"))

(foo)
```

That's all folks!
