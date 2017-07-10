This repo shows how to build Gradle projects with Docker, while taking advantage of things such as build caching and a relatively new Docker feature, [Multi-stage builds](https://docs.docker.com/engine/userguide/eng-image/multistage-build/).

The Dockerfile in this repo does the following, in this order:
* Creates a build container from the [Alpine Linux-based Gradle Docker image](https://hub.docker.com/_/gradle/).
* Sets up a build directory.
* Changes the Gradle home directory so that `docker build` caches dependencies until the project's Gradle files change.
* Copies in the project's Gradle scripts separately of the source code so that dependencies aren't redownloaded for every single source file change.
* Downloads the project's dependencies.
* Copies the source in and builds the project.

After the project is built:
* A new container is created specifically to host it, based off [OpenJDK's Alpine-based JRE 8 image](https://hub.docker.com/_/openjdk/).
* A new user is created inside the container so that the project doesn't run as root.
    * Even though Docker does a pretty good job at [isolating containers](https://docs.docker.com/engine/security/security/), it's probably a good idea to refrain from using root privileges unless necessary, just in case the worst happens and someone pulls out a nasty kernel exploit.
* A small launcher script (run.sh) is copied in. This script simply adds all the project's dependencies to the classpath at runtime and runs the project.
* The build output from container #1 is copied in, dependencies and all.
* run.sh is set as the launch command.

The output container is now built and ready to go.

In order for this to work, a few modifications to [`build.gradle`](build.gradle) needed to be made.
* A new task ("bundleWithDependencies") has been added to copy the project and dependency JARs to a given output directory.
* A `jar` section has been added so that the project is built into a JAR file. The output file name in this section needs to match the file name of the JAR in run.sh.
    * The main class attribute in this section also needs to be set to the main class of the project
* An empty task has been added. This exists solely to make Gradle download dependencies and exit afterwards, much like `npm install` or similar.

(Note: even though the project in this repo is written in Kotlin, the same concept works for Java projects.)
