# PSF - PuppetServer Foreman

PSF aims to bring Foreman integration to Puppetserver. The core design is that it uses a client-server model over unix sockets. The logic on the Puppetserver side should be as small as possible. There can also be multiple server implementations, depending on the Foreman integration.
