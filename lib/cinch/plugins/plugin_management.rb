# Only admins are allowed to use this plugin

module Cinch
  module Plugins
    class PluginManagement
      include Cinch::Plugin
      Prefix_str = "plugin"
      Load_str = "#{Prefix_str} load"
      Unload_str = "#{Prefix_str} unload"
      Reload_str = "#{Prefix_str} reload"
      Set_str = "#{Prefix_str} set"

      set :help, <<-HELP
INFO
  Only admins are allowed to use this plugin!~
ADMIN_ONLY
#{Load_str} <class_name> [file_base]
  Load a plugin
#{Unload_str} <class_name>
  Unload a plugin
#{Reload_str} <class_name> [file_base]
  Reload a plugin
#{Set_str} <class_name> <option> <value>
  Set plugin config options
      HELP

      hook :pre, method: :admin?
      def admin?(m)
        @bot.admin?(m.user)
      end

      match(/#{Load_str} (\S+)(?: (\S+))?/, method: :load_plugin)
      match(/#{Unload_str} (\S+)/, method: :unload_plugin)
      match(/#{Reload_str} (\S+)(?: (\S+))?/, method: :reload_plugin)
      match(/#{Set_str} (\S+) (\S+) (.+)$/, method: :set_option)
      def load_plugin(m, plugin, mapping)
        mapping ||= plugin.gsub(/(.)([A-Z])/) { |_|
          $1 + "_" + $2
        }.downcase # we downcase here to also catch the first letter

        file_name = "lib/cinch/plugins/#{mapping}.rb"
        unless File.exist?(file_name)
          m.reply "Could not load #{plugin} because #{file_name} does not exist."
          return
        end

        begin
          load(file_name)
        rescue
          m.reply "Could not load #{plugin}."
          raise
        end

        begin
          const = Cinch::Plugins.const_get(plugin)
        rescue NameError
          m.reply "Could not load #{plugin} because no matching class was found."
          return
        end

        @bot.plugins.register_plugin(const)
        m.reply "Successfully loaded #{plugin}"
      end

      def unload_plugin(m, plugin)
        begin
          plugin_class = Cinch::Plugins.const_get(plugin)
        rescue NameError
          m.reply "Could not unload #{plugin} because no matching class was found."
          return
        end

        @bot.plugins.select {|p| p.class == plugin_class}.each do |p|
          @bot.plugins.unregister_plugin(p)
        end

        ## FIXME not doing this at the moment because it'll break
        ## plugin options. This means, however, that reloading a
        ## plugin is relatively dirty: old methods will not be removed
        ## but only overwritten by new ones. You will also not be able
        ## to change a classes superclass this way.
        # Cinch::Plugins.__send__(:remove_const, plugin)

        # Because we're not completely removing the plugin class,
        # reset everything to the starting values.
        plugin_class.hooks.clear
        plugin_class.matchers.clear
        plugin_class.listeners.clear
        plugin_class.timers.clear
        plugin_class.ctcps.clear
        plugin_class.react_on = :message
        plugin_class.plugin_name = nil
        plugin_class.help = nil
        plugin_class.prefix = nil
        plugin_class.suffix = nil
        plugin_class.required_options.clear

        m.reply "Successfully unloaded #{plugin}"
      end

      def reload_plugin(m, plugin, mapping)
        unload_plugin(m, plugin)
        load_plugin(m, plugin, mapping)
      end

      def set_option(m, plugin, option, value)
        begin
          const = Cinch::Plugins.const_get(plugin)
        rescue NameError
          m.reply "Could not set plugin option for #{plugin} because no matching class was found."
          return
        end
        @bot.config.plugins.options[const][option.to_sym] = eval(value)
      end
    end
  end
end
