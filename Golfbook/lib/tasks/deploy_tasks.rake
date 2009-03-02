namespace :agilisto do
  desc 'do all the steps needed to deploy to staging or production'
  task :deploy_to_rails_env => :environment do
    if ['staging','production'].include?(RAILS_ENV)
      puts 'Deploying to ' + RAILS_ENV
      'rake agilisto:copy_appropriate_files'
      if RAILS_ENV == 'staging'
        `cap staging deploy:cold`
        `cap staging accelerator:create_smf`
        `cap staging accelerator:create_vhost`
        `cap staging accelerator:smf_restart`
      elsif RAILS_ENV == 'production'
        `cap production deploy:cold`
        `cap production accelerator:create_smf`
        `cap production accelerator:create_vhost`
        `cap production accelerator:smf_restart`
      end
    else
      puts 'dont know what to do with RAILS_ENV=' + RAILS_ENV
    end
  end

  desc 'do all the steps needed to deploy to staging or production for the first time'
  task :deploy_to_rails_env_first_time => :environment do
    if ['staging','production'].include?(RAILS_ENV)
      puts 'Deploying to ' + RAILS_ENV
      `rake agilisto:copy_appropriate_files`
      if RAILS_ENV == 'staging'
        `cap staging deploy:setup`
        `cap staging deploy:cold`
        `cap staging accelerator:create_smf`
        `cap staging accelerator:create_vhost`
        `cap staging accelerator:smf_restart`
      elsif RAILS_ENV == 'production'
        `cap production deploy:setup`
        `cap production deploy:cold`
        `cap production accelerator:create_smf`
        `cap production accelerator:create_vhost`
        `cap production accelerator:smf_restart`
      end
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
