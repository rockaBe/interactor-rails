module Interactor
  class Generator < ::Rails::Generators::NamedBase
    def self.source_root
      File.expand_path("../templates", __FILE__)
    end

    def self.test_framework
      File.directory?("spec") ? :spec : :test
    end

    def generate
      template "#{self.class.generator_name}.erb", "app/interactors/#{file_name}.rb"
      template "#{self.class.generator_name}_#{self.class.test_framework}.erb", "#{self.class.test_framework}/interactors/#{file_name}_#{self.class.test_framework}.rb"
    end
  end
end
