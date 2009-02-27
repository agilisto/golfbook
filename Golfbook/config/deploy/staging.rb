set :application, "GolfbookDev" #matches names used in smf_template.erb

set :working_directory, "#{deploy_to}/current"
ssh_options[:paranoid] = false
set :rails_env, "staging"

#
# GitHub settings #######################################################################################
default_run_options[:pty] = true
set :repository, "git@github.com:agilisto/golfbook.git" #GitHub clone URL
set :scm, "git"
set :scm_passphrase, "p3nqu1n" #This is the passphrase for the ssh key on the server deployed to
set :branch, "master"
set :scm_verbose, true
set :deploy_via, :remote_cache


#########################################################################################################
set :domain, 'golfbook.agilisto.com'
set :smf_process_user, 'root'
set :smf_process_group, 'root'

# Settings to make app run from ./Golfbook ##############################################################
#_cset(:release_path)      { File.join(releases_path, release_name) }
#_cset(:current_release)   { File.join(releases_path, releases.last) }
#_cset(:previous_release)  { File.join(releases_path, releases[-2]) }
#set :repository_cache, "cached-copy/Golfbook"   #override copy_respository_cache in remote_cache.rb in capistrano. then this will not be necessary - otherwise first comment out, deploy:cold, then do with this.
#########################################################################################################



# comment out if it gives you trouble. newest net/ssh needs this set.
ssh_options[:paranoid] = false
#ssh_options[:forward_agent] = true

role :app, domain
role :web, domain
role :db,  domain, :primary => true

set :server_name, "golfbookdev.agilisto.com"
#set :server_alias, "*." + key_name + ".joyent.us"

namespace :accelerator do
  task :setup_smf_and_vhost do
    puts "not creating vhost and smf on setup anymore for staging."
  end
end

task :tail_log, :roles => :app do
    stream "tail -f #{shared_path}/log/staging.log"
end

after :deploy, 'deploy:cleanup'

module Capistrano
  module Deploy
    module Strategy

      # Implements the deployment strategy that keeps a cached checkout of
      # the source code on each remote server. Each deploy simply updates the
      # cached checkout, and then does a copy from the cached copy to the
      # final deployment location.
      class RemoteCache < Remote
        private


        def copy_repository_cache
            logger.trace "copying the cached version to #{configuration[:release_path]}"
            if copy_exclude.empty?
              run "cp -RPp #{repository_cache}/Golfbook #{configuration[:release_path]} && #{mark}"
            else
              exclusions = copy_exclude.map { |e| "--exclude=\"#{e}\"" }.join(' ')
              run "rsync -lrp #{exclusions} #{repository_cache}/Golfbook/* #{configuration[:release_path]} && #{mark}"
            end
          end

      end

    end
  end
end
