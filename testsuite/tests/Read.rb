# encoding: utf-8

#  Read.ycp
#  Test of Kerberos::Read function (whole read process, many config files)
#  Author:	Jiri Suchomel <jsuchome@suse.cz>
#  $Id$
module Yast
  class ReadClient < Client
    def main
      # testedfiles: Kerberos.ycp Pam.ycp
      Yast.import "Testsuite"
      Yast.import "Kerberos"

      @READ = {
        "etc"       => {
          # /etc/krb5.conf
          "krb5_conf" => {
            "v" => {
              "libdefaults" => {
                "default_realm" => ["SUSE.CZ"],
                "clockskew"     => ["500"]
              },
              "SUSE.CZ"     => {
                "kdc"            => ["chimera.suse.cz", "kdc.suse.cz"],
                "admin_server"   => nil,
                "default_domain" => nil
              },
              "pam"         => {
                "minimum_uid"       => ["1"],
                "renew_lifetime"    => nil,
                "ticket_lifetime"   => nil,
                "forwardable"       => nil,
                "proxiable"         => nil,
                "use_authtok"       => nil,
                "keytab"            => nil,
                "ccache_dir"        => nil,
                "ccname_template"   => nil,
                "mappings"          => nil,
                "existing_ticket"   => ["true"],
                "external"          => ["false"],
                "validate"          => nil,
                "use_shmem"         => nil,
                "addressless"       => nil,
                "debug"             => nil,
                "debug_sensitive"   => nil,
                "initial_prompt"    => nil,
                "subsequent_prompt" => nil,
                "addressless"       => ["false"],
                "banner"            => ["haha"]
              },
              "pkinit"      => { "trusted_servers" => nil }
            }
          },
          # /etc/security/pam_*
          "security"  => {
            "section" => {
              "/etc/security/pam_unix2.conf"   => {},
              "/etc/security/pam_pwcheck.conf" => {}
            },
            "v"       => {
              "/etc/security/pam_unix2.conf" => {
                "passwd" => "nullok use_ldap",
                "auth"   => "nullok use_krb5"
              }
            }
          },
          # /etc/ssh/ssh_config
          "ssh"       => {
            "ssh_config" => {
              "s" => { "*" => {} },
              "v" => {
                "*" => {
                  "GSSAPIAuthentication"      => "yes",
                  "GSSAPIDelegateCredentials" => "yes"
                }
              }
            }
          },
          "sssd_conf" => {
            "v" => {
              "domain/default" => {
                "krb5_realm"              => "SUSE.DE",
                "krb5_server"              => nil,
                "krb5_ccachedir"          => nil,
                "krb5_ccname_template"    => nil,
                "krb5_keytab"             => nil,
                "krb5_renewable_lifetime" => nil,
                "krb5_lifetime"           => nil,
                "krb5_validate"           => nil
              }
            }
          }
        },
        "sysconfig" => { "openafs-client" => nil },
        "target"    => { "stat" => { 1 => 2 }, "string" => "" }
      }

      @EX = {
        "target" => {
          "bash"        => 0,
          "bash_output" => {
            # call of ypdomainname
            #		"stdout" : "suse.cz"
            # call of pam-config
            "stdout" => "password: "
          }
        }
      }

      Testsuite.Dump("==== reading... ============================")

      Testsuite.Test(lambda { Kerberos.Read }, [@READ, {}, @EX], 0)

      Testsuite.Dump("============================================")

      Testsuite.Dump(
        Builtins.sformat("kerberos used: %1", Kerberos.use_pam_krb)
      )

      Testsuite.Dump(
        Builtins.sformat("default realm: %1", Kerberos.default_realm)
      )
      Testsuite.Dump(Builtins.sformat("kdc: %1", Kerberos.kdc))

      Testsuite.Dump(
        Builtins.sformat("\nssh support: %1", Kerberos.ssh_support)
      )
      Testsuite.Dump("============================================")

      #    READ ["etc", "krb5_conf", "v", "libdefaults", "default_realm"]	= nil;
      Ops.set(@READ, ["target", "stat"], {})

      Testsuite.Dump("==== reading... ============================")

      Testsuite.Test(lambda { Kerberos.Read }, [@READ, {}, @EX], 0)

      Testsuite.Dump(
        Builtins.sformat("default realm: %1", Kerberos.default_realm)
      )

      Testsuite.Dump("============================================")

      nil
    end
  end
end

Yast::ReadClient.new.main
