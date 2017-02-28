module SessionsHelper
    
    #logs in the given user
    def log_in(user)
        session[:user_id] = user.id
    end
    
    #returns the current user logged-in if any
    def current_user
        @current_user ||= User.find_by(id: session[:user_id])
    end
    
    #Returns true if there is a user logged in, false otherwise
    def logged_in?
        !current_user.nil?
    end
    
    def log_out
        session.delete(:user_id)
        @current_user = nil
    end
    
end
