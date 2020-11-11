defmodule Anubis.MailgunEmailAdapter do
  @api_v3 "https://api.mailgun.net/v3"

  def send(:v3, %{from: from, to: to, text: text, subject: subject}) do
    payload = [{"from", from}, {"to", to}, {"text", text}, {"subject", subject}]

    headers = [
      Authorization: generate_auth_header(:v3),
      "Content-Type": "application/x-www-form-urlencoded"
    ]

    HTTPoison.post!(build_api_url(:v3), {:multipart, payload}, headers)
  end

  defp build_api_url(:v3) do
    @api_v3 <> "/" <> Application.fetch_env!(:anubis, :mailgun_api_domain) <> "/messages"
  end

  defp generate_auth_header(:v3) do
    "Basic #{Base.encode64("api:#{Application.fetch_env!(:anubis, :mailgun_api_key)}")}"
  end
end
