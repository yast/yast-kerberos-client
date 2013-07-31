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

# File:	include/kerberos-client/dialogs.ycp
# Package:	Configuration of kerberos-client
# Summary:	Dialogs definitions
# Authors:	Jiri Suchomel <jsuchome@suse.cz>
#
# $Id$
module Yast
  module KerberosClientDialogsInclude
    def initialize_kerberos_client_dialogs(include_target)
      Yast.import "UI"

      textdomain "kerberos"

      Yast.import "Address"
      Yast.import "CWM"
      Yast.import "CWMTab"
      Yast.import "IP"
      Yast.import "Kerberos"
      Yast.import "Label"
      Yast.import "Mode"
      Yast.import "Package"
      Yast.import "Popup"
      Yast.import "Report"
      Yast.import "Stage"
      Yast.import "String"
      Yast.import "Wizard"

      # map of current expert settings
      @ExpertSettings = {}

      @text_mode = false

      @widget_description = {
        # ---------------- widgtes for ("main") tab
        "ticket_lifetime"    => {
          "widget"            => :textentry,
          # textentry label
          "label"             => _("&Default Lifetime"),
          # help text (do not transl. values "m","h", "d")
          "help"              => _(
            "<p>By default, the time unit of <b>Default Lifetime</b>, <b>Default Renewable Lifetime</b>, and <b>Clock Skew</b> is set to seconds. Alternatively, specify the time unit (<tt>m</tt> for minutes, <tt>h</tt> for hours, or <tt>d</tt> for days) and use it as a value suffix, as in <tt>1d</tt> or <tt>24h</tt> for one day.</p>"
          ),
          "init"              => fun_ref(
            method(:InitDescription),
            "void (string)"
          ),
          "store"             => fun_ref(
            method(:StoreDescription),
            "void (string, map)"
          ),
          "handle"            => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          ),
          "validate_type"     => :function,
          "validate_function" => fun_ref(
            method(:ValidateTimeEntries),
            "boolean (string, map)"
          ),
          "valid_chars"       => Ops.add(String.CDigit, "dmh")
        },
        "renew_lifetime"     => {
          "widget"            => :textentry,
          # textentry label
          "label"             => _(
            "De&fault Renewable Lifetime"
          ),
          "no_help"           => true,
          "init"              => fun_ref(
            method(:InitDescription),
            "void (string)"
          ),
          "store"             => fun_ref(
            method(:StoreDescription),
            "void (string, map)"
          ),
          "handle"            => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          ),
          "validate_type"     => :function,
          "validate_function" => fun_ref(
            method(:ValidateTimeEntries),
            "boolean (string, map)"
          ),
          "valid_chars"       => Ops.add(String.CDigit, "dmh")
        },
        "forwardable"        => {
          "widget" => :combobox,
          "opt"    => [:hstretch, :notify, :editable],
          # checkbox label
          "label"  => _("For&wardable"),
          # help text
          "help"   => _(
            "<p><b>Forwardable</b> lets you transfer your complete identity (TGT) to another machine. <b>Proxiable</b> only lets you transfer particular tickets. Select wheter the options should be applied to all PAM services, none of them or enter a list of services separated by spaces.</p>"
          ),
          "init"   => fun_ref(method(:InitCombo), "void (string)"),
          "store"  => fun_ref(method(:StoreDescription), "void (string, map)"),
          "handle" => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          )
        },
        "proxiable"          => {
          #	"widget"	: `checkbox,
          "widget"  => :combobox,
          "opt"     => [:hstretch, :notify, :editable],
          # checkbox label
          "label"   => _("&Proxiable"),
          "no_help" => true,
          "init"    => fun_ref(method(:InitCombo), "void (string)"),
          "store"   => fun_ref(method(:StoreDescription), "void (string, map)"),
          "handle"  => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          )
        },
        "retain_after_close" => {
          "widget" => :checkbox,
          # checkbox label
          "label"  => _("R&etained"),
          # help text
          "help"   => _(
            "<p>If <b>Retained</b> is enabled, a PAM module keeps the tickets after closing the session.</p>"
          ),
          "init"   => fun_ref(method(:InitCheckBox), "void (string)"),
          "store"  => fun_ref(method(:StoreDescription), "void (string, map)"),
          "handle" => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          )
        },
        "ssh_support"        => {
          "widget" => :checkbox,
          # checkbox label
          "label"  => _("Kerberos Support for Open&SSH Client"),
          # help text
          "help"   => _(
            "<p>To enable Kerberos support for your OpenSSH client, select <b>Kerberos Support for OpenSSH Client</b>. In this case, Kerberos tickets are used for user authentication on the SSH server.</p>"
          ),
          "init"   => fun_ref(method(:InitCheckBox), "void (string)"),
          "store"  => fun_ref(method(:StoreDescription), "void (string, map)"),
          "handle" => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          )
        },
        "ignore_unknown"     => {
          "widget" => :checkbox,
          # checkbox label
          "label"  => _("&Ignore Unknown Users"),
          # help text
          "help"   => _(
            "<p>Check <b>Ignore Unknown Users</b> to have Kerberos ignore authentication attempts by users it does not know.</p>"
          ),
          "init"   => fun_ref(method(:InitCheckBox), "void (string)"),
          "store"  => fun_ref(method(:StoreDescription), "void (string, map)"),
          "handle" => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          )
        },
        "minimum_uid"        => {
          "widget" => :intfield,
          "opt"    => [:hstretch],
          # intfield label
          "label"  => _("Minimum &UID"),
          # help text
          "help"   => _(
            "<p>When the <b>Minimum UID</b> is greater than 0, authentication attempts by users with UIDs below the specified number are ignored. This is useful for disabling Kerberos authentication for the system administrator root.</p>"
          ),
          "init"   => fun_ref(method(:InitDescription), "void (string)"),
          "store"  => fun_ref(method(:StoreDescription), "void (string, map)"),
          "handle" => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          )
        },
        "clockskew"          => {
          "widget"            => :textentry,
          # textentry label
          "label"             => _("C&lock Skew"),
          # help text
          "help"              => _(
            "<p>The <b>Clock Skew</b> is the tolerance for time stamps not exactly matching the host's system clock. The value is in seconds.</p>"
          ),
          "init"              => fun_ref(
            method(:InitDescription),
            "void (string)"
          ),
          "store"             => fun_ref(
            method(:StoreDescription),
            "void (string, map)"
          ),
          "handle"            => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          ),
          "validate_type"     => :function,
          "validate_function" => fun_ref(
            method(:ValidateTimeEntries),
            "boolean (string, map)"
          ),
          "valid_chars"       => Ops.add(String.CDigit, "dmh")
        },
        "ntp"                => {
          "widget" => :push_button,
          # push button label
          "label"  => _("&NTP Configuration..."),
          "help"   => _(
            "<p>\n" +
              "To synchronize your time with an NTP server, configure your computer\n" +
              "as an NTP client. Access the configuration with <b>NTP Configuration</b>.\n" +
              "</p>\n"
          ),
          "handle" => fun_ref(
            method(:HandleClientCallButton),
            "symbol (string, map)"
          )
        },
        "nss_client"         => {
          "widget" => :menu_button,
          # push button label
          "label"  => _("C&onfigure User Data"),
          # help text
          "help"   => _(
            "<p>To configure the source of user accounts, select the appropriate configuration module in <b>Configure User Data</b>.</p>"
          ),
          "items"  => [
            # menu item
            ["ldap", _("LDAP Client")],
            # menu item
            ["nis", _("NIS Client")]
          ],
          "handle" => fun_ref(
            method(:HandleClientCallButton),
            "symbol (string, map)"
          )
        },
        # ---------------- widgtes for Expert Pam Settings ("pam_expert") tab
        "ccache_dir"         => {
          "widget" => :textentry,
          # textentry label
          "label"  => _("Credential Cac&he Directory"),
          # help text for "Credential Cac&he Directory"
          "help"   => _(
            "<p>Specify the directory where to place credential cache files as <b>Credential Cache Directory</b>.</p>"
          ),
          "init"   => fun_ref(method(:InitDescription), "void (string)"),
          "store"  => fun_ref(method(:StoreDescription), "void (string, map)"),
          "handle" => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          )
        },
        "browse_ccache_dir"  => {
          "widget"  => :push_button,
          # push button label
          "label"   => _("&Browse..."),
          "no_help" => true,
          "handle"  => fun_ref(
            method(:HandleBrowseDirectory),
            "symbol (string, map)"
          )
        },
        "ccname_template"    => {
          "widget"  => :textentry,
          # textentry label
          "label"   => _("Credential Cache &Template"),
          # help text
          "help"    => _(
            "<p><b>Credential Cache Template</b> specifies the location in which to place the user's session-specific credential cache.</p>"
          ),
          "init"    => fun_ref(method(:InitDescription), "void (string)"),
          "store"   => fun_ref(method(:StoreDescription), "void (string, map)"),
          "handle"  => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          ),
          "no_help" => true
        },
        "keytab"             => {
          "widget" => :textentry,
          # textentry label
          "label"  => _("&Keytab File Location"),
          # help text
          "help"   => _(
            "<p>Specify the location of the file with the keys of principals in <b>Keytab File Location</b>.</p>"
          ),
          "init"   => fun_ref(method(:InitDescription), "void (string)"),
          "store"  => fun_ref(method(:StoreDescription), "void (string, map)"),
          "handle" => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          )
        },
        "browse_keytab"      => {
          "widget"  => :push_button,
          # push button label
          "label"   => _("Bro&wse..."),
          "no_help" => true,
          "handle"  => fun_ref(
            method(:HandleBrowseFile),
            "symbol (string, map)"
          )
        },
        "mappings"           => {
          "widget" => :textentry,
          # textentry label
          "label"  => _("&Mappings"),
          # help text
          "help"   => _(
            "<p>With <b>Mappings</b>, specify how the PAM module should derive the principal's name from the system user name.</p>"
          ),
          "init"   => fun_ref(method(:InitDescription), "void (string)"),
          "store"  => fun_ref(method(:StoreDescription), "void (string, map)"),
          "handle" => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          )
        },
        "banner"             => {
          "widget" => :textentry,
          # textentry label
          "label"  => _("Ba&nner"),
          # help text
          "help"   => _(
            "<p>The value of <b>Banner</b> is a text that should be shown before a password questions.</p>"
          ),
          "init"   => fun_ref(method(:InitDescription), "void (string)"),
          "store"  => fun_ref(method(:StoreDescription), "void (string, map)"),
          "handle" => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          )
        },
        # ---------------- widgets for Services tab
        "services_help"      => {
          "widget" => :empty,
          # generic help for Services tab
          "help"   => _(
            "<p>All settings in this dialog can be applied for all PAM services, no service or a specific list of services separated by commas.</p>"
          )
        },
        "addressless"        => {
          "widget" => :combobox,
          "opt"    => [:hstretch, :notify, :editable],
          # textentry label
          "label"  => _("Add&ressless Initial Tickets"),
          # help text
          "help"   => _(
            "<p>When <b>Addressless Initial Tickets</b> is set, initial tickets (TGT) with no address information are requested.</p>"
          ),
          "init"   => fun_ref(method(:InitCombo), "void (string)"),
          "store"  => fun_ref(method(:StoreDescription), "void (string, map)"),
          "handle" => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          )
        },
        "debug"              => {
          "widget" => :combobox,
          "opt"    => [:notify, :editable],
          # textentry label
          "label"  => _("&Debug"),
          # help text
          "help"   => _(
            "<p>Check <b>Debug</b> to turn on debugging for selected services via syslog.</p>"
          ),
          "init"   => fun_ref(method(:InitCombo), "void (string)"),
          "store"  => fun_ref(method(:StoreDescription), "void (string, map)"),
          "handle" => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          )
        },
        "debug_sensitive"    => {
          "widget" => :combobox,
          "opt"    => [:notify, :editable],
          # textentry label
          "label"  => _("&Sensitive Debug"),
          # help text
          "help"   => _(
            "<p><b>Sensitive Debug</b> turns  on  debugging  of  sensitive  information.</p>"
          ),
          "init"   => fun_ref(method(:InitCombo), "void (string)"),
          "store"  => fun_ref(method(:StoreDescription), "void (string, map)"),
          "handle" => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          )
        },
        "existing_ticket"    => {
          "widget" => :combobox,
          "opt"    => [:hstretch, :notify, :editable],
          # textentry label
          "label"  => _("Accept &Existing Ticket"),
          # help text
          "help"   => _(
            "<p>Check <b>Accept Existing Ticket</b> to tell PAM module to accept the presence of pre-existing Kerberos credentials as sufficient to authenticate the user.</p>"
          ),
          "init"   => fun_ref(method(:InitCombo), "void (string)"),
          "store"  => fun_ref(method(:StoreDescription), "void (string, map)"),
          "handle" => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          ),
          "items"  => []
        },
        "external"           => {
          "widget" => :combobox,
          "opt"    => [:hstretch, :notify, :editable],
          # textentry label
          "label"  => _("E&xternal Credentials"),
          # help text
          "help"   => _(
            "<p>List the services allowed to provide credentials in <b>External Credentials</b>.</p>"
          ),
          "init"   => fun_ref(method(:InitCombo), "void (string)"),
          "store"  => fun_ref(method(:StoreDescription), "void (string, map)"),
          "handle" => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          ),
          "items"  => []
        },
        "use_shmem"          => {
          "widget" => :combobox,
          "opt"    => [:hstretch, :notify, :editable],
          # textentry label
          "label"  => _("Use Shared Mem&ory"),
          # help text
          "help"   => _(
            "<p><b>Use Shared Memory</b> describes the services for which the shared memory is used during authentication.</p>"
          ),
          "init"   => fun_ref(method(:InitCombo), "void (string)"),
          "store"  => fun_ref(method(:StoreDescription), "void (string, map)"),
          "handle" => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          ),
          "items"  => []
        },
        "validate"           => {
          "widget" => :combobox,
          "opt"    => [:hstretch, :notify, :editable],
          # textentry label
          "label"  => _("&Validate Initial Ticket"),
          # help text
          "help"   => _(
            "<p>Select the services for which TGT should be validated by changing the value of <b>Validate Initial Ticket</b>."
          ),
          "init"   => fun_ref(method(:InitCombo), "void (string)"),
          "store"  => fun_ref(method(:StoreDescription), "void (string, map)"),
          "handle" => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          ),
          "items"  => []
        },
        "initial_prompt"     => {
          "widget" => :combobox,
          "opt"    => [:notify, :editable],
          # textentry label
          "label"  => _("&Initial Prompt"),
          # help text
          "help"   => _(
            "<p>With <b>Initial Prompt</b> checked, the PAM module asks for a password before the authentication attempt.</p>"
          ),
          "init"   => fun_ref(method(:InitCombo), "void (string)"),
          "store"  => fun_ref(method(:StoreDescription), "void (string, map)"),
          "handle" => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          )
        },
        "subsequent_prompt"  => {
          "widget" => :combobox,
          "opt"    => [:notify, :editable],
          # textentry label
          "label"  => _("Subsequent &Prompt"),
          # help text
          "help"   => _(
            "<p>If <b>Subsequent Prompt</b> is enabled, the PAM module may ask the user for a password, in case the previously-entered  password  was  somehow  insufficient for authentication.</p>"
          ),
          "init"   => fun_ref(method(:InitCombo), "void (string)"),
          "store"  => fun_ref(method(:StoreDescription), "void (string, map)"),
          "handle" => fun_ref(
            method(:HandleDescription),
            "symbol (string, map)"
          )
        }
      }
    end

    #*****************************************************************************
    # widget handlers
    #****************************************************************************

    # universal widget: initialize the string value of widget @param
    def InitDescription(id)
      val = Ops.get_string(@ExpertSettings, id, "")
      if id == "minimum_uid"
        UI.ChangeWidget(Id(id), :Value, Builtins.tointeger(val))
      else
        UI.ChangeWidget(Id(id), :Value, val)
      end

      nil
    end

    # store the string value of given widget
    def StoreDescription(key, event)
      event = deep_copy(event)
      if key == "minimum_uid"
        Ops.set(
          @ExpertSettings,
          key,
          Builtins.tostring(UI.QueryWidget(Id(key), :Value))
        )
      else
        Ops.set(@ExpertSettings, key, UI.QueryWidget(Id(key), :Value))
      end

      nil
    end

    # handler for general string-value widgets: store their value on exit/save
    def HandleDescription(key, event)
      event = deep_copy(event)
      # store the value on exiting
      StoreDescription(key, event) if Ops.get(event, "ID") == :next
      nil
    end

    # universal widget: initialize the string value of widget @param
    def InitCheckBox(id)
      UI.ChangeWidget(
        Id(id),
        :Value,
        Ops.get_boolean(@ExpertSettings, id, false)
      )

      nil
    end

    # handler for Configure User Data menubutton + NTP client button
    def HandleClientCallButton(key, event)
      event = deep_copy(event)
      _ID = Ops.get(event, "ID")
      if (key != "nss_client" ||
          Ops.get_string(event, "EventType", "") != "MenuEvent") &&
          (key != "ntp" || _ID != key)
        return nil
      end
      if _ID == "ldap" || _ID == "nis" || _ID == "ntp"
        if Package.Install(Builtins.sformat("yast2-%1-client", _ID))
          WFM.CallFunction(Ops.add(Convert.to_string(_ID), "-client"), [])
        end
      end
      nil
    end

    # Validation function for widgets with time values
    def ValidateTimeEntries(key, event)
      event = deep_copy(event)
      val = Convert.to_string(UI.QueryWidget(Id(key), :Value))
      return true if val == "" || Kerberos.ValidateTimeEntries(key, val)
      UI.SetFocus(Id(key))
      false
    end

    # universal handler for directory browsing
    def HandleBrowseDirectory(key, event)
      event = deep_copy(event)
      return nil if Ops.get(event, "ID") != key
      val = Builtins.substring(key, 7)
      current = Convert.to_string(UI.QueryWidget(Id(val), :Value))
      current = "" if current == nil
      # directory location popup label
      dir = UI.AskForExistingDirectory(current, _("Path to Directory"))
      if dir != nil
        UI.ChangeWidget(Id(val), :Value, dir)
        StoreDescription(val, {})
      end
      nil
    end

    # universal handler for looking up files
    def HandleBrowseFile(key, event)
      event = deep_copy(event)
      return nil if Ops.get(event, "ID") != key
      val = Builtins.substring(key, 7)
      current = Convert.to_string(UI.QueryWidget(Id(val), :Value))
      current = "" if current == nil
      # file location popup label
      dir = UI.AskForExistingFile(current, "", _("Path to File"))
      if dir != nil
        UI.ChangeWidget(Id(val), :Value, dir)
        StoreDescription(val, {})
      end
      nil
    end

    # initialize the value of combo box
    def InitCombo(id)
      value = Ops.get_string(@ExpertSettings, id, "")
      items = [
        # combo box item
        Item(Id("true"), _("All services"), "true" == value),
        # combo box item
        Item(Id("false"), _("No services"), "false" == value),
        # combo box item
        Item(Id(""), _("Not set"), value == "")
      ]
      if !Builtins.contains(["true", "false", ""], value)
        items = Builtins.add(items, Item(Id(value), value, true))
      end
      UI.ChangeWidget(Id(id), :Items, items)

      nil
    end

    #*****************************************************************************
    # end of widget handlers
    #****************************************************************************

    # The dialog that appears when the [Abort] button is pressed.
    # @return `abort if user really wants to abort, `back otherwise
    def ReallyAbort
      ret = Kerberos.Modified || Stage.cont ? Popup.ReallyAbort(true) : true

      if ret
        return :abort
      else
        return :back
      end
    end

    # Read settings dialog
    # @return `abort if aborted and `next otherwise
    def ReadDialog
      ret = Kerberos.Read

      if Kerberos.sssd
        # popup message
        Popup.Message(
          "System Security Services Daemon (SSSD) is configured.\n" +
            "It is in use for Kerberos authentication instead of pam_krb5.\n" +
            "\n" +
            "SSSD specific options can be configured in LDAP Client Configuration module."
        )
      end

      ret ? :next : :abort
    end

    # Write settings dialog
    # @return `abort if aborted and `next otherwise
    def WriteDialog
      # help text
      Wizard.RestoreHelp(_("Writing Kerberos client settings..."))
      ret = Kerberos.Write
      ret ? :next : :abort
    end

    # check the validity of the entered address
    # enhanced for setting the port number after colon
    def check_address(address)
      address_l = Builtins.splitstring(address, ":")
      if Builtins.size(address_l) == 1
        return Address.Check(address)
      elsif Builtins.size(address_l) == 2
        return Address.Check(Ops.get_string(address_l, 0, "")) &&
          Builtins.regexpmatch(Ops.get_string(address_l, 1, "0"), "^[0-9]+$")
      else
        return false
      end
    end

    # Dialog for configuring Kerberos client (values in /etc/krb5.conf)
    # @return dialog result
    def ConfigureDialog
      # help text 1/5
      help_text = _(
        "<p>\n" +
          "<b><big>Authentication with Kerberos</big></b><br>\n" +
          "The Kerberos client configuration updates your PAM settings to enable Kerberos authentication.  Your system needs access to a Kerberos server in the network for this to work.\n" +
          "</p>\n"
      ) +
        # help text 2/5
        _(
          "<p>\n" +
            "<b>Basic Client Settings</b>:\n" +
            "Enter your <b>Default Domain</b>, <b>Default Realm</b>, and the hostname or address of your Key Distribution Center (<b>KDC Server Address</b>). To specify more values for KDC, separate them by spaces.</p>"
        ) +
        # help text 3/5
        _(
          "<p>\nIt is common practice to use the domain name in uppercase as your default realm name, but you can select freely. If the realm is not available on the server, you cannot log in.  Ask your server administrator if you need more information.</p>\n"
        ) +
        # help text for Use DNS to acquire the configuration data at runtime
        _(
          "Check <b>Use DNS to Acquire the Configuration Data at Runtime</b> to let your client use the Kerberos authentication data provided by DNS. This option cannot be selected if the DNS server does not provide such data.</p>"
        ) +
        # help text 5/5
        _("<p>To configure more settings, click <b>Advanced Settings</b>.</p>")

      # during installation, star ldap is default value
      installation = Stage.cont && !Builtins.contains(WFM.Args, "from_users")
      default_realm = Kerberos.default_realm
      kdc = Kerberos.kdc
      default_domain = Kerberos.default_domain
      use_pam_krb = Kerberos.use_pam_krb || installation
      dns_used = Kerberos.dns_used
      dns_available = Kerberos.dns_available

      con = HBox(
        HSpacing(3),
        VBox(
          VSpacing(0.5),
          RadioButtonGroup(
            Id(:rd),
            Left(
              HVSquash(
                VBox(
                  # radio button label
                  Left(
                    RadioButton(
                      Id(:pamno),
                      Opt(:notify),
                      _("Do No&t Use Kerberos"),
                      !use_pam_krb
                    )
                  ),
                  # radio button label
                  Left(
                    RadioButton(
                      Id(:pamyes),
                      Opt(:notify),
                      _("&Use Kerberos"),
                      use_pam_krb
                    )
                  )
                )
              )
            )
          ),
          VSpacing(0.2),
          Left(
            HBox(
              HSpacing(2),
              CheckBox(
                Id(:dns),
                Opt(:notify),
                # checkbox label
                _("Use DN&S to acquire the configuration data at runtime"),
                dns_used
              )
            )
          ),
          VSpacing(),
          # frame label
          Frame(
            _("Basic Kerberos Settings"),
            HBox(
              HSpacing(0.5),
              VBox(
                VSpacing(0.5),
                HBox(
                  # textentry label
                  TextEntry(Id(:domain), _("Default &Domain"), default_domain),
                  # textentry label
                  TextEntry(Id(:realm), _("Default Real&m"), default_realm)
                ),
                # textentry label
                TextEntry(Id(:kdc), _("&KDC Server Address"), kdc),
                # infield label
                VSpacing(0.5)
              ),
              HSpacing(0.5)
            )
          ),
          VSpacing(0.6),
          # pushbutton label
          Right(PushButton(Id(:advanced), _("Ad&vanced Settings..."))),
          VSpacing(0.2)
        ),
        HSpacing(3)
      )

      Wizard.SetContentsButtons(
        # dialog title
        _("Kerberos Client Configuration"),
        con,
        help_text,
        Stage.cont ? Label.BackButton : Label.CancelButton,
        Stage.cont ? Label.NextButton : Label.OKButton
      )
      if Stage.cont
        Wizard.RestoreAbortButton
      else
        Wizard.HideAbortButton
      end

      UI.ChangeWidget(Id(:dns), :Enabled, dns_available && use_pam_krb)
      Builtins.foreach([:realm, :domain, :kdc, :advanced]) do |widget|
        UI.ChangeWidget(Id(widget), :Enabled, use_pam_krb)
        if widget != :advanced && use_pam_krb
          UI.ChangeWidget(Id(widget), :Enabled, !dns_used)
        end
      end

      result = nil
      begin
        result = Convert.to_symbol(UI.UserInput)

        if result == :pamyes || result == :pamno
          use_pam_krb = result == :pamyes
          Builtins.foreach([:realm, :domain, :kdc, :advanced]) do |widget|
            UI.ChangeWidget(Id(widget), :Enabled, use_pam_krb)
          end
          UI.ChangeWidget(Id(:dns), :Enabled, dns_available && use_pam_krb)
        end
        if result == :dns
          dns_used = Convert.to_boolean(UI.QueryWidget(Id(:dns), :Value))
          Builtins.foreach([:realm, :domain, :kdc]) do |widget|
            UI.ChangeWidget(Id(widget), :Enabled, !dns_used)
          end
          # fill the values with the ones provided by DNS...
          UI.ChangeWidget(Id(:realm), :Value, Kerberos.dns_default_realm)
          UI.ChangeWidget(Id(:kdc), :Value, Kerberos.dns_kdc)
        end

        if result == :next || result == :advanced
          default_realm = Convert.to_string(UI.QueryWidget(Id(:realm), :Value))
          default_domain = Convert.to_string(
            UI.QueryWidget(Id(:domain), :Value)
          )
          kdc = Convert.to_string(UI.QueryWidget(Id(:kdc), :Value))
          dns_used = Convert.to_boolean(UI.QueryWidget(Id(:dns), :Value))

          if use_pam_krb && default_realm == ""
            # error popup label
            Report.Error(_("Enter the default realm name."))
            UI.SetFocus(Id(:realm))
            result = :not_next
            next
          end

          if use_pam_krb && kdc == ""
            # error popup label
            Report.Error(_("Enter the address of the KDC server."))
            UI.SetFocus(Id(:kdc))
            result = :not_next
            next
          end
          if use_pam_krb
            kdcs = Builtins.splitstring(kdc, " \t")
            checked = true
            Builtins.foreach(kdcs) { |k| checked = checked && check_address(k) }
            if !checked
              # error popup label
              Report.Error(
                Ops.add(
                  _("The KDC server address is invalid.") + "\n\n",
                  Address.Valid4
                )
              )
              UI.SetFocus(Id(:kdc))
              result = :not_next
              next
            end
          end
        end
        if (result == :abort || result == :cancel || result == :back) &&
            ReallyAbort() != :abort
          result = :not_next
        end
        if result == :next && use_pam_krb
          if !Package.InstallAll(Kerberos.RequiredPackages)
            result = :not_next
            use_pam_krb = false
            UI.ChangeWidget(Id(:rd), :Value, :pamno)
            Builtins.foreach([:realm, :domain, :kdc, :advanced, :dns]) do |widget|
              UI.ChangeWidget(Id(widget), :Enabled, use_pam_krb)
            end
          end
        end
      end while !Builtins.contains([:back, :cancel, :abort, :next, :advanced], result)

      if result == :next || result == :advanced
        Kerberos.modified = true
        Kerberos.default_domain = default_domain
        Kerberos.default_realm = default_realm
        Kerberos.kdc = kdc
        Kerberos.dns_used = dns_used

        if use_pam_krb != Kerberos.use_pam_krb
          Kerberos.pam_modified = true
          Kerberos.use_pam_krb = use_pam_krb
        end
      end
      result
    end

    # description of tab layouts
    def get_tabs_descr
      {
        "main"       => {
          # tab header
          "header"       => _("PAM Settings"),
          "contents"     => Top(
            HBox(
              HSpacing(3),
              VBox(
                VSpacing(0.4),
                # frame label
                Frame(
                  _("Ticket Attributes"),
                  HBox(
                    HSpacing(0.5),
                    VBox(
                      VSpacing(0.4),
                      "ticket_lifetime",
                      "renew_lifetime",
                      HBox("forwardable", HSpacing(0.5), "proxiable"),
                      VSpacing(0.4)
                    ),
                    HSpacing(0.5)
                  )
                ),
                VSpacing(0.4),
                Left("ssh_support"),
                VSpacing(0.2),
                Left("ignore_unknown"),
                VSpacing(0.4),
                "minimum_uid",
                HBox("clockskew", VBox(Label(""), "ntp")),
                VSpacing(0.6),
                Left("nss_client")
              ),
              HSpacing(3)
            )
          ),
          "widget_names" => [
            "ticket_lifetime",
            "renew_lifetime",
            "forwardable",
            "proxiable",
            "ssh_support",
            "ignore_unknown",
            "minimum_uid",
            "clockskew",
            "ntp",
            "nss_client"
          ]
        },
        "pam_expert" => {
          # tab header
          "header"       => _("Expert PAM Settings"),
          "contents"     => HBox(
            HSpacing(2),
            VBox(
              VSpacing(0.4),
              HBox("keytab", VBox(Label(""), "browse_keytab")),
              HBox("ccache_dir", VBox(Label(""), "browse_ccache_dir")),
              "ccname_template",
              "mappings",
              "banner",
              VStretch()
            ),
            HSpacing(2)
          ),
          "widget_names" => [
            "keytab",
            "browse_keytab",
            "ccache_dir",
            "browse_ccache_dir",
            "ccname_template",
            "mappings",
            "banner"
          ]
        },
        "services"   => {
          # tab header
          "header"       => _("PAM Services"),
          "contents"     => HBox(
            HSpacing(2),
            VBox(
              "services_help",
              VSpacing(0.4),
              "addressless",
              # `VSpacing (0.4),
              # "existing_ticket",
              VSpacing(0.4),
              "external",
              VSpacing(0.4),
              "use_shmem",
              VSpacing(0.4),
              "validate",
              VSpacing(0.4),
              HBox(
                HWeight(1, "debug"),
                HSpacing(0.5),
                HWeight(1, "debug_sensitive")
              ),
              VSpacing(0.4),
              HBox(
                HWeight(1, "initial_prompt"),
                HSpacing(0.5),
                HWeight(1, "subsequent_prompt")
              ),
              VSpacing(0.4),
              VStretch()
            ),
            HSpacing(2)
          ),
          "widget_names" => [
            "services_help",
            "addressless",
            "external",
            "use_shmem",
            "validate",
            "debug",
            "debug_sensitive",
            "initial_prompt",
            "subsequent_prompt"
          ]
        },
        "realms"     => {
          # tab header
          "header"       => _("Realm Settings"),
          "contents"     => HBox(
            HSpacing(2),
            VBox(VSpacing(0.4), Empty(Opt(:hstretch, :vstretch))),
            HSpacing(2)
          ),
          "widget_names" => []
        }
      }
    end

    # Kerberos advanced configuration
    # @return dialog result
    def AdvancedDialog
      display_info = UI.GetDisplayInfo
      @text_mode = Ops.get_boolean(display_info, "TextMode", false)

      @ExpertSettings = Convert.convert(
        Builtins.union(
          Kerberos.ExpertSettings,
          {
            "minimum_uid"     => Kerberos.minimum_uid,
            "ticket_lifetime" => Kerberos.ticket_lifetime,
            "renew_lifetime"  => Kerberos.renew_lifetime,
            "forwardable"     => Kerberos.forwardable,
            "proxiable"       => Kerberos.proxiable,
            "ignore_unknown"  => Kerberos.ignore_unknown,
            "clockskew"       => Kerberos.clockskew,
            "ssh_support"     => Kerberos.ssh_support
          }
        ),
        :from => "map",
        :to   => "map <string, any>"
      )

      Ops.set(
        @widget_description,
        "tab",
        CWMTab.CreateWidget(
          {
            "tab_order"    => ["main", "pam_expert", "services"],
            "tabs"         => get_tabs_descr,
            "widget_descr" => @widget_description,
            "initial_tab"  => "main"
          }
        )
      )

      Wizard.SetContentsButtons(
        "",
        VBox(),
        "",
        Label.CancelButton,
        Label.OKButton
      )

      ret = CWM.ShowAndRun(
        {
          "widget_names" => ["tab"],
          "widget_descr" => @widget_description,
          "contents"     => VBox("tab"),
          # default dialog caption
          "caption"      => _(
            "Advanced Kerberos Client Configuration"
          ),
          "back_button"  => Label.CancelButton,
          "next_button"  => Label.OKButton,
          "abort_button" => nil
        }
      )
      Builtins.y2milestone("Returning %1", ret)
      if ret == :next
        Kerberos.minimum_uid = Ops.get_string(
          @ExpertSettings,
          "minimum_uid",
          "1"
        )
        Kerberos.ticket_lifetime = Ops.get_string(
          @ExpertSettings,
          "ticket_lifetime",
          "1d"
        )
        Kerberos.renew_lifetime = Ops.get_string(
          @ExpertSettings,
          "renew_lifetime",
          "1d"
        )
        Kerberos.clockskew = Ops.get_string(@ExpertSettings, "clockskew", "300")
        Kerberos.forwardable = Ops.get_string(
          @ExpertSettings,
          "forwardable",
          "false"
        )
        Kerberos.proxiable = Ops.get_string(
          @ExpertSettings,
          "proxiable",
          "false"
        )
        if Ops.get_boolean(@ExpertSettings, "ssh_support", false) !=
            Kerberos.ssh_support
          Kerberos.ssh_modified = true
          Kerberos.ssh_support = Ops.get_boolean(
            @ExpertSettings,
            "ssh_support",
            false
          )
        end
        if Ops.get_boolean(@ExpertSettings, "ignore_unknown", false) !=
            Kerberos.ignore_unknown
          Kerberos.pam_modified = true
          Kerberos.ignore_unknown = Ops.get_boolean(
            @ExpertSettings,
            "ignore_unknown",
            false
          )
        end
        # ssh_support, ignore_unknown are not from /etc/krb5.conf
        @ExpertSettings = Builtins.remove(@ExpertSettings, "ssh_support")
        Kerberos.ExpertSettings = Builtins.remove(
          @ExpertSettings,
          "ignore_unknown"
        )
      end
      ret
    end
  end
end
