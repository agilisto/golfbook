set :application, "Golfbook" #matches names used in smf_template.erb
set :repository,  "https://cap@code.agilisto.com:8443/svn/golfbook/trunk/Golfbook"

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

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :subversion
set :domain, 'golfbook.agilisto.com'
set :scm_password, "deploy"

role :app, domain
role :web, domain
role :db,  domain, :primary => true

#set :server_name, key_name + ".joyent.us"
#set :server_alias, "*." + key_name + ".joyent.us"
set :server_name, golfbook.agilisto.com