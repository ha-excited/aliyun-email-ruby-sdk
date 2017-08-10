# Aliyun email push sdk

## use: 

### init

```
aliyun = Aliyun::Email.new(@config['access_key_id'],@config['access_key_secret'], @config['account_name'])
```

### send
```
aliyun.send(@config['to_address'],
                                from_alias: @config['from_alias'],
                                subject: @config['subject'],
                                htmlbody: @config['htmlbody'],
                                textbody: @config['textbody'],
                                click_trace: @config['click_trace'])
```