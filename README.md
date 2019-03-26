# Containerized Java REST Microservice Example

This mini-project is a minimal setup for deploying a REST service on the
Java Enterprise Edition platform.

The end result is a container that runs a trivial REST service running
on an embedded web server. The jargon version: The project builds a
[Docker](https://www.docker.com) container that runs a
[JAX-RS](https://jcp.org/en/jsr/detail?id=339)
[RESTful](https://en.wikipedia.org/wiki/Representational_state_transfer) web service using the [Thorntail](http://thorntail.io/) web server and a [Java 8 JDK](http://www.oracle.com/technetwork/java/javase/downloads/index.html).

I'm documenting the process here because it took a bit of work to understand
how to do, and I want to remember it. Maybe it will help you too.

## Build

To build the project, you will need the [Maven](https://maven.apache.org/)
build tool. [Docker](https://www.docker.com/) should be already running. Then
run,

    mvn clean install             # create the "fat jar"
    docker build -t rest-test .   # put fat jar into container

## Run/Usage

To run the container with the service exposed on `http://localhost:8080`,

    docker run -p 8080:8080 rest-test

Then visit `http://localhost:8080/greet` to get a trivial Hello, World
message.

## Description

Our goal is to create a container that runs a REST (micro-)service.

### Creating the REST service

The project uses [JBoss-Forge](https://forge.jboss.org/) to automatically
generate a skeleton for a REST service. Open the `forge` shell, then issue
something like,

    project-new --named rest-test
    rest-new-endpoint --named ...

This creates a new service using JAX-RS, the JavaEE REST specification.

### Embedded web server

Now we have to deploy the REST service.

#### The traditional web server technique (we don't do this)

One option would be to create a Docker container that holds a Java web server
(e.g.  [Jetty](http://www.eclipse.org/jetty/),
[GlassFish](https://javaee.github.io/glassfish/), or
[Wildfly](http://wildfly.org/)). Then, the REST service is packaged into a WAR
artifact, and the WAR is deployed inside the server.  For instance, with
Jetty, that would mean providing some `web.xml` configuration file and placing
the WAR into the special directory `webapps`. That would allow us to serve
several applications using one server.

#### The "fat JAR" technique

A modern alternative is to turn the process inside out, in a sense. Instead of
loading the application into a web server, we embed a minimal web server into
our application. The resulting "fat JAR" has everything needed, and so it is
trivially deployed. We just run it,

    java -jar rest-test-thorntail.jar

and the REST service starts. Take a look at the `Dockerfile` to get a sense of
how easy it is. We build the JAR, copy it into the container (that has just a
JDK), and then run the JAR. That's it.

Another benefit of this approach is that the web server that gets embedded
into the JAR is minimal. Just the parts of the server that are needed to run
the services.

#### Implementing the "fat JAR"

The "fat JAR" appears to have been pioneered by [Spring
Boot](https://projects.spring.io/spring-boot/), but the JavaEE-compliant
[Thorntail](http://thorntail.io/) does the same thing. We want a
JavaEE JAX-RS service, so we use Thorntail.

Again, we use JBoss-Forge to generate what we need. In this case, forge
generates a Maven configuration. From the `forge` shell, run

    # install the thorntail plugin
    addon-install-from-git --url https://github.com/forge/thorntail-addon.git

    # setup and install the minimal server config
    thorntail-setup
    thorntail-detect-fractions --depend --build

Finally, from a normal shell, run maven

    mvn clean install

This should create a fat JAR in the `targets` directory.

### Docker

(Note that a Docker daemon must be running for this section. On my Macbook, I
used [Docker for Mac](https://www.docker.com/docker-mac), which worked very
nicely)

Now that the JAR file is created, it's trivial to put the JAR into a Docker
container

    docker build -t <name> .

Don't miss the trailing period (`.`). I encourage you to look at the
`Dockerfile` and play around with it. Notice that the container we derive from
is holds just the Java JDK. We don't need anything else.

With a successfully built Docker container, just run it

    docker run -p 8080:8080 <name>

The server should start and the REST service is now available at
`http://localhost:8080/greet`. Don't expect much. The REST service doesn't
really do anything except prove that a real service could be deployed this
way.

## License

[BSD-3](https://opensource.org/licenses/BSD-3-Clause). See `LICENSE`
