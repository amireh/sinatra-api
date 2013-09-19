class String
  unless String.instance_methods.include?(:camelize)
    def camelize
      s = self.sub(/[_|\s]\w/) { |f| f[1].capitalize }
      s[0] = s[0].upcase
      s
    end
  end
end