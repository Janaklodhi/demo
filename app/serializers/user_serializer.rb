class UserSerializer < ActiveModel::Serializer
    attributes :id, :username, :password, :confirm_password, :account_type
end
