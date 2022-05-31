class RadiobotMailer < ActionMailer::Base
  
  def custom_mail(cur_user, my_pass)
     @recipients = cur_user.email
     @from       = 'noreply@bot.fm'
     @sent_on    = Time.now
     @subject    = "Регистрация на BOT.FM"
     @nick       = cur_user.name
     @login      = cur_user.login
     @password   = my_pass
  end

  def remind_pass(user, new_pass)
     @recipients = user.email
     @from       = 'noreply@bot.fm'
     @sent_on    = Time.now
     @subject    = "Напоминание пароля"
     @body[:name] = user.name
     @body[:my_pass] = new_pass
  end

end
