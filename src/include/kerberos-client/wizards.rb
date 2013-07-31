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

# File:	include/kerberos-client/wizards.ycp
# Package:	Configuration of kerberos-client
# Summary:	Wizards definitions
# Authors:	Jiri Suchomel <jsuchome@suse.cz>
#
# $Id$
module Yast
  module KerberosClientWizardsInclude
    def initialize_kerberos_client_wizards(include_target)
      Yast.import "UI"

      textdomain "kerberos"

      Yast.import "Label"
      Yast.import "Popup"
      Yast.import "Sequencer"
      Yast.import "Stage"
      Yast.import "Wizard"


      Yast.include include_target, "kerberos-client/dialogs.rb"
    end

    # Main workflow of the kerberos-client configuration
    # @return sequence result
    def MainSequence
      aliases = { "configure" => lambda { ConfigureDialog() }, "advanced" => lambda(
      ) do
        AdvancedDialog()
      end }

      sequence = {
        "ws_start"  => "configure",
        "configure" => {
          :abort    => :abort,
          :cancel   => :abort,
          :advanced => "advanced",
          :next     => :next
        },
        "advanced"  => {
          :abort  => :abort,
          :cancel => :abort,
          :next   => "configure"
        }
      }

      ret = Sequencer.Run(aliases, sequence)
      ret
    end

    # Whole configuration of kerberos-client
    # @return sequence result
    def KerberosSequence
      aliases = {
        "read"  => [lambda { ReadDialog() }, true],
        "main"  => lambda { MainSequence() },
        "write" => [lambda { WriteDialog() }, true]
      }

      sequence = {
        "ws_start" => "read",
        "read"     => { :abort => :abort, :cancel => :abort, :next => "main" },
        "main"     => { :abort => :abort, :next => "write" },
        "write"    => { :abort => :abort, :cancel => :abort, :next => :next }
      }

      if Stage.cont
        Wizard.CreateDialog
      else
        Wizard.OpenNextBackDialog
        Wizard.HideAbortButton
      end
      Wizard.SetDesktopTitleAndIcon("kerberos")
      ret = Sequencer.Run(aliases, sequence)
      UI.CloseDialog

      ret
    end

    # Whole configuration of kerberos-client but without reading and writing.
    # For use with autoinstallation.
    # @return sequence result
    def KerberosAutoSequence
      # dialog caption
      caption = _("Kerberos Client Configuration")

      # label (init dialog)
      contents = Label(_("Initializing..."))

      Wizard.CreateDialog
      Wizard.SetDesktopTitleAndIcon("kerberos")
      Wizard.SetContentsButtons(
        caption,
        contents,
        "",
        Label.BackButton,
        Label.NextButton
      )

      ret = MainSequence()

      UI.CloseDialog
      ret
    end
  end
end
