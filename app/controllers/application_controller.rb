class ApplicationController < ActionController::API
    
    SECRET = ENV['SECRET_KEY'] # Rails.application.secret_key_base this#
    def encode_data(payload)
        token = JWT.encode payload, SECRET, "HS256"
        return token
    end
    
    def decode_data(token)  
        begin
            data = JWT.decode token, SECRET, true, { algorithm: "HS256" }
            return data
        rescue => e
            puts e
        end
    end

    private
    def current_user
        token = request.headers['Authorization']&.split(' ')&.last
        return unless token
        data = decode_data(token)
        user_id = data[0]['user_data']
        User.find_by(id: user_id) if user_id.present?
    end 
end
