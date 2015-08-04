module Ghetto
  module ActiveDirectoryHelper
    def create_user (firstName, lastName, email, company, jobTitle, username, expirationDate, homeRegion)
      account_created = false
      json_body = ''

      if ENV["TRYGRID_AD_ENABLED"].to_b
        puts "AD Account Creation enabled for TryGrid - Proceeding"
        begin
          response = RestClient.post(url="#{ENV['TRYGRID_API_HOST']}/signup", 
                                     payload = {:fname => firstName, 
                                                :lname => lastName, 
                                                :username => username, 
                                                :org => company, 
                                                :email => email, 
                                                :title => jobTitle, 
                                                :expires_at => ((expirationDate.to_i)*1000), 
                                                :region => homeRegion}, 
                                     headers = {:token => ENV["TRYGRID_API_KEY"]})

          if response.code == 200
            json_body = JSON.parse response
            account_created = true
          end
        rescue => e
          puts "Error Received when creating account for email: #{email} : #{e}"
        end
        puts "Done creating account for email #{email}. Response from AD #{json_body}"
      else
        puts "AD Account Creation **disabled** for TryGrid - generating fake data"
        json_body = create_user_dummy (username)
        account_created = true
      end

      return account_created, json_body
    end

    def delete_user (username)
      account_removed = false
      response = ''

      if ENV["TRYGRID_AD_ENABLED"].to_b
        begin
          response = RestClient.post( url="#{ENV['TRYGRID_API_HOST']}/unregister",
                                      payload={:username => username}, 
                                      headers= {:token => ENV["TRYGRID_API_KEY"]})
          account_removed = true
          puts "Got response #{response} for account deletion for user #{username}"
        rescue => e
          puts "Error Received when deleting account for username: #{username} : #{e}"
        end
      else
        account_removed = true
      end


      return account_removed, response
    end

    def reset_user_password (username, email)
      password_reset = false
      response = ''

      if ENV["TRYGRID_AD_ENABLED"].to_b
        begin
          response = RestClient.post( url="#{ENV['TRYGRID_API_HOST']}/changePassword", 
                                      payload={:username => username, :email => email}, 
                                      headers= {:token => ENV["TRYGRID_API_KEY"]})
            if response.code == 200
              puts "Password reset request was successful for username #{username}. New passwrd is #{response}"
              password_reset = true
            end
        rescue => e
          puts "Error Received during password reset for username: #{username} : #{e}"
        end
      else
        password_reset = true
        response = reset_user_password_dummy(username, email)
      end


      return password_reset, response
    end

    def change_user_password (username, password)
      password_change = false
      response = ''

      if ENV["TRYGRID_AD_ENABLED"].to_b
        begin
          response = RestClient.post( url="#{ENV['TRYGRID_API_HOST']}/changeUserPassword",
                                      payload={:username => username, :password => password}, 
                                      headers= {:token => ENV["TRYGRID_API_KEY"]})
          if response.code == 200
            puts "Password change request was successful for username #{username}, response #{response}"
            password_change = true
          end
        rescue => e
          puts "Error Received during password change for username: #{username} : #{e}"
        end
      else
        password_change = true
      end

      return password_change, response
    end

    def authenticate (username, password)
      authentication_success= false

      if ENV["TRYGRID_AD_ENABLED"].to_b
        begin
          username = username.downcase
          response = RestClient.post( url="#{ENV['TRYGRID_API_HOST']}/authenticate",
                                      payload={:username => username, :password => password}, 
                                      headers= {:token => ENV["TRYGRID_API_KEY"]})
          if response.code == 200
            authentication_success = true
          end
        rescue => e
          puts "Error Received during authentication for username: #{username} : #{e}"
        end
      else
        authentication_success = true
      end

      return authentication_success
    end

    def extend_user_account (username, newExpirationDate)
      account_extended = false
      expires_at = DateTime.parse(newExpirationDate) 

      if ENV["TRYGRID_AD_ENABLED"].to_b
        begin
          response = RestClient.post( url="#{ENV['TRYGRID_API_HOST']}/extendAccount",
                                      payload={:username => username,  :expires_at => ((expires_at.to_i)*1000)}, 
                                      headers= {:token => ENV["TRYGRID_API_KEY"]})
          if response.code == 200
            puts "Account extension was successful for username #{username}, response #{response}"
            account_extended = true
          end
        rescue => e
          puts "Error Received during account extension for username: #{username} : #{e}"
        end
      else
        account_extended = true
      end


      return account_extended
    end

    def does_user_exist (username)
      existing_user = nil

      if ENV["TRYGRID_AD_ENABLED"].to_b
        begin
          response = RestClient.post( url="#{ENV['TRYGRID_API_HOST']}/getUser",
                                      payload={:username => username}, 
                                      headers= {:token => ENV["TRYGRID_API_KEY"]})
          if response.code == 200
            puts "Existing user exists for username #{username}, response #{response}"
            existing_user = response
          end
        rescue => e
          puts "Error Received during authentication for username: #{username} : #{e}"
        end
      else
        existing_user = does_user_exist_dummy(username)
      end

      return existing_user
    end

    def add_user_to_group (username, groupName)
      user_added = false

      if ENV["TRYGRID_AD_ENABLED"].to_b
        begin
          add_user_to_group_url = "#{ENV['TRYGRID_API_HOST']}/addUserToGroup"
          response = RestClient.post( url=add_user_to_group_url,
                                      payload={:username => username, :group => groupName}, 
                                      headers= {:token => ENV["TRYGRID_API_KEY"]})
          user_added = true
        rescue => e
          puts "Error Received adding username: #{username} from group #{groupName}: #{e}"
        end
      else
        user_added = true
      end
    end

    def remove_user_from_group (username, groupName)
      user_removed = false

      if ENV["TRYGRID_AD_ENABLED"].to_b
        begin
          remove_user_from_group_url = "#{ENV['TRYGRID_API_HOST']}/removeUserFromGroup"
          response = RestClient.post( url = remove_user_from_group_url,
                                      payload={:username => username, :group => groupName}, 
                                      headers= {:token => ENV["TRYGRID_API_KEY"]})
          user_removed = true
        rescue => e
          puts "Error Received removing username: #{username} from group #{groupName}: #{e}"
        end
      else
        user_removed = true
      end
    end

  private

    def create_user_dummy (username)
      response_json = {}
      response_json['username']   = username
      response_json['password']   = 'FakePassword'

      return response_json
    end

    def reset_user_password_dummy (username, email)
      return 'FakePasswordReset'
    end

    def does_user_exist_dummy (username)
      existing_user = Account.find_by_username(username)
      response_json = {}

      if existing_user
        response_json['username']   = username
        response_json['name']   = existing_user.first_name + " " + existing_user.last_name
        response_json['company']   = existing_user.company
        response_json['email']   = existing_user.email
        response_json['last_login']   = Time.now - 1.day
        return response_json
      else
        return nil
      end
    end
  end
end