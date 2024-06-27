FROM node:18 as keycloakify_jar_builder
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk && \
    apt-get install -y maven;
COPY ./package.json ./yarn.lock /opt/app/
WORKDIR /opt/app
RUN yarn install --frozen-lockfile
COPY . /opt/app/
RUN yarn build-keycloak-theme

FROM docker.io/bitnami/keycloak:24.0.5-debian-12-r0 as builder
WORKDIR /opt/bitnami/keycloak
COPY --from=keycloakify_jar_builder /opt/app/dist_keycloak/keycloak-theme-for-kc-25-and-above.jar /opt/bitnami/keycloak/providers/
RUN /opt/bitnami/keycloak/bin/kc.sh build

FROM docker.io/bitnami/keycloak:24.0.5-debian-12-r0
COPY --from=builder /opt/bitnami/keycloak /opt/bitnami/keycloak
ENV KC_HOSTNAME=localhost
ENTRYPOINT ["/opt/bitnami/keycloak/bin/kc.sh", "start-dev"]
