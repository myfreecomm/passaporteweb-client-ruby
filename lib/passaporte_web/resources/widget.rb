class PassaporteWeb::Resources::Widget < PassaporteWeb::Resources::Base

  def navbar_url
    %(#{PassaporteWeb.configuration.url}/api/v1/widgets/navbar?access_token=#{api.token})
  end
end
