---
title: "Spring Boot Notes"
date: 2020-05-13T12:49:57+02:00
draft: true
---

Spring Boot is a framework for creating backend-framework applications in Java. 
The application is usually divided into a few different layers:
- **API/Controller layer** This is where incoming and outgoing information is handeled. Logic for verifying input should be called early in this layer. This layer calls the next, the *service layer*. In this layer input is translated to domain objects, or data structures the application knows about. It is for example translated from JSON to POJOs.
- **Service layer** Handles the business logic. Input is manipulated and either returned, or the next layer is called. Only data structures or domain objects are allowed in this layer.
- **Data Access layer** Handles calls to other services, or databases. The response is returned to the *service layer*.

I will also clarify some terminology, introduced in Robert C. Martins *Clean Code*:  
**Objects** do not *expose their internals*. That means the local variables are hidden for whomever uses the object. We can get informaiton about it, and define it, but we know nothing of the implementation.  
**Data Structures** only *contain information*. Here getters/setters are fine, but no logic or other methods should be in such a class. That would create a hybrid, which is not clean. 


In a SpringApplication you will encounter a few standard packages. Usually there is one for each of the layers described above:  
- `api` (or `controllers`) for incoming and outgoing traffic.
- `service` for business logic, and a few packages for the data access layer.
- `models` contain domain objects or data structures that are used in the *service layer*. 
- `dto` Data Transfer Objects. This contains data structures for transfering data structures between other services, and can often be seen in place of `models`.
- `dao` Data Access Objects. Objects for interacting with a database or other services: updating, retriving, posting, ++. This means it corresponds to a folder for the *Data access layer*. It is a good idea to use interfaces to wrap APIs called from this layer. That way, if the API changes, we only have to change the class that implements the interface. 


## Beans
Beans are instances of objects which sould be able to be injected into other classes. This is done to reduce the bloat which comes with creating new instances of objects. The `RestTemplate` is an example of an often used bean. Let's say we have two or three objects in the `dao` package, which calls an API each, using the `RestTemplate`. If `RestTemplate` wasn't instantiated as a bean, we would create an instance of the `RestTemplate`-object for *each of the objects in the `dao`*. If, however, we do create a bean for it, all of the objects in the `dao` wil use the *same instance of a `RestTemplate`-object*.

We can create beans of our own classes as well, by using spring annotations before the class:  
- `@Component`:
- `@Repository`: The same as `@Component`, but makes it clear that this bean is accessing data.
- `@RestController`: Is used for objects in the *API/Controller layer*. 

When we do this, SpringBoot will start an instance of the object when the application starts. This means that if other objects require it (either via their constructor - which is the recommended way of doing it, or via the annotation `@Autowire`) SpringBoot will inject the instance into the object.

Beans can be created manually as well, in either the `AppConfig.java` file (recommended) or directly in the `Application` object instantiated with `@SpringBootApplication`. When we instantiate a bean, we can use the annotation `@DependsOn` to signal SpringBoot that it needs to create instances of the listed beans *before* it creates the bean with the annotation.

### Injecting interfaces
There might be multiple beans that implement the same interface. To inject the correct one when we call it, we use the `@Qualifier("implementationName")` annotation before the variable in the constructor injecting the bean. We also need to enrich the annotation before the implementing class with the same name, for example `@Component("implementationName"`.


## SpringBoot Test


## Building a Controller


## Building a Service


## Profiles


## Documentation
Springfox is an exellent tool to create the Swagger documentation for a SpringBoot application.
