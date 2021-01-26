require 'puppet-decrypt'

Puppet::Functions.create_function(:'decrypt') do
  dispatch :main do
    required_param 'Variant[String, Hash]', :value
    required_param 'String', :secret_key
  end

  def main(value, secret_key)
    options = {}
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
