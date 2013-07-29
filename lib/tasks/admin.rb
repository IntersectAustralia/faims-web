def set_admin_password
  puts "Please enter new admin password:"
  count = 0
  loop do
    break if count > 2
    count = count + 1
    input = STDIN.gets.chomp
    admin = User.find_by_email('faimsadmin@intersect.org.au')
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

