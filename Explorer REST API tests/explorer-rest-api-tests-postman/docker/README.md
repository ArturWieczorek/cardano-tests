This is a `Dockerfile` of modified newman image - it adds a non root user so HTML reports genearted by running test collections are not created by `root` and it is possible to delete them - buildkite (CI) does not display any errors about failed attempts to remove old reports files anymore.

This Dockerfile was used to create image that was pushed to:
`https://hub.docker.com/r/arturwieczorek/newman/tags`
and is used by buildkite pipeline defined in `.buildkite` folder in this repository. 
Plugin used for running docker container in pipeline definition file requires agent v3.0 and above.
