class PassaporteWeb::Resources::SignUp < PassaporteWeb::Resources::Base

  def create(params)
    respond_with_entity(api.post('/api/v1/sign_up', body: params))
  end
end
