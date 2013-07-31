# encoding: utf-8

#  Write.ycp
#  Test of Kerberos::Write function
#  Author:	Jiri Suchomel <jsuchome@suse.cz>
#  $Id$
module Yast
  class WriteClient < Client
    def main
      # testedfiles: Kerberos.ycp Pam.ycp
      Yast.import "Testsuite"
      Yast.import "Kerberos"

      @READ = {
        "etc" => {
          # /etc/krb5.conf
          "krb5_conf" => {
            "s" => { "libdefaults" => {}, "SUSE.CZ" => {}, "pam" => {} }
          },
          # /etc/security/pam_*
          "security"  => {
            "section" => {
              "/etc/security/pam_unix2.conf"   => {},
              "/etc/security/pam_pwcheck.conf" => {}
            },
            "v"       => {
              "/etc/security/pam_unix2.conf" => {
                "password" => "nullok use_ldap use_krb5",
                "auth"     => "nullok use_krb5",
                "account"  => "use_krb5"
              }
            }
          }
        }
      }

      @WRITE = {}
      @EX = { "target" => { "bash_output" => { "stdout" => "" } } }

      Testsuite.Dump(
        "==== writing without any changes ================================="
      )

      Testsuite.Test(lambda { Kerberos.Write }, [{}, @WRITE, @EX], 0)

      Testsuite.Dump("==== pam enabled with krb5-ignore_unknown_principals=")

      Kerberos.pam_modified = true
      Kerberos.use_pam_krb = true
      Kerberos.ignore_unknown = true

      Testsuite.Test(lambda { Kerberos.Write }, [@READ, @WRITE, @EX], 0)

      Kerberos.pam_modified = false
      Kerberos.ignore_unknown = false

      Testsuite.Dump(
        "==== ssh modified (enabled) ======================================"
      )

      Kerberos.ssh_modified = true
      Kerberos.ssh_support = true

      Testsuite.Test(lambda { Kerberos.Write }, [{}, @WRITE, @EX], 0)

      Testsuite.Dump(
        "==== kerberos disabled, ssh support disabled, krb5.conf untouched="
      )

      Kerberos.pam_modified = true
      Kerberos.use_pam_krb = false
      Kerberos.ssh_support = false

      Testsuite.Test(lambda { Kerberos.Write }, [@READ, @WRITE, @EX], 0)

      Testsuite.Dump(
        "==== only krb5.conf modified ====================================="
      )
      Testsuite.Dump(
        "==== (all sections exist) ========================================"
      )

      Kerberos.pam_modified = false
      Kerberos.ssh_modified = false
      Kerberos.modified = true

      Kerberos.default_realm = "SUSE.CZ"
      Kerberos.kdc = "chimera.suse.cz"

      Testsuite.Test(lambda { Kerberos.Write }, [@READ, @WRITE, @EX], 0)

      Testsuite.Dump(
        "==== (pam section doesn't exist) ================================="
      )
      @READ = {
        "etc" => {
          "krb5_conf" => { "s" => { "libdefaults" => {}, "SUSE.CZ" => {} } }
        }
      }
      Kerberos.admin_server = "user_defined" # -> won't be written

      Testsuite.Test(lambda { Kerberos.Write }, [@READ, {}, @EX], 0)

      nil
    end
  end
end

Yast::WriteClient.new.main
