# DevSecOps Workshops: CI & Express.js app build containerization

In this workshop, we're going to optimize the current CI pipeline in Github Actions. The current pipeline runs one job that we named `CI` (you can chekc the `.github/workflows/ci.yaml`), with four steps:

1. Checkout the latest code with the new changes.
2. Build a container image based on `node` version 8 (alpine), and adding to it all required application dependencies from the `package.json` file. We call this image `base-back`. You can check `base.Dockerfile`.
3. Run a simple docker build in which we use the previous image to move our application code so they can be served from there. You can check `Dockerfile`.
4. We test our web app from the last container image we built by running a MongoDB container, and running our container on port `3000` and using `curl localhost:3000`.

## Tasks:

The problem here is that these job steps always run and take some time. A viable solution would be to skip the second step if we already have a `base-back` image with all required dependencies that we saved during the previous job run. Dependencies are written in the `package.json` file. So only changes to that file should cause us to build a new `base-back` image.

We can detect changes to a file by running `sha1sum /path/to/file` to generate a hash, and compare it with an older hash. The hash string is a bit long and generally speaking we can just use the 15 first characters or so from each hash.

Before proceeding to build a `base-back` image in the first step, we can first check if we have an image named `<username>/base-back:<hash>` in our Docker Hub. We'll have to set up a `token` in our Docker Hub account, save it as a `secret` in our repository settings and move it to an `environment variable` in our workflow file. Assuming we've set up `DOCKER_TOKEN` as environment variable, `DOCKER_USER` as a variable with our Docker Hub user, `BACK_IMG_TAG` is the first 15 characters of our current `package.json` file `sha1sum` hash, and our image is named `base-back`, the following command can help us retrieve our image fron Docker Hub:

```bash
wget -O - --user $DOCKER_USER --password $DOCKER_TOKEN https://registry.hub.docker.com/v2/repositories/$DOCKER_USER/base-back/tags | { grep $BACK_IMG_TAG || true; }
```

The `|| true;` part at the end is used to prevent grep from returning a non zero return code and blocking the entire CI pipeline. This way, if grep succeeds, it will return a string containing information about the container we searched for, and if it fails it will return an empty string.

If that doesn't return anything, then we dont have that image with that tag in our Docker Hub and we can proceed to building it as usual. We'll have to use `docker login` and `docker logout` commands. In the second step, we can proceed to pulling the image `<username>/base-back:<hash>` and tagging it simply `base-back` so that the `Dockerfile` build works fine.

Another thing we can add at the end is to push the final resulting container to our Docker Hub (for example `<username>/back-app:latest`).

Clone this repository, host it as your own, in your Github account, then start working ;)
