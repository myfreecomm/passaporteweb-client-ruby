# A wrapper to PassaporteWeb's widget API
#
# [API]
#   Documentation:
#
# @example Obtaining the user's navbar URL:
#   client = PassaporteWeb::Client::Identity.new(credentials)
#   client.widget.navbar_url
#
# @example Inviting a new user to PassaporteWeb (on behalf of an application):
#   client = PassaporteWeb::Client::Application.new
#   client.sign_up.create('john.doe@gmail.com')
#
# @see PassaporteWeb::Client::Identity#initialize
class PassaporteWeb::Resources::Widget < PassaporteWeb::Resources::Base

   # Retrieves the user's navbar URL
  #
  # [API]
  #   Method: <tt>GET /api/v1/widgets/navbar</tt>
  #
  #   Documentation:
  #
  # @return [String] user's navbar URL
  def navbar_url
    %(#{PassaporteWeb.configuration.url}/api/v1/widgets/navbar?access_token=#{api.token})
  end
end
