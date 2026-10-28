# Intake validation: required fields, a parcel we recognise, a valuation in
# range, and a contractor licence that has not run out.
class SubmissionValidator
  Result = Struct.new(:errors, keyword_init: true) do
    def valid?
      errors.empty?
    end
  end

  FIELD_LABELS = {
    parcel_address: 'Parcel address',
    work_type: 'Work type',
    scope_narrative: 'Scope of work',
    valuation: 'Project valuation',
    applicant_name: 'Your name',
    applicant_email: 'Email address'
  }.freeze

  def initialize(application, parcel_address:)
    @application = application
    @parcel_address = parcel_address
  end

  def call
    errors = {}

    errors[:applicant_name] = 'Enter the name this permit should be issued to.' if @application.applicant_name.blank?
    errors[:applicant_email] = 'Enter an email address we can reach you at.' if @application.applicant_email.blank?
    errors[:scope_narrative] = 'Describe the work you are planning.' if @application.scope_narrative.blank?

    if @parcel_address.blank?
      errors[:parcel_address] = 'Enter the address the work will happen at.'
    elsif @application.parcel.nil?
      errors[:parcel_address] = 'We could not match that address to a Mountport parcel.'
    end

    unless PermitApplication::WORK_TYPES.include?(@application.work_type)
      errors[:work_type] = 'Choose the type of work you are applying for.'
    end

    if @application.valuation_cents.to_i <= 0
      errors[:valuation] = 'Enter the estimated value of the work.'
    elsif @application.valuation_cents.to_i > PermitApplication::VALUATION_CEILING_CENTS
      errors[:valuation] = 'Projects above $2,000,000 are handled by Major Projects, not the permit counter.'
    end

    if @application.contractor?
      if @application.contractor_licence_expiry.blank?
        errors[:contractor_licence_expiry] = 'Enter the expiry date on the contractor licence.'
      elsif @application.contractor_licence_expiry <= Date.current
        errors[:contractor_licence_expiry] = 'That contractor licence has expired.'
      end
    end

    Result.new(errors: errors)
  end
end
