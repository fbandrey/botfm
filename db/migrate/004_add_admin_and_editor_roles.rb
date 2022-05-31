class AddAdminAndEditorRoles < ActiveRecord::Migration
  def self.up
    Role.create!(:title => 'admin')
    Role.create!(:title => 'editor')
    temp_user = User.find_by_login('admin')
    if temp_user
      temp_user.roles << Role.find_by_title('admin')
    end
    
    puts "Admin and Editor roles created!"
  end

  def self.down
    Role.find_by_title('admin').destroy
    Role.find_by_title('editor').destroy
    
    puts "Admin and Editor roles deleted!"
  end
end
