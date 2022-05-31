class AddUserRole < ActiveRecord::Migration
  def self.up
    Role.create(:title => 'user')
    puts "USER role created!"
  end

  def self.down
    Role.find_by_title('user').destroy
    puts "USER role deleted!"
  end
end
