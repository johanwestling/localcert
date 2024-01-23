# Localcert

When working with `containers` (e.g. Docker) we sometimes find ourself in need of serving a local development server over `https` on a custom domain (other than `https://localhost`). 

For a browser to see a connection to a container secure we will need a `rootCA` and a `leaf` certificate to sign all steps of the transfer.

`localcert` strive to automate the process of installing `rootCA` in your machines operative system and generate a `leaf` certificate for your local dev domain.

<br>

## Usage

1. Open terminal.
	
	> Windows users should use `WSL2` _(Windows Subsystem for Linux)_ for `localcert` script to function properly.

1. Change directory to your project directory:

	```bash
	cd /path/to/project/directory
	```

1. Download `localcert` script:
	
	```bash
	curl -fsSL "https://raw.githubusercontent.com/johanwestling/localcert/main/localcert?token=GHSAT0AAAAAACJTLOJPPBDHBEQIUCXKVHDEZNPMUMQ" -o localcert
	```

1. Add `.localcert` to your project `.gitignore` file.

1. Run `localcert` script:
	
	```bash
	./localcert name-of-cert domain.dev "*.domain.dev"
	```