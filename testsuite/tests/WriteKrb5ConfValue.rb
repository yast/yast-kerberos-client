# encoding: utf-8

#  WriteKrb5ConfValue.ycp
#  Test of Kerberos::WriteKrb5ConfValue function
#  Author:	Jiri Suchomel <jsuchome@suse.cz>
#  $Id$
module Yast
  class WriteKrb5ConfValueClient < Client
    def main
      # testedfiles: Kerberos.ycp
      Yast.import "Testsuite"
      Yast.import "Kerberos"

      @p = path(".etc.krb5_conf.v.libdefaults.default_realm")

      Testsuite.Test(lambda { Kerberos.WriteKrb5ConfValue(@p, "SUSE") }, [
        {},
        {},
        {}
      ], 0)

      Testsuite.Test(lambda { Kerberos.WriteKrb5ConfValue(@p, "") }, [{}, {}, {}], 0)

      Testsuite.Test(lambda { Kerberos.WriteKrb5ConfValue(@p, nil) }, [
        {},
        {},
        {}
      ], 0)

      @p = path(".etc.krb5_conf.v.SUSE.kdc")
      Testsuite.Test(lambda do
        Kerberos.WriteKrb5ConfValues(@p, ["kdc.suse.cz", "kdc.suse.de"])
      end, [
        {},
        {},
        {}
      ], 0)

      Testsuite.Test(lambda do
        Kerberos.WriteKrb5ConfValuesAsString(@p, "kdc.suse.cz kdc.suse.de")
      end, [
        {},
        {},
        {}
      ], 0)

      nil
    end
  end
end

Yast::WriteKrb5ConfValueClient.new.main
