namespace :solr do
  namespace :index do

    desc "Index all description records WITHOUT commiting changes to the index."
    task :description => :environment do
      puts "Desc: #{Atrium::Description.find(:all).inspect}"
      Atrium::Description.all.each do |desc|
        puts "Indexing Description ID:#{desc.id}"
        Blacklight.solr.add desc.as_solr
      end
    end

    desc "Index all description records AND commit changes to the index"
    task :all => :environment do
      Rake::Task['solr:index:description'].execute
      Rake::Task['solr:index:commit'].execute
      Rake::Task['solr:index:optimize'].execute
    end

    desc "Commit changes to solr index"
    task :commit => :environment do
      puts "Commiting Solr index."
      start = Time.now
      Blacklight.solr.commit
      puts "Commiting took #{Time.now - start}s"
    end

    desc "Optimize solr index"
    task :optimize => :environment do
      puts "Optimizing Solr index."
      start = Time.now
      Blacklight.solr.optimize
      puts "Optimization took #{Time.now - start}s"
    end

  end
end
