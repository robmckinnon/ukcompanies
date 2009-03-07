desc "Import companies from the companies yml file"
task :import_companies => :environment do
  companies = YAML.load(open(File.join(RAILS_ROOT, 'companies.yml')))
  companies.each { |c| Company.create(c) }
end
