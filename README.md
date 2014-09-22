# omniauth-qy-wechat-oauth2

Using OAuth2 to authenticate wechat user in web application.
Base on [https://github.com/skinnyworm/omniauth-wechat-oauth2](https://github.com/skinnyworm/omniauth-wechat-oauth2)

Qy Wechat Document: [http://qydev.weixin.qq.com/wiki/index.php?title=%E4%BC%81%E4%B8%9A%E8%8E%B7%E5%8F%96code](http://qydev.weixin.qq.com/wiki/index.php?title=%E4%BC%81%E4%B8%9A%E8%8E%B7%E5%8F%96code)

## Installation

Add this line to your application's Gemfile:

    gem 'omniauth-qy-wechat-oauth2', git: 'https://github.com/mycolorway/omniauth-qy-wechat-oauth2.git'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-qy-wechat-oauth2

## Usage

Add provider to `config/initializers/omniauth.rb`

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :qy_wechat, 'qy_wechat_corp_id'
end
```

Access the OmniAuth Open Wechat OAuth2 URL: /auth/qy_wechat

## Auth Hash

A example of `request.env["omniauth.auth"]` :

```ruby
{
    :provider => "qy_wechat",
    :uid => "user_id",
    :info => {
          user_id:     "abc999",
        },
    :credentials => {
            :token => "token",
            :refresh_token => "another_token",
            :expires_at => 7200,
            :expires => true
        },
    :extra => {
            :raw_info => {
                      user_id:    "abc999"
                    }
        }
}
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/omniauth-open-wechat-oauth2/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
