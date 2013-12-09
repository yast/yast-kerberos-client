#
# spec file for package yast2-kerberos-client
#
# Copyright (c) 2013 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           yast2-kerberos-client
Version:        3.1.1
Release:        0

BuildRoot:      %{_tmppath}/%{name}-%{version}-build
Source0:        %{name}-%{version}.tar.bz2

Group:          System/YaST
License:        GPL-2.0
BuildRequires:	doxygen perl-XML-Writer update-desktop-files yast2 yast2-pam yast2-testsuite
BuildRequires:  yast2-devtools >= 3.0.6

# etc_krb5_conf.scr 
Requires:	yast2-pam >= 2.20.0

# Hostname::CurrentDomain, CurrentHostname
# Wizard::SetDesktopTitleAndIcon
Requires:	yast2 >= 2.21.22

BuildArchitectures:	noarch

Requires:       yast2-ruby-bindings >= 1.0.0

Summary:	YaST2 - Kerberos Client Configuration

%description
With this YaST2 module, you can configure a Kerberos client so that a
Kerberos server will be used for user authentication.

%prep
%setup -n %{name}-%{version}

%build
%yast_build

%install
%yast_install


%files
%defattr(-,root,root)
%{yast_clientdir}/kerberos.rb
%{yast_clientdir}/kerberos-client.rb
%{yast_clientdir}/kerberos-client_auto.rb
%{yast_moduledir}/Kerberos.rb
%{yast_desktopdir}/kerberos.desktop
%{yast_scrconfdir}/*.scr
%{yast_schemadir}/autoyast/rnc/kerberos.rnc
%dir %{yast_yncludedir}/kerberos-client
%{yast_yncludedir}/kerberos-client/dialogs.rb
%{yast_yncludedir}/kerberos-client/wizards.rb
%doc %{yast_docdir}
%doc COPYING
