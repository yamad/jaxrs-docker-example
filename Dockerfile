FROM openjdk:jre-alpine

COPY target/forge-test-thorntail.jar /opt/forge-test-thorntail.jar

EXPOSE 8080
# preferIPv4Stack is needed to keep thorntail happy
ENTRYPOINT ["java", "-Djava.net.preferIPv4Stack=true", "-jar", "/opt/forge-test-thorntail.jar"]
