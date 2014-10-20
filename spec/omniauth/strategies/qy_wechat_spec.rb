require 'spec_helper'

describe OmniAuth::Strategies::QyWechat do
  let(:request) { double('Request', :params => {}, :cookies => {}, :env => {}, :scheme=>"http", :url=>"localhost") }
  let(:app) { ->{[200, {}, ["Hello."]]}}
  let(:client){OAuth2::Client.new('appid', 'secret')}

  subject do
    OmniAuth::Strategies::QyWechat.new(app, 'appid', 'secret', { name: 'xxx', agentid: 'agentid' }).tap do |strategy|
      allow(strategy).to receive(:request) {
        request
      }
    end
  end

  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
  end

  describe '#client_options' do
    specify 'has site' do
      expect(subject.client.site).to eq('https://qyapi.weixin.qq.com')
    end

    specify 'has authorize_url' do
      expect(subject.client.options[:authorize_url]).to eq('https://open.weixin.qq.com/connect/oauth2/authorize#wechat_redirect')
    end

    specify 'has token_url' do
      expect(subject.client.options[:token_url]).to eq('/cgi-bin/gettoken')
    end
  end

  describe "#authorize_params" do
    specify "default scope is snsapi_login" do
      expect(subject.authorize_params[:scope]).to eq("snsapi_base")
    end
  end

  describe "#token_params" do
    specify "token response should be parsed as json" do
      expect(subject.token_params[:parse]).to eq(:json)
    end
  end

  describe 'state' do
    specify 'should set state params for request as a way to verify CSRF' do
      expect(subject.authorize_params['state']).not_to be_nil
      expect(subject.authorize_params['state']).to eq(subject.session['omniauth.state'])
    end
  end


  describe "#request_phase" do
    specify "redirect uri includes'appid','redirect_uri','response_type','scope','state'and'wechat_redirect'fragment" do
      callback_url = "http://exammple.com/callback"

      subject.stub(:callback_url=>callback_url)
      subject.should_receive(:redirect).with do |redirect_url|
        uri = URI.parse(redirect_url)
        expect(uri.fragment).to eq("wechat_redirect")
        params = CGI::parse(uri.query)
        expect(params["appid"]).to eq(['appid'])
        expect(params["redirect_uri"]).to eq([callback_url])
        expect(params["response_type"]).to eq(['code'])
        expect(params["scope"]).to eq(['snsapi_base'])
        expect(params["state"]).to eq([subject.session['omniauth.state']])
      end

      subject.request_phase
    end
  end

  describe "#auth_hash" do

    let(:request) { double('Request', \
                           :params => { 'code' => 'code' }, \
                           :cookies => {}, \
                           :session => { 
                             "omniauth.corpid" => subject.client.id,
                             "omniauth.agentid" => subject.options.agentid
                           }, \
                           :env => {}, \
                           :scheme=>"http", \
                           :url=>"localhost") }

    specify "should has value" do
      auth_hash = subject.auth_hash
      expect(auth_hash[:corpid]).to eq subject.client.id
      expect(auth_hash[:code]).to eq request.params['code']
      expect(auth_hash[:agentid]).to eq subject.options.agentid
    end

  end

end
