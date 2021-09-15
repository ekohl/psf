%define puppet_vendor_ruby /opt/puppetlabs/puppet/lib/ruby/vendor_ruby

Name:          psf
Version:       0.1.0
Release:       1%{?dist}
Summary:       Foreman integration for Puppetserver

License:       MIT
URL:           https://github.com/ekohl/puppetserver-foreman
Source0:       https://codeload.github.com/ekohl/%{name}/tar.gz/%{version}#/%{name}-%{version}.tar.gz
BuildArch:     noarch

BuildRequires: python3-rpm-macros
BuildRequires: systemd-rpm-macros

Requires:      python%{python3_version}dist(pyyaml)
Requires:      python%{python3_version}dist(requests)
Requires:      socat
Requires:      puppetserver

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
install -D -m 0755 -t %{buildroot}%{_bindir} server/direct/puppetserver-foreman
install -D -m 0644 -t %{buildroot}%{_unitdir} server/direct/puppetserver-foreman@.{service,socket}
install -D -m 0600 -t %{buildroot}%{_sysconfdir}/psf server/direct/credentials

%post
%systemd_post puppetserver-foreman@.socket puppetserver-foreman@.service

%preun
%systemd_preun puppetserver-foreman@.socket puppetserver-foreman@.service

%postun
%systemd_postun_with_restart puppetserver-foreman@.socket puppetserver-foreman@.service

%files
# Client
%{_bindir}/psf

# Integration in puppetserver
%{puppet_vendor_ruby}/puppet/indirector/facts/psf.rb
%{puppet_vendor_ruby}/puppet/reports/psf.rb

# Server
%{_bindir}/puppetserver-foreman
%{_unitdir}/puppetserver-foreman@.service
%{_unitdir}/puppetserver-foreman@.socket
%config(noreplace) %{_sysconfdir}/psf/credentials
