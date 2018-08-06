class PassaporteWeb::Configuration
  attr_accessor :user_agent

  def initialize
    @url = 'https://app.passaporteweb.com.br'
    @user_agent = "PassaporteWeb Ruby Client v#{PassaporteWeb::VERSION}"
  end

  def url_for(path)
    path.start_with?('/') ? %(#{url}#{path}) : %(#{url}/#{path})
  end

  def url
    url.end_with?('/') ? url.chomp('/') : url
  end
end
