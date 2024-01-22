# Localcert

When working with `containers` (e.g. Docker) we sometimes find ourself in need of serving a local development server over `https` on a custom domain (other than `https://localhost`). 

For a browser to see a connection to a container secure we will need a `rootCA` and a `leaf` certificate to sign all steps of the transfer.

`localcert` strive to automate the process of installing `rootCA` in your machines operative system and generate a `leaf` certificate for your local dev domain.

<br>

## Usage

**Generate certificates:**
```bash
./localcert my-certificate-name my.domain.dev "*.my.domain.dev"
```

> [!IMPORTANT]
> `MacOS` this prompt for your account password when reaching the  installation of generated `rootCA` as the `Keychain` do not allow it to be added without `sudo`.