FROM maven:3.8.7-openjdk-18-slim AS build

RUN mkdir /app
COPY . /app
WORKDIR /app
RUN mvn package

FROM alpine:3.14 AS jmx_exporter
RUN wget https://github.com/prometheus/jmx_exporter/releases/download/1.1.0/jmx_prometheus_javaagent-1.1.0.jar -O /jmx_prometheus_javaagent.jar


# Minimal rintime image - only JRE
FROM gcr.io/distroless/java21-debian12 AS runtime
COPY --from=build /app/target/*.jar /app.jar
COPY --from=jmx_exporter /jmx_prometheus_javaagent.jar /jmx_prometheus_javaagent.jar
COPY --from=build /app/jmx-exporter.conf.yaml /config.yaml
ENTRYPOINT [ "java" ]
CMD [ "-javaagent:/jmx_prometheus_javaagent.jar=8081:/config.yaml", "-jar", "/app.jar", ">", "app.log" ]
