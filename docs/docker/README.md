## Docker Image

Included in this repo is a Dockerfile that you can launch ASC node for trying it out. Docker images are available on `ghcr.io/axc-chain/asc`.

You can build the docker image with the following commands:

```bash
make docker
```

If your build machine has an ARM-based chip, like Apple silicon (M1), the image is built for `linux/arm64` by default. To build for `x86_64`, apply the --platform arg:

```bash
docker build --platform linux/amd64 -t axc-chain/asc -f Dockerfile .
```

Before start the docker, get a copy of the config.toml & genesis.json from the release: https://github.com/axc-chain/asc/releases, and make necessary modification. `config.toml` & `genesis.json` should be mounted into `/asc/config` inside the container. Assume `config.toml` & `genesis.json` are under `./config` in your current working directory, you can start your docker container with the following command:

```bash
docker run -v $(pwd)/config:/asc/config --rm --name asc -it axc-chain/asc
```

You can also use `ETHEREUM OPTIONS` to overwrite settings in the configuration file

```bash
docker run -v $(pwd)/config:/asc/config --rm --name asc -it axc-chain/asc --http.addr 0.0.0.0 --http.port 8545 --http.vhosts '*' --verbosity 3
```

If you need to open another shell, just do:

```bash
docker exec -it axc-chain/asc /bin/bash
```

We also provide a `docker-compose` file for local testing

To use the container in kubernetes, you can use a configmap or secret to mount the `config.toml` & `genesis.json` into the container

```bash
containers:
  - name: asc
    image: axc-chain/asc

    ports:
      - name: p2p
        containerPort: 30311
      - name: rpc
        containerPort: 8545
      - name: ws
        containerPort: 8546

    volumeMounts:
      - name: asc-config
        mountPath: /asc/config

  volumes:
    - name: asc-config
      configMap:
        name: cm-asc-config
```

Your configmap `asc-config` should look like this:

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: cm-asc-config
data:
  config.toml: |
    ...

  genesis.json: |
    ...

```
