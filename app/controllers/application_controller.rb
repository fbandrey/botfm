# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  include ExceptionNotifiable
  ExceptionNotifier.exception_recipients = %w(fbandrey@gmail.com)
  ExceptionNotifier.sender_address = %("Error (Bot.FM)" <error-no-reply@bot.fm>)

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
