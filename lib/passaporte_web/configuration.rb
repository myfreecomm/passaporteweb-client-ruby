class PassaporteWeb::Configuration

  attr_accessor :url, :user_agent, :application_id, :application_secret

  def initialize
    @url = 'https://v2.passaporteweb.com.br'
    @user_agent = "PassaporteWeb Ruby Client v#{PassaporteWeb::VERSION}"
  end

  def url_for(path)
    %(#{url.chomp('/')}#{path})
  end
end
