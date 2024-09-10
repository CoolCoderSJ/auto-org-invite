require 'sinatra'
require 'httparty'

set :bind, '0.0.0.0'

get '/' do
  erb :index, :locals => {:orgName => ENV['ORG_NAME'], :username => nil, :success => nil}
end

post '/' do
  username = params['username']
  response = HTTParty.get("https://api.github.com/users/#{username}").body
  userObj = JSON.parse response
  puts userObj['id'], ENV['ORG_NAME'], ENV['GITHUB_TOKEN']
  
  resp = HTTParty.post("https://api.github.com/orgs/#{ENV['ORG_NAME']}/invitations", 
  {
    headers: {
      "Authorization" => "Bearer #{ENV['GITHUB_TOKEN']}",
      "Accept" => "application/vnd.github+json",
    },
    body: {
      "invitee_id" => userObj["id"],
      "role" => "direct_member",
    }.to_json
  })

  puts resp.body

  if resp.code == 201
    erb :index, :locals => {:orgName => ENV['ORG_NAME'], :username => username, :success => true}
  else
    erb :index, :locals => {:orgName => ENV['ORG_NAME'], :username => username, :success => false}
  end

end