defmodule LssfHtsWeb.ScanEventHTML do
  use LssfHtsWeb, :html

  embed_templates "scan_event_html/*"

  @doc """
  Renders a scan_event form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def scan_event_form(assigns)
end
