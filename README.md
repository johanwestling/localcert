> [!WARNING]
> This is a work in progress, this `README.md` and script content can change at any time for testing purposes.

# Localcert

When working with `containers` (e.g. Docker) we sometimes find ourself in need of serving a local development server over `https` on a custom domain (other than `https://localhost`). 

For a browser to see a connection as "secure" we will need a `rootCA` and a `leaf` certificate to sign the transfer between the browser and container properly.

`localcert` strive to be a convenience script for the procedure of installing a `rootCA` and generating a `leaf` certificate for your local development domain.

<br>

## Usage

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

	> `.localcert` is the directory where the certificates will be stored by default.

1. Generate project certificates:
	
	```bash
	./localcert project-name project-name.dev "*.project-name.dev"
	```