#
# Makefile.am for devtools/devtools/skeletons/config/src
#

yncludedir = @yncludedir@/kerberos-client

client_DATA =			\
	kerberos.ycp    	\
	kerberos-client.ycp 	\
	kerberos-client_auto.ycp

ynclude_DATA =			\
	wizards.ycp 		\
	dialogs.ycp

config_DATA =			\
	kerberos.y2cc

desktop_DATA =			\
	kerberos.desktop

module_DATA =			\
	Kerberos.ycp

EXTRA_DIST = $(client_DATA) $(config_DATA) $(module_DATA) $(ynclude_DATA) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common
