set :application, "Golfbook" #matches names used in smf_template.erb
set :rails_env, "production"

#set :repository,  "https://cap@code.agilisto.com:8443/svn/golfbook/trunk/Golfbook"

set :deploy_to, "/home/993440e2/web/#{application}"

# Replace XXXXXXXX with the username provided by Joyent in your welcome email.

set :key_name, 'gnpcqaaa' 
set :user, '993440e2'
set :password, 'p3nqu1n'
set :smf_process_user, 'root'
set :smf_process_group, 'root'
set :service_name, application
set :working_directory, "#{deploy_to}/current"
ssh_options[:paranoid] = false 

set :domain, 'golfbook.agilisto.com'
role :app, domain
role :web, domain
role :db,  domain, :primary => true

#set :server_name, key_name + ".joyent.us"
#set :server_alias, "*." + key_name + ".joyent.us"
set :server_name, 'golfbook.agilisto.com'

#####

# GitHub settings #######################################################################################
default_run_options[:pty] = true
set :repository, "git@github.com:agilisto/golfbook.git" #GitHub clone URL
set :scm, "git"
set :scm_passphrase, "p3nqu1n" #This is the passphrase for the ssh key on the server deployed to
set :branch, "master"
set :scm_verbose, true
set :deploy_via, :remote_cache
#########################################################################################################
#
# Settings to make app run from ./Golfbook ##############################################################
#_cset(:release_path)      { File.join(releases_path, release_name) }
#_cset(:current_release)   { File.join(releases_path, releases.last) }
#_cset(:previous_release)  { File.join(releases_path, releases[-2]) }
#set :repository_cache, "cached-copy/Golfbook"   #override copy_respository_cache in remote_cache.rb in capistrano. then this will not be necessary - otherwise first comment out, deploy:cold, then do with this.
#########################################################################################################

namespace :accelerator do
  task :setup_smf_and_vhost do
    puts "not creating vhost and smf on setup anymore."
  end
end

task :tail_log, :roles => :app do
    stream "tail -f #{shared_path}/log/production.log"
end

after :deploy, 'deploy:cleanup'
after 'deploy:cold', 'accelerator:create_passenger_vhost'
