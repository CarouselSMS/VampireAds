set :application,         "vampire_ads"
set :repository,          ""
set :domain,              ""

default_run_options[:pty] = true
ssh_options[:paranoid]    = false

set :user,                "smsbox"
set :runner,              "smsbox"
set :use_sudo,            false

set :scm,                 :git
set :branch,              "master"
set :deploy_to,           "/home/smsbox/#{application}"

# don't use export as it will clear out the .git directories prematurely.
# we'll remove them ourselves later when we're done with using git
set :deploy_via,          :checkout   

# set these values with proc-value to delay evaluation and properly handle overrides (e.g. deploy_to)
set(:current_path)        { "#{deploy_to}/current" }  # A hack since cap 2.3.0 uses /u/apps sometimes
set(:mongrel_conf)        { "#{current_path}/config/mongrel_cluster.yml" }

role :app, domain
role :web, domain
role :db,  domain, :primary => true

# Create uploads directory and link, remove rep clone
task :after_update_code, :roles => :app do
  run "cp #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  run "ln -s #{shared_path}/data #{release_path}/public/data"
  run "rm -Rf #{release_path}/.git" if fetch(:deploy_to) != :export
end

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
