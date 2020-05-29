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

```java
// How we normally create an object in java:
private var myObject = new MyObject();

// This is already done by the @Bean annotation, and we can access 
// it by injecting it anywhere:
@Bean
class MyObject {...}

class MyDependentObject {
	private static MyObject myObject;
    // The bean created of MyObject is automatically injected in 
	// this field (they don't have to be in the same file.)
    public MyDependentObject(MyObject myObject) {
	    this.myObject = myObject;
	}
}
```

We can create beans of our own classes as well, by using spring annotations before the class:  
- `@Component` is a component of the application. Instantiates a bean of the class automatically when the application starts.
- `@Repository` is the same as `@Component`, but makes it clear that this bean is accessing data.
- `@RestController` is used for objects in the *API/Controller layer*. 

When we do this, SpringBoot will start an instance of the object when the application starts. This means that if other objects require it (either via their constructor - which is the recommended way of doing it, or via the annotation `@Autowire`) SpringBoot will inject the instance into the object.

Beans can be created manually as well, in either the `AppConfig.java` file (recommended) or directly in the `Application` object instantiated with `@SpringBootApplication`. When we instantiate a bean, we can use the annotation `@DependsOn` to signal SpringBoot that it needs to create instances of the listed beans *before* it creates the bean with the annotation.

### Injecting interfaces
There might be multiple beans that implement the same interface. To inject the correct one when we call it, we use the `@Qualifier("implementationName")` annotation before the variable in the constructor injecting the bean. We also need to enrich the annotation before the implementing class with the same name, for example `@Component("implementationName")`.


## Maven Dependency Manager
In this document we'll use maven to manage our dependencies, however Gradle is also widely used. Everything is collected in the `pom.xml` file.

### What's in the pom.xml?
Maven uses the pom to ensure that the project is build exactly the same on any machines.

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
- `@RequestParam` parameters that are put in the *query-variables* of the request.
- `@RequestBody` an object that is passed as the *body* of the request.
- `@RequestHeader` variables that is gotten from the *header* of the request.

From the library fasterxml, we usually add the jackson `@JsonProperty`, which can be used either to annotate values in data structures (not neccessary if the variable is named the *same* as the json-property) or, to annotate method parameters that are found in a json-request body.

### Return types
When returning from an endpoint, we want to define what the caller can expect. To do this, we can either return a POJO, which will create a json for it and return that. However, we usually want to be able to return error codes such as `BAD_REQUEST`, `INTERNAL_SERVER_ERROR`, or `IM_A_TEAPOT` as well. To define these, we return a `ResponseEntity`.


### Example
For starters, we have to add the dependency for springboot in the maven pom:
```xml
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-web</artifactId>
</dependency>
```
An implementation of a simple controller. Remember that controllers should also be subject to *Clean Code*, and so the controller classes should be split according to the Single Resposibility Principle (SRP).
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

### Pagination
TBD

## Building a Service
In the service layer, all the application specific code goes. Here, it is important to remember the principles of *Clean Code*. The objects here should have *hidden implementation*. Other things to remember is to divide classes after the Single Responsibility Principle (SRP). Functions should do only *one* thing, and should have *no side effects*.


## Profiles and Configuration
There are usually a few different scenarios we want to run our application in: *test*, *dev*, and *prod*. For each of these scenarios, we want different configurations. For *test* we don't actually want to make any calls outside the application, and for *dev* we might want to set some environment variables ourselves, to test the application locally on our own machine. In *prod* we want to call secret stores and get the environment variables from there.  
For each of these profiles, we can create an `application.properties` file in the `resources` folder. Spring will automatically pick the property file based on which profile is running. Therefore, it is important to choose the correct name for the folder. If the profile *test* is running, spring will get the `application-test.properties` file. If *prod* is running, the `application-prod.properties`. If any properties should be the same across all profiles, we can define them in the `application.properties` file. An important note here is that passwords or other secrets usually are environment variables. Therefore it is very important to **_never fall for the temptation to log, hardcode, or put them in comments!_** Usually they are provided through some service, like *vault*, but you should still not log or put them in comments. You can use a debugging tool to see what they are during runtime instead. 

