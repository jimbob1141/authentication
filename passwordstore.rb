#!/usr/bin/ruby


require 'pg'
require 'digest'
require_relative 'pw.rb'
password = $pass


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
  password_hash = create_hash(user_pw)
  con = get_connection()
  #inserts the username and hash into the table
  con.exec "INSERT INTO hashes VALUES ('#{username}', '#{password_hash}')"
end 


def create_hash(user_pw)
  return Digest::SHA1.hexdigest(user_pw)
end


def get_users
  username_array = []
  con = get_connection()
  usernames = con.exec "SELECT username FROM hashes"
  usernames.each do |name|
    username_array[username_array.length] = name['username']
  end
  return username_array
end


def get_hash(username)
  con = get_connection()
  #gets the password hash for the passed in username
  hashes = con.exec "SELECT hash FROM hashes WHERE username = '#{username}'"
  hashes.each do |hash|
    return hash['hash']
  end
end


def existing_user
  print "Please enter username: "
  username = gets.chomp
  users = get_users
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
      end
    end
    puts "Max attempts reached, exiting program"
    exit
    end
end


def get_connection
  password = 'password'
  return PG.connect :dbname => password, :user => 'james', :password => password
end


menu_select()


