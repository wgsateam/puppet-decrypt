module Puppet
  module Decrypt

    class Decryptor
      ENCRYPTED_PATTERN = /^ENC:?(\w*)\[(.*)\]$/
      KEY_DIR = ENV['PUPPET_DECRYPT_KEYDIR'] || '/etc/puppet-decrypt'
      DEFAULT_KEY = 'encryptor_secret_key'
      DEFAULT_FILE = File.join(KEY_DIR, DEFAULT_KEY)

      def initialize(options = {})
        @raw = options[:raw] || false
      end

      def decrypt_hash(hash)
        decrypt(hash['value'], hash['secretkey']  || hash['secret_key'])
      end

      def encrypt_hash(hash)
        secret_key = hash['secretkey'] || hash['secret_key'] ||
            File.join(KEY_DIR, DEFAULT_KEY)
        salt = hash['salt'] || SecureRandom.base64
        iv = hash['iv'] || OpenSSL::Cipher::Cipher.new('aes-256-cbc').random_iv

        encrypt(hash['value'], secret_key, salt, iv)
      end

      def decrypt(value, secret_key_file)
        secret_key_file ||= secret_key_for value
        secret_key_digest = digest_from secret_key_file
        if @raw
          match = true
        else
          match = value.match(ENCRYPTED_PATTERN)
          if match
            value = match[2]
          end
        end
        if match
          value, iv, salt = value.split(':').map{|s| strict_decode64 s }
          if iv && salt
            res = Encryptor.decrypt(:value => value, :key => secret_key_digest, :iv => iv, :salt => salt)
          else
            $stderr.puts "Warning: re-encrypt with puppet-crypt to use salted passwords"
            res = Encryptor.decrypt(:key => secret_key_digest)
          end
        end
        res
      end

      def encrypt(value, secret_key_file, salt, iv)
        secret_key_file ||= secret_key_for value
        secret_key_digest = digest_from secret_key_file
        result = value.encrypt(:key => secret_key_digest, :iv => iv, :salt => salt)
        encrypted_value = [result, iv, salt].map{|v| strict_encode64(v).strip }.join ':'
        encrypted_value = "ENC[#{encrypted_value}]" unless @raw
        raise "Value can't be encrypted properly with salt #{salt}" unless decrypt(encrypted_value, secret_key_file) == value
        encrypted_value
      end

      private
      def load_key(secret_key_file)
        Puppet::Decrypt.key_loader.load_key secret_key_file
      end

      def secret_key_for(value)
        match = value.match(ENCRYPTED_PATTERN)
        if match
          key = match[1]
          key = DEFAULT_KEY if key.empty?
        end
        key ||= DEFAULT_KEY
        File.join(KEY_DIR, key)
      end

      def digest_from(secret_key_file)
        secret_key = load_key secret_key_file
        Digest::SHA256.hexdigest(secret_key)
      end

      # Backported for ruby 1.8.7
      def strict_decode64(str)
        return Base64.strict_decode64(str) if Base64.respond_to? :strict_decode64

        unless str.include?("\n")
          Base64.decode64(str)
        else
          raise(ArgumentError,"invalid base64")
        end
      end

      # Backported for ruby 1.8.7
      def strict_encode64(bin)
        return Base64.strict_encode64(bin) if Base64.respond_to? :strict_encode64
        Base64.encode64(bin).tr("\n",'')
      end

    end
  end
end
