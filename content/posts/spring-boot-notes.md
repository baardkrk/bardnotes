---
title: "Spring Boot Notes"
date: 2020-05-13T12:49:57+02:00
draft: true
tags: [ programming, java, springboot, backend, database, rest ]
---

Spring Boot is a framework for creating backend-framework applications in Java. 
The application is usually divided into a few different layers:
- **API/Controller layer** is where incoming and outgoing information is handeled. Logic for verifying input should be called early in this layer. This layer calls the next, the *service layer*. In this layer input is translated to domain objects, or data structures the application knows about. It is for example translated from JSON to POJOs.
- **Service layer** handles the business logic. Input is manipulated and either returned, or the next layer is called. Only data structures or domain objects are allowed in this layer.
- **Data Access layer** handles calls to other services, or databases. The response is returned to the *service layer*.

I will also clarify some terminology, introduced in Robert C. Martins *Clean Code*:  
**Objects** do not *expose their internals*. (i.e. the implementation is *hidden*) That means the local variables are hidden for whomever uses the object. We can get informaiton about it, and define it, but we know nothing of the implementation.  
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
- `@Component` is a component of the application. Instantiates a bean of the class automatically when the application starts.
- `@Repository` is the same as `@Component`, but makes it clear that this bean is accessing data.
- `@RestController` is used for objects in the *API/Controller layer*. 

When we do this, SpringBoot will start an instance of the object when the application starts. This means that if other objects require it (either via their constructor - which is the recommended way of doing it, or via the annotation `@Autowire`) SpringBoot will inject the instance into the object.

Beans can be created manually as well, in either the `AppConfig.java` file (recommended) or directly in the `Application` object instantiated with `@SpringBootApplication`. When we instantiate a bean, we can use the annotation `@DependsOn` to signal SpringBoot that it needs to create instances of the listed beans *before* it creates the bean with the annotation.

### Injecting interfaces
There might be multiple beans that implement the same interface. To inject the correct one when we call it, we use the `@Qualifier("implementationName")` annotation before the variable in the constructor injecting the bean. We also need to enrich the annotation before the implementing class with the same name, for example `@Component("implementationName"`.

## Building a Controller
The controller is the applications face outward. Here, the way other applications interact with yours is implemented - it's *your* API. That means that what an endpoint in a controller accepts should not change, or at least, change in ways that don't break earlier releases for the API. 

### Endpoint implementations
The endpoints are usually annotated with a mapping. One exists for each operation supported in the HTTP spec.
- `@GetMapping`, requesting resources, for example an HTML page.
- `@PostMapping`, update *new* resources. The *Server* decides the URI for the newly created resources.
- `@PutMapping`, oppdatere ressurser. Is used when the *client* decides the URI for a newly developed resource. The PUT method tries to store the data under the sepcified URI. If the URI refers to an existing resource, the data being sent will be interpreted as a modified version of the same data that exists at the locaiton the URI points to on the server. If the resource doesn'nt exist, it will be defined as a new resource which is created on the server.
- `@DeleteMapping`, delete resources
- `@PatchMapping`, is used when the client sends one or more changes that should be done on the server.


In the method that implements an endpoint, we can provide a few different method parameters. The parameters usually have an annotation describing where in the request the variable gets its data from:
- `@PathVaraible` parameters that are found in the *path* of the request.
- `@RequestParam` parameters that are put in the *query-variables* of the request. Examples of query parameters are as follows: `?varName1={varname}&varName2={varname}`
- `@RequestBody` an object that is passed as the *body* of the request.
- `@RequestHeader` variables that is gotten from the *header* of the request.

From the library fasterxml, we usually add the jackson `@JsonProperty`, which can be used either to annotate values in data structures (not neccessary if the variable is named the *same* as the json-property) or, to annotate method parameters that are found in a json-request body.

```java
@RestController
public class GenericEntityController {
	private List<GenericEntity> entityList = new ArrayList<>();
	
	@GetMapping("/entity/all")
	public List<GenericEntity> findAll() {
		return entityList();
	}
	
	@PostMapping("/entity")
	public GenericEntity addEntity(GenericEntity entity) {
		entityList.add(entity);
		return entity;
	}
	
	@GetMapping("/entity/findby/{id}")
	public GenericEntity findById(@PathVariable Long id) {
		return entityList.stream()
			.filter(entity -> entity.getId().equals(id))
			.findFirst().get();
	}
```


## Building a Service


## Profiles


## SpringBoot Test
There are mainly two types of tests we write for an application. 

### H2/In-memory database


## Documentation
Springfox is an exellent tool to create the Swagger documentation for a SpringBoot application.


## Databases

### Postgres

### Flyway
