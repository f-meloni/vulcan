require "vulcano/parsed_class"
require "vulcano/parsed_variable"

module Vulcano
  class CodableGenerator
    def generate_codable_file(json, destination_folder, className = nil)
      variables = []

      json.each do |key, value|
        parsed_object = parse_object(destination_folder, key, value)

        variables.push(parsed_object) unless parsed_object.nil?
      end

      name = className.nil? ? 'Generated' : className

      parsed_class = ParsedClass.new(name, variables)

      spec = Gem::Specification.find_by_name('vulcan')
      template = File.read("#{spec.gem_dir}/resources/TemplateFile.swift")

      renderer = ERB.new(template)
      result = renderer.result(parsed_class.class_binding)

      File.open("#{destination_folder}/#{name}.swift", 'w') { |f| f.write(result) }
    end

    def parse_object(destination_folder, key, value)
      return parse_object(destination_folder, key, value.first).array unless !value.is_a?(Array)

      if value.is_a?(Hash)
        generate_codable_file(value, destination_folder, class_name_from_key(key))
      end

      ParsedVariable.new(key, value)
    end

    def class_name_from_key(key)
      key.camel_case
    end
  end
end