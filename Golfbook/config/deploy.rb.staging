##THIS IS THE STAGING DEPLOY.RB FILE

#Things to do before deploying to a specific environment.
#Copy the relevant mongrel_#{stage}.yml to mongrel_cluster.yml
#change the application name to 'GolfbookDev' for staging and 'Golfbook' for production.

require 'erb'
require 'config/accelerator/accelerator_tasks'

set :stages, %w(staging production)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

#For staging:
set :application, "GolfbookDev" #matches names used in smf_template.erb
#For production:
#set application, 'Golfbook'

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
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

set :domain, 'golfbookdev.agilisto.com'

# comment out if it gives you trouble. newest net/ssh needs this set.
#ssh_options[:paranoid] = false
#ssh_options[:forward_agent] = true


role :app, domain
role :web, domain
role :db,  domain, :primary => true

desc "create symlinks from rails dir into project"
task :create_sym do
    sudo "ln -nfs #{shared_path}/rails #{release_path}/vendor/rails"
    #sudo "ln -nfs #{deploy_to}/shared//uploaded_images #{release_path}/public//uploaded_images"
    #sudo "chown -R mongrel:www  #{deploy_to} "
    #sudo "chown -R mongrel:www  #{shared_path} "	
    #sudo "chmod 775  #{deploy_to} "
end

########################
#Deploy from suburl of main repo url
########################
desc 'Restructures current release directory and installs plugins'
task :before_finalize_update, :roles => :app do
  restructure_current_release
end
def restructure_current_release
  sudo "mv #{current_release}/Golfbook/* #{current_release}"
  sudo "rm -rf Golfbook"
end

deploy.task :destroy do
    sudo "rm -rf #{deploy_to}"
end

task :tail_log, :roles => :app do
    stream "tail -f #{shared_path}/log/production.log"
end

########################
#Passenger
########################
#This will restart the passenger app
namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end
########################

after :deploy, 'deploy:cleanup'
after 'deploy:cold', 'deploy:cleanup'