With the `@Configuration` annotation we can create classes that instantiates a given set of beans with a given set of values. Accompanied with the `@Profile` tag we can specify which profile the configuration should work for.

```java
@Retention(RUNTIME)
@Target({TYPE, METHOD})
@Profile("dev")
public @interface Development {}


@Bean
@Development
class OnlyActiveOnDev { ... }
```


## Documentation
Springfox is an exellent tool to create the Swagger documentation for a SpringBoot application. Most of the documentation will be found in either the `dto`s, or in the controllers. Springfox has its own configuration file, we call the `SwaggerConfig`. More information for the swagger config can be found at [springfox's documentation](https://springfox.github.io/springfox/docs/current/).

```java
@Configuration
@EnableSwagger2
public class SwaggerConfig implements WebMvcConfigurer {

    @Bean
    public Docket api() {
        HashSet contentTypeJson = new HashSet(Arrays.asList("application/json"));
        return new Docket(DocumentationType.SWAGGER_2)
                .ignoredParameterTypes(ApiIgnore.class)
                .select()
                .apis(RequestHandlerSelectors.any())
                .paths(PathSelectors.ant("/api/**"))
                .build()
                .apiInfo(apiInfo())
                .produces(contentTypeJson)
                .consumes(contentTypeJson)
                .useDefaultResponseMessages(false);
    }

    private ApiInfo apiInfo() {
        return new ApiInfoBuilder()
                .title("Applciation Title")
                .description("This is a short description of the application. It lets your users know if they have come to the right place.")
                .termsOfServiceUrl("https://baardkrk.github.io")
                .contact(new Contact("The repo for the project", "https://github.com/baardkrk/bardnotes", null))
                .license("Super Strict Licence")
                .licenseUrl("https://opensource.org/licenses/super-strict-license")
                .build();
    }

    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        registry.addViewController("/api").setViewName("redirect:/swagger-ui.html");
    }
}
```


## Database
TBD
### H2
TBD
### Postgres
TBD
### Flyway
TBD

## SpringBoot Test
The first thing to know about test code is that it is *just as important as produciton code*. It requires the same attention to detail, and the same amount of maintenance, and needs to be kept just as *clean* as the production code. The way to keep tests clean is to make them **readable**. This means following clean-code principles like in production code: A function does only *one* thing without consequences, giving meaningful names to variables and fuctions, and all the other goodness.  
Some guidelines will argue that there should only be one assert per test. However, I'm more a fan of the school where a test should only cover one *concept*. You should try to keep the tests to have a single assert, but not be afraid to add more asserts if they test the same concept.


There are mainly two types of tests we write for an application. A unit test, and an integration test. Integration tests usually test the whole application, from endpoint to return. Unit tests test a *unit* of code. If you're following the principle of Test Driven Development (TDD), you're usually writing Unit Tests. A rule in TDD is that it is not allowed to write *any* produciton code until you've written a failing test. When a failing test is written, it is allowed to produce *just enough* production code to let the test pass.

Another point here is to test your boundaries independently. You can use learning tests to try out functionality in libraries you depend on. That way, if you substitute the library with a newer version, you can use the learning tests to see what functionality have changed.  

When writing tests for APIs you rely on a clean way is to write a "fake" version of the API which implements an interface *you* define (this is also sometimes called a test-double, by Martin Fowler. However, test-double is a wide term that can be used for dummy, fake, stub, spy, or mock). Then, an Adapter is written for the API wich also implements the same interface. That way, only the Adapter has to change if the API changes, as we talked about earlier in the beginning.

### Unit Tests
We'll use JUnit to run our tests, so we need to add it to our dependiencies:
```xml
<dependency>
	<groupId></groupId>
	<artifactId></artifactId>
	<scope>test</scope>
</dependency>
```
### Integration tests
To use the springrunner for tests, we need to add it to our dependencies:
```xml
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-test</artifactId>
	<scope>test</scope>
</dependency>
```
