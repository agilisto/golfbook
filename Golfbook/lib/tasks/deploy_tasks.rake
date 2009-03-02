namespace :agilisto do
  desc 'do all the steps needed to deploy to staging or production'
  task :deploy_to_rails_env => :environment do
    if ['staging','production'].include?(RAILS_ENV)
      puts 'Deploying to ' + RAILS_ENV
      cmd = "rake agilisto:copy_appropriate_files"
      exec cmd
      cmd = "cap #{RAILS_ENV} deploy:cold"  #deploys and runs necessary migrations.
      exec cmd
      cmd = "cap #{RAILS_ENV} accelerator:create_smf"  #creates the service for smf.
      exec cmd
      cmd = "cap #{RAILS_ENV} accelerator:create_vhost"  #creates the service for smf.
      exec cmd
      cmd = "cap #{RAILS_ENV} accelerator:smf_restart"  #creates the service for smf.
    else
      puts 'dont know what to do with RAILS_ENV=' + RAILS_ENV
    end
  end

  desc 'do all the steps needed to deploy to staging or production for the first time'
  task :deploy_to_rails_env_first_time => :environment do
    if ['staging','production'].include?(RAILS_ENV)
      puts 'Deploying to ' + RAILS_ENV
      cmd = "rake agilisto:copy_appropriate_files"
      exec cmd
      cmd = "cap #{RAILS_ENV} deploy:setup"  #deploys and runs necessary migrations.
      exec cmd
##This is happening in the accelerator task after deploy:setup now.
#      cmd = "cap #{RAILS_ENV} accelerator:chown_directory"  #deploys and runs necessary migrations.
#      exec cmd
      cmd = "cap #{RAILS_ENV} deploy:cold"  #deploys and runs necessary migrations.
      exec cmd
      cmd = "cap #{RAILS_ENV} accelerator:create_smf"  #creates the service for smf.
      exec cmd
      cmd = "cap #{RAILS_ENV} accelerator:create_vhost"  #creates the service for smf.
      exec cmd
      cmd = "cap #{RAILS_ENV} accelerator:smf_restart"  #creates the service for smf.
    else
      puts 'dont know what to do with RAILS_ENV=' + RAILS_ENV
    end
  end

  desc 'copy the appropriate deploy.rb file'
  task :copy_appropriate_files => :environment do
    puts 'copying files for ' + RAILS_ENV
    if RAILS_ENV == 'staging'
      `cp config/deploy.rb.staging config/deploy.rb`
      `cp config/mongrel_staging.yml config/mongrel_cluster.yml`
    elsif RAILS_ENV == 'production'
      `cp config/deploy.rb.production config/deploy.rb`
      `cp config/mongrel_production.yml config/mongrel_cluster.yml`
    else
      puts 'RAILS_ENV= something other than staging or production...? ' + RAILS_ENV
    end
  end
end
