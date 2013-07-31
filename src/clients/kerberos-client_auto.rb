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

# File:	clients/kerberos-client_auto.ycp
# Package:	Configuration of kerberos-client
# Summary:	Client for autoinstallation
# Authors:	Jiri Suchomel <jsuchome@suse.cz>
#
# $Id$
#
# This is a client for autoinstallation. It takes its arguments,
# goes through the configuration and return the setting.
# Does not do any changes to the configuration.

# @param first a map of kerberos-client settings
# @return [Hash] edited settings or an empty map if canceled
# @example map mm = $[ "FAIL_DELAY" : "77" ];
# @example map ret = WFM::CallModule ("kerberos-client_auto", [ mm ]);
module Yast
  class KerberosClientAutoClient < Client
    def main
      Yast.import "UI"

      textdomain "kerberos"

      Builtins.y2milestone("----------------------------------------")
      Builtins.y2milestone("Kerberos-client auto started")

      Yast.import "Kerberos"
      Yast.include self, "kerberos-client/wizards.rb"

      @ret = nil
      @func = ""
      @param = {}

      # Check arguments
      if Ops.greater_than(Builtins.size(WFM.Args), 0) &&
          Ops.is_string?(WFM.Args(0))
        @func = Convert.to_string(WFM.Args(0))
        if Ops.greater_than(Builtins.size(WFM.Args), 1) &&
            Ops.is_map?(WFM.Args(1))
          @param = Convert.to_map(WFM.Args(1))
        end
      end
      Builtins.y2debug("func=%1", @func)
      Builtins.y2debug("param=%1", @param)


      # create a  summary
      if @func == "Import"
        @ret = Kerberos.Import(@param)
      # create a  summary
      elsif @func == "Summary"
        @ret = Ops.get_string(Kerberos.Summary, 0, "")
      # ShortSummary is used by Users module
      elsif @func == "ShortSummary"
        @ret = Kerberos.ShortSummary
      elsif @func == "Reset"
        Kerberos.Import({})
        Kerberos.modified = false
        @ret = {}
      elsif @func == "Change"
        @ret = KerberosAutoSequence()
      elsif @func == "Read"
        @ret = Kerberos.Read
      elsif @func == "Export"
        @ret = Kerberos.Export
      elsif @func == "Write"
        Yast.import "Progress"
        Kerberos.write_only = true
        @progress_orig = Progress.set(false)
        @ret = Kerberos.Write
        Progress.set(@progress_orig)
      elsif @func == "Packages"
        @ret = Kerberos.AutoPackages
      # Return if configuration  was changed
      # return boolean
      elsif @func == "GetModified"
        @ret = Kerberos.Modified
      # Set modified flag
      # return boolean
      elsif @func == "SetModified"
        Kerberos.modified = true
        @ret = true
      else
        Builtins.y2error("unknown function: %1", @func)
        @ret = false
      end

      Builtins.y2debug("ret=%1", @ret)
      Builtins.y2milestone("Kerberos-client auto finished")
      Builtins.y2milestone("----------------------------------------")

      deep_copy(@ret) 

      # EOF
    end
  end
end

Yast::KerberosClientAutoClient.new.main
