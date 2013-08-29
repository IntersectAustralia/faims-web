def set_admin_password
  count = 0
  loop do
    break if count > 2
    count = count + 1
    puts "Please enter new admin password:"
    input = STDIN.gets.chomp
    admin = User.find_by_email('faimsadmin@intersect.org.au')
    unless admin
   	  admin = User.new(first_name:'Faims', last_name:'Admin', email: 'faimsadmin@intersect.org.au')
	  admin.activate
	end
    admin.password = admin.password_confirmation = input
    if admin.valid?
      admin.save
      puts "Password changed!"
      break 
    else
      puts 'Password error: ' + admin.errors[:password].join(' | ')
    end
  end
end

