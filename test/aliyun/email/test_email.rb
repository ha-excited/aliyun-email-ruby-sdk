$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'aliyun/email'

require 'minitest/autorun'
require 'yaml'

class TestEmail < Minitest::Test
  def setup
    @config = YAML.load(File.open("test_config.yml"))
    @aliyun = Aliyun::Email.new(@config['access_key_id'],@config['access_key_secret'], @config['account_name'])
  end
  def test_send
    result = @aliyun.send(@config['to_address'],
                                from_alias: @config['from_alias'],
                                subject: @config['subject'],
                                textbody: @config['textbody'],
                                click_trace: @config['click_trace'])
    p result.body unless result.nil?
    assert_equal !result.nil?, true
  end
  def test_sign
    strToSign = 'POST&%2F&AccessKeyId%3DLTAIVN0FfJj0xh3l%26AccountName%3Dservice%2540mymart.sg%26Action%3DSingleSendMail%26AddressType%3D1%26Format%3DXML%26FromAlias%3D%25E4%25BD%2599%25E7%258E%25A9%26RegionId%3Dcn-hangzhou%26ReplyToAddress%3Dfalse%26SignatureMethod%3DHMAC-SHA1%26SignatureNonce%3Db45f51c8-9981-4fc0-a8c3-7832055e008a%26SignatureVersion%3D1.0%26Subject%3D%25E7%25B3%25BB%25E7%25BB%259F%25E9%2582%25AE%25E4%25BB%25B6%252C%2520%25E8%25AF%25B7%25E5%258B%25BF%25E5%259B%259E%25E5%25A4%258D%26TagName%3D%25E7%25B3%25BB%25E7%25BB%259F%26TextBody%3D%25E4%25BD%25A0%25E5%25A5%25BD%26Timestamp%3D2017-08-10T03%253A41%253A07Z%26ToAddress%3Dzgyxydkyzc%2540qq.com%26Version%3D2015-11-23'
    signature = 'SBKvmWw7+dUbOL5wMoaP25ryqPo='
    assert_equal @aliyun.calculate_signature(@config['access_key_secret']+'&', strToSign), signature
  end
end
