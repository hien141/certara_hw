# app/Dockerfile
FROM alpine:3.19

RUN apk --no-cache add curl

WORKDIR /app

# We expect a standardized binary name passed during the build context step
COPY rest-backend ./rest-app
RUN chmod +x ./rest-app

EXPOSE 8080
USER 65534:65534

ENTRYPOINT ["./rest-app"]
