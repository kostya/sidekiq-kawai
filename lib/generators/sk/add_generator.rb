# for Rails 3
if Rails::VERSION::MAJOR >= 3

  module Sk
    class AddGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../templates", __FILE__)

      def add_files
        template "consumer.rb", "app/models/sidekiq/sk_#{file_path}.rb"
        template "spec.rb", "spec/models/sidekiq/sk_#{file_path}_spec.rb"
      end
    end
  end

end

# for Rails 2.3
if Rails::VERSION::MAJOR == 2

  class RqAddGenerator < Rails::Generator::NamedBase
    def manifest
      record do |m|
        m.template "consumer.rb", "app/models/bin/sk_#{file_path}.rb"
        m.template "spec.rb", "spec/models/bin/sk_#{file_path}_spec.rb"
      end
    end
  end

end
