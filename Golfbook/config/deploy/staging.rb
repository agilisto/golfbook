set :application, "GolfbookDev" #matches names used in smf_template.erb
set :rails_env, "staging"

set :working_directory, "#{deploy_to}/current"
ssh_options[:paranoid] = false

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
set :domain, 'golfbookdev.agilisto.com'

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
after 'deploy:cold', 'accelerator:create_passenger_vhost'