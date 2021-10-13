%define puppet_vendor_ruby /opt/puppetlabs/puppet/lib/ruby/vendor_ruby

Name:          psf
Version:       0.1.0
Release:       1%{?dist}
Summary:       Foreman integration for Puppetserver

License:       MIT
URL:           https://github.com/ekohl/psf
Source0:       https://codeload.github.com/ekohl/%{name}/tar.gz/%{version}#/%{name}-%{version}.tar.gz
BuildArch:     noarch

BuildRequires: python3-rpm-macros
BuildRequires: systemd-rpm-macros

# Client
Requires:      socat

# Server
Requires:      python%{python3_version}dist(pyyaml)
Requires:      python%{python3_version}dist(requests)
# This provides the puppet user which psfd@.socket uses
Requires:      puppetserver
# This provides the foreman-proxy user which psfd@.service uses
Requires:      foreman-proxy

%description
%{summary}

%prep
%autosetup

%build

%install
# Client
install -D -m 0755 client/psf.sh %{buildroot}%{_bindir}/psf

# Integration in puppetserver
install -D -m 0644 client/puppet-psf/lib/puppet/indirector/facts/psf.rb %{buildroot}%{puppet_vendor_ruby}/puppet/indirector/facts/psf.rb
install -D -m 0644 client/puppet-psf/lib/puppet/reports/psf.rb %{buildroot}%{puppet_vendor_ruby}/puppet/reports/psf.rb

# Server
install -D -m 0755 -t %{buildroot}%{_bindir} server/psfd
install -D -m 0644 -t %{buildroot}%{_unitdir} server/psfd@.{service,socket}
install -D -m 0600 -t %{buildroot}%{_sysconfdir}/psf server/credentials

%post
%systemd_post psfd@.socket psfd@.service

%preun
%systemd_preun psfd@.socket psfd@.service

%postun
%systemd_postun_with_restart psfd@.socket psfd@.service

%files
# Client
%{_bindir}/psf

# Integration in puppetserver
%{puppet_vendor_ruby}/puppet/indirector/facts/psf.rb
%{puppet_vendor_ruby}/puppet/reports/psf.rb

# Server
%{_bindir}/psfd
%{_unitdir}/psfd@.service
%{_unitdir}/psfd@.socket
%config(noreplace) %{_sysconfdir}/psf/credentials
