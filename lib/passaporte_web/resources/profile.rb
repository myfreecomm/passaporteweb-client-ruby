class PassaporteWeb::Resources::Profile < PassaporteWeb::Resources::Base

  def get
    respond_with_entity(api.get('/api/v1/profile'))
  end

  def professional_info
    respond_with_entity(
      api.get('/api/v1/profile/professional_info'),
      PassaporteWeb::Entities::Profile::ProfessionalInfo)
  end

  def contacts
    respond_with_entity(
      api.get('/api/v1/profile/contacts'),
      PassaporteWeb::Entities::Profile::Contacts)
  end

  def emails
    respond_with_entity(
      api.get('/api/v1/profile/emails'),
      PassaporteWeb::Entities::Profile::Emails)
  end

end
