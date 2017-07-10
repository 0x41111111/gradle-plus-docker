# This is the build container
FROM gradle:jdk8-alpine as gradle-host

# Create the build directory and set the permissions properly so that Gradle can actually generate the build output without crashing.
USER root
RUN mkdir -p /incoming
WORKDIR /incoming/
RUN chmod -R 0776 /incoming
RUN chown -R gradle /incoming

# Go back to the Gradle user, copy the build scripts in and resolve all necessary dependencies.
# This is done separately so editing the source code doesn't cause the dependencies to be redownloaded.
USER gradle

# Change the Gradle cache location so that dependencies are cached during builds
RUN mkdir -p /incoming/.cache
ENV GRADLE_USER_HOME=/incoming/.cache

ADD *.gradle /incoming/
ADD gradle/ /incoming/gradle
RUN gradle install --stacktrace

# Copy the source code in and build it
ADD src/ /incoming/src
RUN gradle bundleWithDependencies --stacktrace

# Everything should be built, move on to the runtime container

# This is the runtime container
FROM openjdk:jre-alpine as target
ARG RUNTIME_USER=server

# Create the user that will be used to run the product and set up the directory it'll reside in.
RUN addgroup -S -g 1001 ${RUNTIME_USER}
RUN mkdir /srv/rt
RUN adduser -D -S -H -G ${RUNTIME_USER} -u 1001 -s /bin/false -h /srv/rt ${RUNTIME_USER}
RUN chown -R ${RUNTIME_USER}:${RUNTIME_USER} /srv/rt

# Copy the launcher script in.
# This serves to ensure that all necessary dependencies end up on the classpath.
ADD run.sh /srv/rt/
RUN chmod +x /srv/rt/run.sh

# Switch to the runtime user and copy the product in.
USER $RUNTIME_USER
COPY --from=gradle-host /incoming/build/output/ /srv/rt/
WORKDIR /srv/rt

# Run the built product when the container launches
CMD "/srv/rt/run.sh"
