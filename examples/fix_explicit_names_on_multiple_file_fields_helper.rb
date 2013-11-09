# encoding: utf-8

# Patch for ActionView::Helpers#add_default_name_and_id
# and ActionView::Helpers#tag_name and tag_name_with_index
# If a file field tag is passed the multiple option, it is turned into an
# array field (appending "[]"), but if the file field is passed an
# explicit name as an option, leave the name alone (do not append "[]").
# Based on https://github.com/rmm5t/rails/commit/384331ca363c6cdfc5cfdcb9b955117b2912f0e8

# Always require all the classes you will be patching (or will need in order to patch) first
require 'rails/all'
if defined?(Rails) && Rails.version.to_s < '4.0'
  require 'active_support/all'
  require 'action_view/helpers'
  require 'action_view/helpers/form_helper'
end

# Change the following path to your rails app root directory...
app_root ||= File.expand_path(File.join(__FILE__, ['..']*4))
require 'pachinko'

class FixExplicitNamesOnMultipleFileFieldsPatch < Pachinko

  def name
    'Fix explicit names on multiple file fields'
  end

  RELEVANCY = ->{
    begin
      test_view_class = Class.new
      test_view_class.instance_eval do
        include ActionView::Helpers::FormHelper
      end
      test_view_instance = test_view_class.new
      test_view_instance.file_field("import", "file", multiple: true, name: "custom") == '<input id="import_file" multiple="multiple" name="custom[]" type="file" />'
    end
  }

  def relevant?
    ::Rails.version.to_s < '4.0' && RELEVANCY.call
  end

  patch do
    module ::ActionView
      module Helpers
        class InstanceTag
          raise "ActionView::Helpers::Tags::Base#add_default_name_and_id not already defined before its monkeypatch" unless (private_instance_methods(false) | instance_methods(false)).include?(:add_default_name_and_id)
          def add_default_name_and_id(options)
            if options.has_key?("index")
              options["name"] ||= options.fetch("name"){ tag_name_with_index(options["index"], options["multiple"]) }
              options["id"] = options.fetch("id"){ tag_id_with_index(options["index"]) }
              options.delete("index")
            elsif defined?(@auto_index)
              options["name"] ||= options.fetch("name"){ tag_name_with_index(@auto_index, options["multiple"]) }
              options["id"] = options.fetch("id"){ tag_id_with_index(@auto_index) }
            else
              options["name"] ||= options.fetch("name"){ tag_name(options["multiple"]) }
              options["id"] = options.fetch("id"){ tag_id }
            end

            options["id"] = [options.delete('namespace'), options["id"]].compact.join("_").presence
          end
          private :add_default_name_and_id
          raise "ActionView::Helpers::Tags::Base#tag_name not already defined before its monkeypatch" unless (private_instance_methods(false) | instance_methods(false)).include?(:tag_name)
          def tag_name(multiple = false)
            "#{@object_name}[#{sanitized_method_name}]#{"[]" if multiple}"
          end
          private :tag_name
          raise "ActionView::Helpers::Tags::Base#tag_name_with_index not already defined before its monkeypatch" unless (private_instance_methods(false) | instance_methods(false)).include?(:tag_name_with_index)
          def tag_name_with_index(index, multiple = false)
            "#{@object_name}[#{index}][#{sanitized_method_name}]#{"[]" if multiple}"
          end
          private :tag_name_with_index
        end
      end
    end
  end

end
FixExplicitNamesOnMultipleFileFieldsPatch.run(__FILE__==$PROGRAM_NAME)
