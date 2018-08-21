class PassaporteWeb::Entities::Profile::ProfessionalInfo < PassaporteWeb::Entities::Base
  attribute :id,          Integer
  attribute :profession,  String
  attribute :company,     String
  attribute :position,    String
end
