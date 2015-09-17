class BoxInstanceFetcherWorker
  include Sidekiq::Worker

  attr_reader :instance

  def initialize(box_instance_id)
    @instance = BoxInstance.find(box_instance_id)
  end

  def agent
    @agent ||= Mechanize.new
  end

  def login_to_token_generator
    page = agent.get(instance.token_retriever_url)
    form = page.forms.first

    form.client_id = instance.client_id
    form.client_secret = instance.client_secret

    page = form.submit
    form = page.form_with(name: 'login_form')

    form.login = instance.username
    form.password = instance.password

    page = form.submit
    form = page.form_with(name: 'consent_form')

    form.submit(form.button_with(name: 'consent_accept'))
  end

  def perform(box_instance_id=nil)
    @instance = BoxInstance.find(box_instance_id) if box_instance_id.present?

    result = login_to_token_generator
    tokens = result.search('h4.text-info').map(&:text).first(2)

    instance.access_token = tokens.first
    instance.refresh_token = tokens.last
    instance.save!
  end
end