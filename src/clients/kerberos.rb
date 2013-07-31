# encoding: utf-8

# ------------------------------------------------------------------------------
# Copyright (c) 2006-2012 Novell, Inc. All Rights Reserved.
#
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of version 2 of the GNU General Public License as published by the
# Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, contact Novell, Inc.
#
# To contact Novell about this file by physical or electronic mail, you may find
# current contact information at www.novell.com.
# ------------------------------------------------------------------------------

# File:	clients/kerberos.ycp
# Package:	Configuration of kerberos-client
# Summary:	Main file
# Authors:	Jiri Suchomel <jsuchome@suse.cz>
#
# $Id$
#
# Main file for kerberos-client configuration. Uses all other files.
module Yast
  class KerberosClient < Client
    def main
      Yast.import "UI"

      #**
      # <h3>Configuration of the kerberos-client</h3>

      textdomain "kerberos"

      # The main ()
      Builtins.y2milestone("----------------------------------------")
      Builtins.y2milestone("Kerberos-client module started")

      Yast.import "Kerberos"
      Yast.import "Wizard"
      Yast.import "Report"
      Yast.import "RichText"
      Yast.import "CommandLine"

      Yast.include self, "kerberos-client/wizards.rb"

      # is this proposal or not?
      @propose = false
      @args = WFM.Args
      if Ops.greater_than(Builtins.size(@args), 0)
        if Ops.is_path?(WFM.Args(0)) && WFM.Args(0) == path(".propose")
          Builtins.y2milestone("Using PROPOSE mode")
          @propose = true
        end
      end

      # main ui function
      @ret = nil

      # the command line description map
      @cmdline = {
        "id"         => "kerberos",
        # translators: command line help text for Kerberos client module
        "help"       => _(
          "Kerberos client configuration module"
        ),
        "guihandler" => fun_ref(method(:KerberosSequence), "symbol ()"),
        "initialize" => fun_ref(Kerberos.method(:Read), "boolean ()"),
        "finish"     => fun_ref(method(:KerberosWrite), "boolean ()"),
        "actions"    => {
          "pam"       => {
            "handler" => fun_ref(
              method(:KerberosEnableHandler),
              "boolean (map <string, string>)"
            ),
            # translators: command line help text for pam action
            "help"    => _(
              "Enable or disable Kerberos authentication"
            )
          },
          "summary"   => {
            "handler" => fun_ref(
              method(:KerberosSummaryHandler),
              "boolean (map)"
            ),
            # translators: command line help text for summary action
            "help"    => _(
              "Configuration summary of Kerberos client"
            )
          },
          "configure" => {
            "handler" => fun_ref(
              method(:KerberosChangeConfiguration),
              "boolean (map)"
            ),
            # translators: command line help text for configure action
            "help"    => _(
              "Change the global settings of Kerberos client"
            )
          }
        },
        "options"    => {
          "enable"            => {
            # translators: command line help text for pam enable option
            "help" => _(
              "Enable the service"
            )
          },
          "disable"           => {
            # translators: command line help text for pam disable option
            "help" => _(
              "Disable the service"
            )
          },
          "dns"               => {
            "help"     => _("Use DNS to acquire the configuration at runtime"),
            "type"     => "enum",
            "typespec" => ["yes", "no"]
          },
          "kdc"               => {
            # translators: command line help text for the kdc option
            "help" => _(
              "The Key Distribution Center (KDC) address"
            ),
            "type" => "string"
          },
          "domain"            => {
            # translators: command line help text for the domain option
            "help" => _(
              "Default domain"
            ),
            "type" => "string"
          },
          "realm"             => {
            # translators: command line help text for the realm option
            "help" => _(
              "Default realm"
            ),
            "type" => "string"
          },
          "minimum_uid"       => {
            # translators: command line help text for the minimum_uid option
            "help" => _(
              "Minimum UID used for Kerberos authentication"
            ),
            "type" => "string"
          },
          "clockskew"         => {
            # translators: command line help text for the clockskew option
            "help" => _(
              "Clock skew (in seconds)"
            ),
            "type" => "string"
          },
          "ticket_lifetime"   => {
            # help text for command line option
            "help" => _(
              "Default ticket lifetime"
            ),
            "type" => "string"
          },
          "renew_lifetime"    => {
            # help text for command line option
            "help" => _(
              "Default renewable lifetime"
            ),
            "type" => "string"
          },
          "forwardable"       => {
            # help text for command line option
            "help" => _(
              "Forwardable credentials"
            ),
            "type" => "string"
          },
          "proxiable"         => {
            # help text for command line option
            "help" => _(
              "Proxiable credentials"
            ),
            "type" => "string"
          },
          "keytab"            => {
            # help text for command line option
            "help" => _(
              "Keytab File Location"
            ),
            "type" => "string"
          },
          "ccache_dir"        => {
            # help text for command line option
            "help" => _(
              "Credential Cache Directory"
            ),
            "type" => "string"
          },
          "ccname_template"   => {
            # help text for command line option
            "help" => _(
              "Credential Cache Template"
            ),
            "type" => "string"
          },
          "mappings"          => {
            # help text for command line option
            "help" => _("Mappings"),
            "type" => "string"
          },
          "existing_ticket"   => {
            # help text for command line option
            "help" => _(
              "Accept Existing Ticket"
            ),
            "type" => "string"
          },
          "external"          => {
            # help text for command line option
            "help" => _(
              "External credentials"
            ),
            "type" => "string"
          },
          "validate"          => {
            # help text for command line option
            "help" => _(
              "Validate Initial Ticket"
            ),
            "type" => "string"
          },
          "use_shmem"         => {
            # help text for command line option
            "help" => _("Use Shared Memory"),
            "type" => "string"
          },
          "addressless"       => {
            # help text for command line option
            "help" => _(
              "Addressless Initial Tickets"
            ),
            "type" => "string"
          },
          "debug"             => {
            # help text for command line option
            "help" => _("Debug"),
            "type" => "string"
          },
          "debug_sensitive"   => {
            # help text for command line option
            "help" => _("Sensitive Debug"),
            "type" => "string"
          },
          "initial_prompt"    => {
            # help text for command line option
            "help" => _("Initial Prompt"),
            "type" => "string"
          },
          "subsequent_prompt" => {
            # help text for command line option
            "help" => _("Subsequent Prompt"),
            "type" => "string"
          },
          "ssh_support"       => {
            # help text for command line option
            "help"     => Builtins.deletechars(
              _("Kerberos Support for Open&SSH Client"),
              "&"
            ),
            "type"     => "enum",
            "typespec" => ["yes", "no"]
          },
          "ignore_unknown"    => {
            # help text for command line option
            "help"     => Builtins.deletechars(
              _("&Ignore Unknown Users"),
              "&"
            ),
            "type"     => "enum",
            "typespec" => ["yes", "no"]
          }
        },
        "mappings"   => {
          "pam"       => [
            "enable",
            "disable",
            "kdc",
            "domain",
            "realm",
            "minimum_uid",
            "clockskew",
            "ticket_lifetime",
            "renew_lifetime",
            "forwardable",
            "proxiable",
            "keytab",
            "ccache_dir",
            "ccname_template",
            "mappings",
            "existing_ticket",
            "external",
            "validate",
            "use_shmem",
            "addressless",
            "debug",
            "debug_sensitive",
            "initial_prompt",
            "subsequent_prompt",
            "dns",
            "ignore_unknown",
            "ssh_support"
          ],
          "summary"   => [],
          "configure" => [
            "kdc",
            "domain",
            "realm",
            "minimum_uid",
            "clockskew",
            "ticket_lifetime",
            "renew_lifetime",
            "forwardable",
            "proxiable",
            "keytab",
            "ccache_dir",
            "ccname_template",
            "mappings",
            "existing_ticket",
            "external",
            "validate",
            "use_shmem",
            "addressless",
            "debug",
            "debug_sensitive",
            "initial_prompt",
            "subsequent_prompt",
            "dns",
            "ignore_unknown",
            "ssh_support"
          ]
        }
      }

      # --------------------------------------------------------------------------

      if @propose
        @ret = KerberosAutoSequence()
      else
        @ret = CommandLine.Run(@cmdline)
      end

      Builtins.y2debug("ret == %1", @ret)

      # Finish
      Builtins.y2milestone("Kerberos-client module finished")
      Builtins.y2milestone("----------------------------------------")
      deep_copy(@ret) 

      # EOF
    end

    # --------------------------------------------------------------------------
    # --------------------------------- cmd-line handlers

    # Print summary of basic options
    # @return [Boolean] false
    def KerberosSummaryHandler(options)
      options = deep_copy(options)
      CommandLine.Print(
        RichText.Rich2Plain(Ops.add("<br>", Kerberos.ShortSummary))
      )
      false # do not call Write...
    end

    # Change basic configuration of Kerberos client (server, realm, domain)
    # @param [Hash] options  a list of parameters passed as args
    # @return [Boolean] true on success
    def KerberosChangeConfiguration(options)
      options = deep_copy(options)
      ret = false
      if Ops.get_string(options, "clockskew", "") != "" &&
          Ops.get_string(options, "clockskew", "") != Kerberos.clockskew
        value = Builtins.tointeger(Ops.get_string(options, "clockskew", ""))
        if value == nil || Ops.less_than(value, 0)
          # error: wrong input (probably string or negative integer)
          Report.Error(
            _("The value for clock skew must be a positive integer.")
          )
          return false
        end
        if !Kerberos.ValidateTimeEntries(
            "clockskew",
            Ops.get_string(options, "clockskew", "")
          )
          return false
        end
        Kerberos.clockskew = Ops.get_string(options, "clockskew", "")
        ret = true
      end
      if Ops.get(options, "kdc") != nil &&
          Ops.get_string(options, "kdc", "") != Kerberos.kdc
        Kerberos.kdc = Ops.get_string(options, "kdc", "")
        ret = true
      end
      if Ops.get(options, "domain") != nil &&
          Ops.get_string(options, "domain", "") != Kerberos.default_domain
        Kerberos.default_domain = Ops.get_string(options, "domain", "")
        ret = true
      end
      if Ops.get(options, "realm") != nil &&
          Ops.get_string(options, "realm", "") != Kerberos.default_realm
        Kerberos.default_realm = Ops.get_string(options, "realm", "")
        ret = true
      end
      if Ops.get_string(options, "minimum_uid", "") != "" &&
          Ops.get_string(options, "minimum_uid", "") != Kerberos.minimum_uid
        Kerberos.minimum_uid = Ops.get_string(options, "minimum_uid", "")
        ret = true
      end
      if Ops.get_string(options, "forwardable", "") != "" &&
          Ops.get_string(options, "forwardable", "") != Kerberos.forwardable
        Kerberos.forwardable = Ops.get_string(options, "forwardable", "")
        ret = true
      end
      if Ops.get_string(options, "proxiable", "") != "" &&
          Ops.get_string(options, "proxiable", "") != Kerberos.proxiable
        Kerberos.proxiable = Ops.get_string(options, "proxiable", "")
        ret = true
      end
      if Ops.get_string(options, "ticket_lifetime", "") != "" &&
          Ops.get_string(options, "ticket_lifetime", "") !=
            Kerberos.ticket_lifetime
        val = Ops.get_string(options, "ticket_lifetime", "")
        return false if !Kerberos.ValidateTimeEntries("ticket_lifetime", val)
        Kerberos.ticket_lifetime = val
        ret = true
      end
      if Ops.get_string(options, "renew_lifetime", "") != "" &&
          Ops.get_string(options, "renew_lifetime", "") !=
            Kerberos.renew_lifetime
        val = Ops.get_string(options, "renew_lifetime", "")
        return false if !Kerberos.ValidateTimeEntries("renew_lifetime", val)
        Kerberos.renew_lifetime = Ops.get_string(options, "renew_lifetime", "")
        ret = true
      end
      if Ops.get_string(options, "ignore_unknown", "") != ""
        ignore_unknown = Ops.get_string(options, "ignore_unknown", "") == "yes"
        if ignore_unknown != Kerberos.ignore_unknown
          Kerberos.ignore_unknown = ignore_unknown
          ret = true
        end
      end
      if Ops.get_string(options, "ssh_support", "") != ""
        ssh_support = Ops.get_string(options, "ssh_support", "") == "yes"
        if ssh_support != Kerberos.ssh_support
          Kerberos.ssh_support = ssh_support
          Kerberos.ssh_modified = true
          ret = true
        end
      end

      Builtins.foreach(
        [
          "keytab",
          "ccache_dir",
          "ccname_template",
          "mappings",
          "existing_ticket",
          "external",
          "validate",
          "use_shmem",
          "addressless",
          "debug",
          "debug_sensitive",
          "initial_prompt",
          "subsequent_prompt"
        ]
      ) do |expert_key|
        val = Ops.get_string(options, expert_key, "")
        if val != "" &&
            Ops.get_string(Kerberos.ExpertSettings, expert_key, "") != val
          Ops.set(Kerberos.ExpertSettings, expert_key, val)
          ret = true
        end
      end
      if Ops.get_string(options, "dns", "") != ""
        dns = Ops.get_string(options, "dns", "") == "yes"
        if dns != Kerberos.dns_used
          if dns && !Kerberos.dns_available
            Builtins.y2warning("DNS does not provide config, ignoring")
          else
            Kerberos.dns_used = true
            ret = true
          end
        end
      end

      Kerberos.modified = true if ret
      ret
    end

    # Enable or disable Kerberos authentication
    # @param [Hash{String => String}] options  a list of parameters passed as args
    # @return [Boolean] true on success
    def KerberosEnableHandler(options)
      options = deep_copy(options)
      # check the "command" to be present exactly once
      command = CommandLine.UniqueOption(options, ["enable", "disable"])
      return false if command == nil

      if Kerberos.use_pam_krb && command == "disable" ||
          !Kerberos.use_pam_krb && command == "enable"
        Kerberos.pam_modified = true
      end

      Kerberos.use_pam_krb = command == "enable"

      KerberosChangeConfiguration(options)
      Kerberos.modified || Kerberos.pam_modified
    end


    # Wrapper for writing Kerberos configuration
    def KerberosWrite
      return false if !Package.InstallAll(Kerberos.RequiredPackages)
      Kerberos.Write
    end
  end
end

Yast::KerberosClient.new.main
