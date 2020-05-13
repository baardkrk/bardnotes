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

In addition, we'll test out the other markdown features, such as [quotes][1]:

> There are three great virtues of a programmer; Laziness, Impatience and Hubris  
> *-- Larry Wall, original author of Perl*

Numbered Lists:

1. **Laziness**   
   The quality that makes you go to great effort to reduce overall energy expenditure. It makes you
   write labor-saving programs that other people will find useful and document what you wrote so you
   don't have to answer so many questions about it.

2. **Impatience**  
   The anger you feel when the computer is being lazy. This makes you write programs that don't just
   react to your needs, but actually anticipate them. Or at least pretend to.

3. **Hubris**  
   The quality that makes you write (and maintain) programs that other people won't say bad things
   about.

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
To update the theme, you just add it as a submodule to the project (unless already done) and change it.  
This is also needed if the repository for the site is freshly downloaded:
```
$ git clone <MAIN REPOSITORY>
$ cd <MAIN REPOSITORY>/themes
$ git submodule add <THEME REPOSITORY>
```
Building the site locally is done by calling
```
$ hugo server -D
```
Usually it will be available at `localhost:1313`
However, it is very important to have the *extended* version of hugo to build some of the themes, at least the one I'm using on this site.

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

[1]: http://threevirtues.com/
