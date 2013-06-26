class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  #  :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :token_authenticatable, :validatable

  before_save :ensure_authentication_token
end
