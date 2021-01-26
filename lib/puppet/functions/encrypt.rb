require 'puppet-decrypt'

Puppet::Functions.create_function(:'encrypt') do
# Encrypt data, using Decryptor.
#
# This function expects four arguments:
# - Data to encrypt.
# - Secret key file path,
#    Puppet::Decrypt::Decryptor::DEFAULT_KEY by default.
#   Can be specified as basename in Puppet::Decrypt::Decryptor::KEY_DIR.
# - Salt (optional), randomly generated by default.
# - Initialization vector (optional), randomly generated by default,
#   mainly useful for tests.

  dispatch :main do
    required_param 'Variant[String,Hash]', :value
    required_param 'String', :secret_key
    optional_param 'String', :salt
    optional_param 'String', :iv
  end

  def main(value, secret_key, salt, iv)
    encrypt_args = {}
    unless salt
      salt = Puppet::Util::Execution.execute("pwgen -s -1 14")
    end

    unless iv
      iv = Puppet::Util::Execution.execute("head -c 10 /dev/random | base64")
    end

    if value.is_a? String
      encrypt_args['value'] = value
      encrypt_args['secret_key'] = secret_key
      encrypt_args['salt'] = salt
      encrypt_args['iv'] = iv
    else
      encrypt_args = value
    end

    Puppet::Decrypt::Decryptor.new.encrypt_hash(encrypt_args)
  end
end
