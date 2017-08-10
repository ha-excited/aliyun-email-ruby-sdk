require 'aliyun/version'
require 'net/http'
require 'openssl'
require 'base64'
require 'uri'
require 'erb'
include ERB::Util

module Aliyun
  class Email
    attr_accessor :access_key_secret,
                  :access_key_id,
                  :action,
                  :format,
                  :region_id,
                  :account_name,
                  :signature_method,
                  :reply_to_address,
                  :address_type,
                  :signature_version,
                  :version
    def initialize(access_key_id, access_key_secret, account_name)
      # public args
      @access_key_secret = access_key_secret
      @access_key_id = access_key_id
      @format ||= 'JSON'
      @region_id ||= 'cn-hangzhou'
      @signature_method ||= 'HMAC-SHA1'
      @signature_version ||= '1.0'
      @version ||= '2015-11-23'

      # function args
      @action ||= 'SingleSendMail'
      @account_name = account_name
      @reply_to_address = false
      @address_type = 1
    end

    def create_params(to_address)
      {
        # public args
        'AccessKeyId'       => access_key_id,
        'Format'            => format,
        'RegionId'          => region_id,
        'SignatureMethod'   => signature_method,
        'SignatureVersion'  => signature_version,
        'Version'           => version,

        'SignatureNonce'    => seed_signature_nonce,
        'Timestamp'         => seed_timestamp,

        # function args
        'Action'            => action,
        'AccountName'       => account_name,
        'ReplyToAddress'    => reply_to_address,
        'AddressType'       => address_type,
        'ToAddress'         => to_address
      }
    end

    def send(to_address, from_alias: nil, subject: nil, htmlbody: nil, textbody: nil, click_trace: nil)
      begin
        uri = URI("https://dm.aliyuncs.com")
        header = {"Content-Type": "application/x-www-form-urlencoded"}
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(uri.request_uri, header)
        params = create_params(to_address)
        params['FromAlias'] = from_alias unless from_alias.nil?
        params['Subject'] = subject unless subject.nil?
        params['HtmlBody'] = htmlbody unless htmlbody.nil?
        params['TextBody'] = textbody unless textbody.nil?
        params['ClickTrace'] = click_trace unless click_trace.nil?
        req.body = sign_result(access_key_secret, params)
        p req.body.split('&')
        response = http.request(req)
        response
      rescue => e
        puts "errors #{e}"
      end
    end

    def sign_result(key_secret, params)
      params_string = (query_string(params))
      "Signature=" + safe_encode(compute_signature(key_secret, params_string)) + '&' + params_string
    end

    def query_string(params)
      params.keys.sort.map {|key| "%s=%s" % [safe_encode(key.to_s), safe_encode(params[key])]}.join('&')
    end

    def seed_timestamp
      Time.now.utc.strftime("%FT%TZ")
    end

    def seed_signature_nonce
      Time.now.utc.strftime("%Y%m%d%H%M%S%L")
    end


    def compute_signature access_key_secret,canonicalized_query_string
      string_to_sign = 'POST' + '&' + safe_encode('/') + '&' + safe_encode(canonicalized_query_string)
      signature = calculate_signature access_key_secret+"&", string_to_sign
    end

    def calculate_signature key, string_to_sign
      Base64.encode64(OpenSSL::HMAC.digest('sha1', key, string_to_sign)).gsub("\n", '')
    end

    def safe_encode value
      URI.encode_www_form_component(value).gsub(/\+/,'%20').gsub(/\*/,'%2A').gsub(/%7E/,'~')
    end
  end
end

