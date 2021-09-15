# PSF - PuppetServer Foreman

PSF aims to bring Foreman integration to Puppetserver. The core design is that it uses a client-server model over unix sockets. The logic on the Puppetserver side should be as small as possible. There can also be multiple server implementations, depending on the Foreman integration.

## Installation

Installation is only tested on EL8. Systemd on EL7 is too old to support DynamicUser=yes which decreases security.

First install & configure PSF:

```bash
dnf install -y epel-release https://yum.puppet.com/puppet7-release-el-8.noarch.rpm

dnf localinstall ~/psf-0.1.0-1.el8.noarch.rpm
# Edit /etc/psf/credentials
# Edit /etc/psf/ca.pem
systemctl enable --now puppetserver-foreman@{enc,facts,report}.socket
```

Then install & configure puppetserver. You may need to run `. /etc/profile.d/puppet-agent.sh` if it's in the same shell.

```
puppet config set --section server node_terminus exec
puppet config set --section server external_nodes "/usr/bin/psf enc"
puppet config set --section server reports psf
cat <<EOF > /etc/puppetlabs/puppet/routes.yaml
---
server:
  facts:
    terminus: psf
EOF
puppetserver ca setup
systemctl enable --now puppetserver
```

To test it, the local system can be configured to run & report:

```bash
puppet config set server $HOSTNAME
systemctl enable --now puppet
```

## Building the RPM

```bash
VERSION=0.1.0
git archive --prefix=psf-$VERSION/ -o psf-$VERSION.tar.gz HEAD
rpmbuild -bs --define "_sourcedir $PWD" --define "_srcrpmdir $PWD" psf.spec
mock -r centos-8-x86_64 psf-$VERSION-1.*.src.rpm
```

Now you'll find the result in `/var/lib/mock/centos-8-x86_64/result`.
