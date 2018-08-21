class PassaporteWeb::Entities::Profile::Contacts < PassaporteWeb::Entities::Base
  attribute :id,            Integer
  attribute :phone_numbers, Array[String]
end
