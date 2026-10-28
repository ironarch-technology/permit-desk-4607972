# Turns a cashiering quote into a stored fee quote.
class FeeAssessment
  def initialize(application, client: Clients::CashieringClient.new)
    @application = application
    @client = client
  end

  def call
    quote = @client.quote(@application)

    @application.fee_quotes.create!(
      total_cents: quote.fetch('total_cents'),
      breakdown: quote.fetch('breakdown', {}),
      quote_reference: quote.fetch('quote_reference'),
      expires_at: Time.zone.parse(quote.fetch('expires_at'))
    )
  end
end
