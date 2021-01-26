require 'puppet-decrypt'

Puppet::Functions.create_function(:'decrypt') do
  $LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

  dispatch :main do
    required_param 'Variant[String, Hash]', :value
    required_param 'String', :secret_key
  end

  def main(value, secret_key)
    options = {
      :algorithm => 'aes-256-cbc'
    }
    decrypt_args = {}

    if value.is_a? String
      decrypt_args['value'] = value
      decrypt_args['secret_key'] = secret_key
    else
      decrypt_args = value
    end

    Puppet::Decrypt::Decryptor.new(options).decrypt_hash(decrypt_args)
  end
end
