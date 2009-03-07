namespace :ukcompanies do

  desc "Import companies from the companies yml file"
  task :import_companies => :environment do
    companies = YAML.load(open(File.join(RAILS_ROOT, 'companies.yml')))
    companies.each { |c| Company.create(c) }
  end

  desc "Import lobbyist_clients from the lobbyist_clients yml file"
  task :import_lobbyist_clients => :environment do
    LobbyistClient.load_from_file
  end

  desc "Import ogc_suppliers from the ogc_suppliers yml file"
  task :import_ogc_suppliers => :environment do
    OgcSupplier.load_from_file
  end
  
  task :match_names_to_checksure => :environment do
    names = LobbyistClient.find(:all).map { |c| c.name.downcase }
    names += OgcSupplier.find(:all).map { |c| c.name.downcase }
    names = names.uniq.sort
    p names
    
    names.each do |name|
      begin
        hash = Checksure.search_by_name(name)
      rescue => e
        p e
        next
      end
      sleep 1
      next if hash.nil?
      p hash
      Company.create(hash)
    end
  end

end
