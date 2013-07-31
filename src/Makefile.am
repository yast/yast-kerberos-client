# Sources for kerberos-client

module_DATA = \
  modules/Kerberos.rb

client_DATA = \
  clients/kerberos-client_auto.rb \
  clients/kerberos.rb \
  clients/kerberos-client.rb

yncludedir = @yncludedir@/kerberos-client
ynclude_DATA = \
  include/kerberos-client/wizards.rb \
  include/kerberos-client/dialogs.rb

scrconf_DATA = \
  scrconf/cfg_openafs-client.scr \
  scrconf/etc_ssh_ssh_config.scr \
  scrconf/etc_pam_pkcs11_conf.scr

schemafilesdir = $(schemadir)/autoyast/rnc
schemafiles_DATA = \
  autoyast-rnc/kerberos.rnc

desktop_DATA = \
  desktop/kerberos.desktop

EXTRA_DIST = $(module_DATA) $(client_DATA) $(ynclude_DATA) $(scrconf_DATA) $(schemafiles_DATA) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common