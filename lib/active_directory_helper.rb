module ActiveDirectoryHelper
  def create_user (firstName, lastName, email, company, jobTitle, username, expirationDate, homeRegion)
    account_created = false
    json_body = ''
    begin
      response = RestClient.post(url="#{ENV['API_HOST']}/signup", 
      							             payload = {:fname => firstName, 
                        							 			:lname => lastName, 
                        							 			:username => username, 
                        							 			:org => company, 
                        							 			:email => email, 
                        							 			:title => jobTitle, 
                        							 			:expires_at => ((expirationDate.to_i)*1000), 
                        							 			:region => homeRegion}, 
      							             headers = {:token => ENV["API_KEY"]})

      if response.code == 200
        json_body = JSON.parse response
        account_created = true
      end
    rescue => e
      puts "Error Received when creating account for email: #{email} : #{e}"
    end
    puts "Done creating account for email #{email}. Response from AD #{json_body}"

    return account_created, json_body
  end

  def delete_user (username)
    account_removed = false
    response = ''

    begin
      response = RestClient.post( url="#{ENV['API_HOST']}/unregister",
                                  payload={:username => username}, 
                                  headers= {:token => ENV["API_KEY"]})
      account_removed = true
      puts "Got response #{response} for account deletion for user #{username}"
    rescue => e
      puts "Error Received when deleting account for username: #{username} : #{e}"
    end

    return account_removed, response
  end

  def reset_user_password (username, email)
    password_reset = false
    response = ''

    begin
      response = RestClient.post( url="#{ENV['API_HOST']}/changePassword", 
                                  payload={:username => username, :email => email}, 
                                  headers= {:token => ENV["API_KEY"]})
        if response.code == 200
          puts "Password reset request was successful for username #{username}. New passwrd is #{response}"
          password_reset = true
        end
    rescue => e
      puts "Error Received during password reset for username: #{username} : #{e}"
    end

    return password_reset, response
  end

  def change_user_password (username, password)
    password_change = false
    response = ''

    begin
      response = RestClient.post( url="#{ENV['API_HOST']}/changeUserPassword",
                                  payload={:username => username, :password => password}, 
                                  headers= {:token => ENV["API_KEY"]})
      if response.code == 200
        puts "Password change request was successful for username #{username}, response #{response}"
        password_change = true
      end
    rescue => e
      puts "Error Received during password change for username: #{username} : #{e}"
    end

    return password_change, response
  end

  def authenticate (username, password)
    authentication_success= false

    begin
      username = username.downcase
      response = RestClient.post( url="#{ENV['API_HOST']}/authenticate",
                                  payload={:username => username, :password => password}, 
                                  headers= {:token => ENV["API_KEY"]})
      if response.code == 200
        authentication_success = true
      end
    rescue => e
      puts "Error Received during authentication for username: #{username} : #{e}"
    end

    return authentication_success
  end

  def extend_user_account (username, newExpirationDate)
    account_extended = false
    expires_at = DateTime.parse(newExpirationDate) 
    begin
      response = RestClient.post( url="#{ENV['API_HOST']}/extendAccount",
                                  payload={:username => username,  :expires_at => ((expires_at.to_i)*1000)}, 
                                  headers= {:token => ENV["API_KEY"]})
      if response.code == 200
        puts "Account extension was successful for username #{username}, response #{response}"
        account_extended = true
      end
    rescue => e
      puts "Error Received during account extension for username: #{username} : #{e}"
    end

    return account_extended
  end

  def does_user_exist (username)
    existing_user = nil
    begin
      response = RestClient.post( url="#{ENV['API_HOST']}/getUser",
                                  payload={:username => username}, 
                                  headers= {:token => ENV["API_KEY"]})
      if response.code == 200
        puts "Existing user exists for username #{username}, response #{response}"
        existing_user = response
      end
    rescue => e
      puts "Error Received during authentication for username: #{username} : #{e}"
    end

    return existing_user
  end
end