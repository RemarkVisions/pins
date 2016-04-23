class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable,  omniauth_providers: [:google_oauth2]
  has_many :pins
end 

class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
      # You need to implement the method below in your model (e.g. app/models/user.rb)
      @user = User.find_for_google_oauth2(request.env[“omniauth.auth”], current_user)

      if @user.persisted?
        session[:sn_user] = request.env[‘omniauth.params’]
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
        sign_in_and_redirect @user, :event => :authentication
      else
        session["devise.google_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
  end
end

def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(:email => data["email"]).first

    # Uncomment the section below if you want users to be created if they don't exist
    # unless user
    #     user = User.create(name: data["name"],
    #        email: data["email"],
    #        password: Devise.friendly_token[0,20]
    #     )
    # end
    user
end

def self.find_for_google_oauth2(access_token, signed_in_resource = nil)

data = access_token.info

user = User.where(:provider => access_token.provider, :uid => access_token.uid ).first

if user

return user

else

registered_user = User.where(:email => access_token.info.email).first

if registered_user

return registered_user

else

access_token.provider = “Google”

user = User.create(first_name: data[“first_name”],

last_name: data[“last_name”],

provider:access_token.provider,

email: data[“email”],

password: Devise.friendly_token[0,20],

confirmed_at:Time.zone.now # if u don’t want to send any confirmation mail

)

end

end

end