#!/bin/sh
java -cp $(echo lib/*.jar | tr ' ' ':') -jar build.jar