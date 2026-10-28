# ============================================================
# Ayora - image de production (Render, ou tout hebergeur Docker)
# Tomcat 10.1 + Java 17. L'application est servie sur /ayora/
# ============================================================

# --- Etape 1 : compilation des sources Java ---
FROM tomcat:10.1-jdk17-temurin AS build
WORKDIR /build
COPY src ./src
COPY WebContent ./WebContent
RUN mkdir -p WebContent/WEB-INF/classes \
 && find src -name '*.java' > sources.txt \
 && javac --release 17 -encoding UTF-8 -nowarn \
      -cp "/usr/local/tomcat/lib/*:WebContent/WEB-INF/lib/*" \
      -d WebContent/WEB-INF/classes @sources.txt \
 && (cd src && find . -type f ! -name '*.java' -exec cp --parents {} ../WebContent/WEB-INF/classes/ \;)

# --- Etape 2 : image finale (Tomcat + l'application) ---
FROM tomcat:10.1-jdk17-temurin
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /build/WebContent /usr/local/tomcat/webapps/ayora
# La racine du site (https://.../) redirige vers l'application (/ayora/)
RUN mkdir -p /usr/local/tomcat/webapps/ROOT \
 && printf '<!doctype html><meta charset="utf-8"><meta http-equiv="refresh" content="0; url=/ayora/"><title>Ayora</title><a href="/ayora/">Ayora</a>\n' \
    > /usr/local/tomcat/webapps/ROOT/index.html
# Memoire adaptee a une petite instance (512 Mo)
ENV JAVA_OPTS="-Xmx300m -XX:+UseSerialGC -Dfile.encoding=UTF-8"
EXPOSE 8080
CMD ["catalina.sh", "run"]
