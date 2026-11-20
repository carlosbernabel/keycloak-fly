# ==========================================================
# VALHALLA - KEYCLOAK DESDE RED HAT UBI 9.8
# Base limpia, sin Keycloak preinstalado
# Java 21
# ==========================================================

FROM registry.access.redhat.com/ubi9/ubi:9.8

LABEL maintainer="Carlos Bernabel Espinoza"
LABEL application="Keycloak"
LABEL base="Red Hat UBI 9.8"

# ----------------------------------------------------------
# VERSIONES
# ----------------------------------------------------------

ENV JAVA_HOME=/usr/lib/jvm/jre-21-openjdk
ENV KC_HOME=/opt/keycloak
ENV PATH="${KC_HOME}/bin:${JAVA_HOME}/bin:${PATH}"

# ----------------------------------------------------------
# INSTALACION DE DEPENDENCIAS
# ----------------------------------------------------------

USER 0

RUN dnf install -y \
    java-21-openjdk-headless \
    tar \
    gzip \
    unzip \
    shadow-utils \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# ----------------------------------------------------------
# USUARIO DE EJECUCION
# ----------------------------------------------------------

RUN useradd \
    --uid 1001 \
    --gid 0 \
    --home-dir /opt/keycloak \
    --shell /sbin/nologin \
    keycloak

# ----------------------------------------------------------
# INSTALACION DE KEYCLOAK
# ----------------------------------------------------------

WORKDIR /opt

RUN curl -fL \
    https://github.com/keycloak/keycloak/releases/download/26.8.2/keycloak-26.8.2.tar.gz -o keycloak-26.8.2.tar.gz

RUN tar -xzf keycloak-26.8.2.tar.gz --strip-components=1 -C /opt/keycloak;
RUN rm keycloak-26.8.2.tar.gz

RUN chown -R 1001:0 /opt/keycloak
RUN chmod -R g+rwX /opt/keycloak

# ----------------------------------------------------------
# CONFIGURACION KEYCLOAK
# ----------------------------------------------------------

ENV KC_DB=postgres
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# ----------------------------------------------------------
# COMPILACION OPTIMIZADA
# ----------------------------------------------------------

USER 1001

RUN /opt/keycloak/bin/kc.sh build

# ----------------------------------------------------------
# PUERTOS
# ----------------------------------------------------------

EXPOSE 8080
EXPOSE 9000

# ----------------------------------------------------------
# EJECUCION
# ----------------------------------------------------------

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

CMD ["start", "--optimized"]
