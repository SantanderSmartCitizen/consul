set :branch, ENV["branch"] || :preproduction

server deploysecret(:server), user: deploysecret(:user), roles: %w[web app db importer cron]
