# for Rails 3
if Rails::VERSION::MAJOR >= 3

  module Sk
    class AddGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../templates", __FILE__)

      def add_files
        template "consumer.rb", "app/workers/sk_#{file_path}.rb"
        template "spec.rb", "spec/workers/sk_#{file_path}_spec.rb"
      end
    end
  end

end

# for Rails 2.3
if Rails::VERSION::MAJOR == 2

  class SkAddGenerator < Rails::Generator::NamedBase
    def manifest
      record do |m|
        m.template "consumer.rb", "app/workers/sk_#{file_path}.rb"
        m.template "spec.rb", "spec/workers/sk_#{file_path}_spec.rb"
      end
    end
  end

end
