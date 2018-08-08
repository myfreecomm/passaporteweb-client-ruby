class PassaporteWeb::Entities::Profile::Emails < PassaporteWeb::Entities::Base
  attribute :id,      Integer
  attribute :emails,  Array[String]
end
