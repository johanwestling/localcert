# Localcert

Utility scripts for automating installation of rootCA and domain specific certificates for Windows, Mac and Linux.

1. Install a local rootCA:

	```bash
	./localcert --install
	```

1. Generate domain certificate:

	```bash
	./localcert "name" "*.mytestdomain.dev"
	```

1. Find the generated certificate (`name.pem`) and its key (`name-key.pem`) in `certificates` directory.

1. **Done**