> [!WARNING]
> This is a work in progress, this `README.md` and script content can change at any time for testing purposes.

# Localcert

When working with `containers` (e.g. Docker) we sometimes find ourself in need of serving a local development server over `https` on a custom domain (other than `https://localhost`). 

For a browser to see a connection as "secure" we will need a `rootCA` and a `leaf` certificate to sign the transfer between the browser and container properly.

`localcert` strive to be a convenience script for the procedure of installing a `rootCA` and generating a `leaf` certificate for your local development domain.

<br>

## Generating ceritificates

1. Open a terminal.
	
	> Windows users should use `WSL2` _(Windows Subsystem for Linux)_ for `localcert` script to function properly.

1. Change directory to your project directory:

	```bash
	cd /path/to/project/directory
	```

1. Download `localcert` script:
	
	```bash
	curl -fsSL "https://raw.githubusercontent.com/johanwestling/localcert/main/localcert" -o localcert
	```

1. Add `.localcert` to your project `.gitignore` file.

	> The `.localcert` directory holds the `mkcert` binary and generated certificates.

1. Change `localcert` to be executable:
	
	```bash
	chmod +x localcert
	```
	
1. Generate project certificates:
	
	```bash
	./localcert project-name project-name.dev "*.project-name.dev"
	```

> [!IMPORTANT]
> The `localcert` script will prompt for `sudo` (account credentials) only when needed. The steps that requires `sudo` at the moment is:
> * Adding `rootCA` to `MacOS` keychain.
> * Running `update-ca-certificates` on `Linux`.
> * Copying `rootCA` from system directory.

<br>

## Using ceritificates

When you have [certificates generated](#generating-ceritificates) for your project you will need to include or volume them in to your project container(s) and configure your development server to use them.