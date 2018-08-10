# A wrapper to PassaporteWeb's sign up API
#
# [API]
#   Documentation:
#
# @example Inviting a new user to PassaporteWeb (on behalf of an existing user):
#   client = PassaporteWeb::Client::Identity.new(credentials)
#   client.sign_up.create('john.doe@gmail.com')
#
# @example Inviting a new user to PassaporteWeb (on behalf of an application):
#   client = PassaporteWeb::Client::Application.new
#   client.sign_up.create('john.doe@gmail.com')
#
# @see PassaporteWeb::Client::Identity#initialize
# @see PassaporteWeb::Client::Application#initialize
class PassaporteWeb::Resources::SignUp < PassaporteWeb::Resources::Base

  # Invites an user to PassaporteWeb, by creating a new sign up.
  #
  # [API]
  #   Method: <tt>POST /api/v1/sign_up</tt>
  #
  #   Documentation:
  # @param [String] email The new user's email.
  #
  # @return [PassaporteWeb::Entities::SignUp] the new sign up; it contains the invited user's id.
  def create(email)
    respond_with_entity(api.post('/api/v1/sign_up', body: MultiJson.dump({ invited: email })))
  end
end
