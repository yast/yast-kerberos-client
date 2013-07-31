# encoding: utf-8

#  ReadKrb5ConfValue.ycp
#  Test of Kerberos::ReadKrb5ConfValue function
#  Author:	Jiri Suchomel <jsuchome@suse.cz>
#  $Id$
module Yast
  class ReadKrb5ConfValueClient < Client
    def main
      # testedfiles: Kerberos.ycp
      Yast.import "Testsuite"
      Yast.import "Kerberos"

      @READ = {
        "etc" => {
          # /etc/krb5.conf
          "krb5_conf" => {
            "v" => {
              "libdefaults" => {
                "default_realm" => ["SUSE.CZ"],
                "clockskew"     => ["500"]
              },
              "SUSE.CZ"     => {
                "kdc"            => ["chimera.suse.cz"],
                "default_domain" => nil
              },
              "pam"         => { "ticket_lifetime" => nil },
              "SUSE.DE"     => nil
            }
          }
        }
      }

      @p = path(".etc.krb5_conf.v.libdefaults.default_realm")

      @realm = Convert.to_string(Testsuite.Test(lambda do
        Kerberos.ReadKrb5ConfValue(@p, "")
      end, [
        @READ,
        {},
        {}
      ], 0))

      @p = Builtins.add(Builtins.add(path(".etc.krb5_conf.v"), @realm), "kdc")

      Testsuite.Test(lambda { Kerberos.ReadKrb5ConfValue(@p, "test.suse.cz") }, [
        @READ,
        {},
        {}
      ], 0)

      @p = Builtins.add(
        Builtins.add(path(".etc.krb5_conf.v"), "SUSE.DE"),
        "kdc"
      )

      Testsuite.Test(lambda { Kerberos.ReadKrb5ConfValue(@p, "test.suse.de") }, [
        @READ,
        {},
        {}
      ], 0)

      @p = path(".etc.krb5_conf.v.pam.ticket_lifetime")

      Testsuite.Test(lambda { Kerberos.ReadKrb5ConfValue(@p, "1d") }, [
        @READ,
        {},
        {}
      ], 0)

      nil
    end
  end
end

Yast::ReadKrb5ConfValueClient.new.main
