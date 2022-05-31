class CreateAdmin < ActiveRecord::Migration
  def self.up
    #temp_user = User.new(:login => 'admin', :email => 'admin@admin.ru', :password => 'nimda', :password_confirmation => 'nimda', :name => "admin", :description => "admin", :is_admin => true)
    #if temp_user.save
    #  puts "Admin created!"
    #else
    #  puts "Error!"
    #end
  end

  def self.down
    #temp_user = User.find_by_login("admin")
    #if temp_user && temp_user.destroy
    #  puts "Admin deleted!"
    #else
    #  puts "Admin not found!"
    #end
  end
end
