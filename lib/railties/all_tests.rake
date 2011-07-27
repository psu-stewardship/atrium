namespace :atrium do
  begin
    require 'cucumber/rake/task'
    require 'rspec/core'
    require 'rspec/core/rake_task'

    desc "Run Atrium cucumber and rspec, with test solr"
    task :all_tests => ['atrium:spec:with_solr', 'atrium:cucumber:with_solr']
    
    namespace :all_tests do
      desc "Run Atrium rspec and cucumber tests with rcov"
      rm "atrium-coverage.data" if File.exist?("atrium-coverage.data")
      task :rcov => ['atrium:spec:rcov', 'atrium:cucumber:rcov']
    end
    
  rescue LoadError
    desc "Not available! (cucumber and rspec not avail)"
    task :all_tests do
      abort 'Not available. Both cucumber and rspec need to be installed to run atrium:all_tests'
    end
  end
end

