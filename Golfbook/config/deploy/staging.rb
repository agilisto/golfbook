set :application, "GolfbookDev" #matches names used in smf_template.erb

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
#
#########################################################################################################
set :domain, 'golfbook.agilisto.com'
set :smf_process_user, 'root'
set :smf_process_group, 'root'


# comment out if it gives you trouble. newest net/ssh needs this set.
ssh_options[:paranoid] = false
ssh_options[:forward_agent] = true

role :app, domain
role :web, domain
role :db,  domain, :primary => true

set :server_name, key_name + ".joyent.us"
set :server_alias, "*." + key_name + ".joyent.us"

#no need to restart apache
deploy.task :restart do
    accelerator.smf_restart
#    accelerator.restart_apache
end
deploy.task :start do
    accelerator.smf_start
#    accelerator.restart_apache
end
deploy.task :stop do
    accelerator.smf_stop
#    accelerator.restart_apache
end

namespace :accelerator do
  task :create_vhost, :roles => :web do
    puts "not creating vhost for staging."
  end
end

task :tail_log, :roles => :app do
    stream "tail -f #{shared_path}/log/staging.log"
end

after :deploy, 'deploy:cleanup'