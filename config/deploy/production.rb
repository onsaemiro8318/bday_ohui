
server 'm8.mnv.kr', user: 'onesup', roles: %w{web app db}# , my_property: :my_value
set :ssh_options, {
  keys: %w(/Users/daul/.ssh/ids/m8.mnv.kr/deployer/id_rsa),
  forward_agent: false
}
set :rails_env, :production
set :application, 'bday_ohui'
puts "deploy/production.rb"