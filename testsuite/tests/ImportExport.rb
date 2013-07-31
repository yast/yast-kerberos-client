# encoding: utf-8

#  Read.ycp
#  Test of Kerberos::Read function (whole read process, many config files)
#  Author:	Jiri Suchomel <jsuchome@suse.cz>
#  $Id$
module Yast
  class ImportExportClient < Client
    def main
      # testedfiles: Kerberos.ycp Pam.ycp
      Yast.import "Testsuite"
      Yast.import "Kerberos"


      @data = {
        "kerberos_client" => {
          "ExpertSettings"  => {},
          "clockskew"       => "300",
          "default_domain"  => "",
          "default_realm"   => "",
          "forwardable"     => true,
          "ignore_unknown"  => true,
          "kdc_server"      => "",
          "minimum_uid"     => "1",
          "proxiable"       => false,
          "renew_lifetime"  => "1d",
          "ssh_support"     => false,
          "ticket_lifetime" => "1d"
        },
        "pam_login"       => { "sssd" => false, "use_kerberos" => false }
      }

      Testsuite.Test(lambda { Kerberos.Import(@data) }, [], 0)

      Testsuite.Test(lambda { Kerberos.Export }, [], 0)

      Testsuite.Dump(Builtins.sformat("\nsssd: %1", Kerberos.sssd))

      Ops.set(@data, ["pam_login", "sssd"], true)

      Testsuite.Test(lambda { Kerberos.Import(@data) }, [], 0)

      Testsuite.Test(lambda { Kerberos.Export }, [], 0)

      Testsuite.Dump(Builtins.sformat("\nsssd: %1", Kerberos.sssd))

      nil
    end
  end
end

Yast::ImportExportClient.new.main
