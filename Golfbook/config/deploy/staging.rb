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
set :domain, 'golfbookdev.agilisto.com'
set :smf_process_user, '993440e2'
set :smf_process_group, '993440e2'

# Settings to make app run from ./Golfbook ##############################################################
#set :repository_cache, "cached-copy" #/Golfbook"   #this will hopefully make the repo copy to cacehd-copy but the copy process copy from cached-copy/Golfbook, alternatively it will make the repo deploy to shared/cached-copy/Golfbook leaving ./Golfbook from there...
#########################################################################################################


# comment out if it gives you trouble. newest net/ssh needs this set.
ssh_options[:paranoid] = false
ssh_options[:forward_agent] = true

role :app, domain
role :web, domain
role :db,  domain, :primary => true

set :server_name, 'golfbookdev.agilisto.com'
#set :server_name, key_name + ".joyent.us"
#set :server_alias, "*." + key_name + ".joyent.us"

task :tail_log, :roles => :app do
    stream "tail -f #{shared_path}/log/staging.log"
end

after :deploy, 'deploy:cleanup'