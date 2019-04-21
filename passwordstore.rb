#!/usr/bin/ruby

require 'pg'
require 'digest'
require_relative 'pw.rb'
password = $pass

#lets the user choose if they are a new or existing user
#until is used so when the function is complete the program will exit
def menu_select()
  puts "Select an option:"
  puts "1. New User"
  puts "2. Existing User"
  input = ''
  until input == '1' || input == '2'
    input = gets.chomp
    if input == '1'
      create_user()
    elsif input == '2'
      existing_user()
    else
      puts "Please enter a valid option: 1 or 2"
    end
  end 
end

#start of the user creation process
def create_user
  print "Please enter your desired username: "
  username = gets.chomp
  #creates database connection
  con = get_connection()
  #gets existing usernames
  usernames = con.exec "SELECT username FROM hashes"
  #creates an array to add usernames to so I can check if they exist
  username_array = get_users()
  #checks the array for the entered username
  if username_array.include?(username)
    puts "Username already taken"
  #if the username is free, takes you to set the password
  else
    set_password(username)
  end  
end

#creates a hash of the users password and inserts into the database
def set_password(username)
  #just set to random letter so they are not equal
  user_pw = 'i'
  user_pw_validate = ''
  #runs until the password match
  unless user_pw == user_pw_validate
    print "Please enter password: "
    user_pw = gets.chomp
    print "please enter password again: "
    user_pw_validate = gets.chomp
    #lets the user know their passwords didn't match
    if user_pw != user_pw_validate
      puts "Passwords did not match"
    end
  end
  #creates a hash using the entered password
  password_hash = create_hash(user_pw)
  #creates connection
  con = get_connection()
  #inserts the username and hash into the table
  con.exec "INSERT INTO hashes VALUES ('#{username}', '#{password_hash}')"
end 

#simply returns a hash of the passed in value
def create_hash(user_pw)
  return Digest::SHA1.hexdigest(user_pw)
end

#queries the database for users and returns an array of users
def get_users
  username_array = []
  con = get_connection()
  usernames = con.exec "SELECT username FROM hashes"
  usernames.each do |name|
    username_array[username_array.length] = name['username']
  end
  return username_array
end

#gets the has for a particular username
def get_hash(username)
  #creates connection
  con = get_connection()
  #gets the password hash for the passed in username
  hashes = con.exec "SELECT hash FROM hashes WHERE username = '#{username}'"
  #similar to before when building the username array, will find a better way to do this as a loop isn't necessary
  hashes.each do |hash|
    return hash['hash']
  end
end

#runs when the user selects existing user
def existing_user
  print "Please enter username: "
  username = gets.chomp
  #gets the array of users
  users = get_users
  #checks if the entered username is in the array
  if users.include?(username)
    attempts = 0
    until attempts == 3
      print "Please enter password: "
      user_pass = gets.chomp
      #runs users input through hash function
      pw_hash = create_hash(user_pass)
      #gets the hash for the existing password
      correct_hash = get_hash(username)
      #increments attempts
      attempts += 1
      if pw_hash == correct_hash
        puts "#{username} authenticated successfully"
	exit
      else
	puts "Password incorrect, please try again"
	if attempts == 3
          puts "Max attempts reached, exiting program"
	end
      end
    else
      puts "User not found"
    end
end


def get_connection
  password = 'password'
  return PG.connect :dbname => password, :user => 'james', :password => password
end


menu_select()


