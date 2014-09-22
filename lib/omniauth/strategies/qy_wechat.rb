require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class QyWechat < OmniAuth::Strategies::OAuth2
      option :name, "qy_wechat"

      option :client_options, {
        site:          "https://qyapi.weixin.qq.com",
        authorize_url: "https://open.weixin.qq.com/connect/oauth2/authorize#wechat_redirect",
        token_url:     "/cgi-bin/gettoken",
        token_method:  :get
      }

      option :authorize_params, {scope: "snsapi_base"}

      option :token_params, {parse: :json}

      uid do
        raw_info['unionid']
      end

      info do
        {
          openid:     raw_info["openid"],
          nickname:   raw_info['nickname'],
          sex:        raw_info['sex'],
          province:   raw_info['province'],
          city:       raw_info['city'],
          country:    raw_info['country'],
          headimgurl: raw_info['headimgurl']
        }
      end

      extra do
        {raw_info: raw_info}
      end

      def request_phase
        params = client.auth_code.authorize_params.merge(redirect_uri: callback_url).merge(authorize_params)
        params["appid"] = params.delete("client_id")
        redirect client.authorize_url(params)
      end

      def raw_info
        @uid ||= access_token["openid"]
        @raw_info ||= begin
          access_token.options[:mode] = :query
          if access_token["scope"] && access_token["scope"].include?("snsapi_base")
            @raw_info = access_token.get("/cgi-bin/user/getuserinfo", :params => {"code" => request.params['code'], "agentid" => client.id}, parse: :json).parsed
          else
            @raw_info = { }
          end
        end
      end

      protected
      def build_access_token
        params = {
          'corpid' => client.id, 
          'corpsecret' => client.secret
          }.merge(token_params.to_hash(symbolize_keys: true))
        client.get_token(params, deep_symbolize(options.auth_token_params))
      end

    end
  end
end
