class SwearFilter

  def self.blacklist
    @blacklist ||= YAML.load_file(File.join(Rails.root, "config", "swear_list.yml"))
  end

  def self.profane?(value)
    regex = /[^a-z^A-Z]/
    value = value.to_s.split(" ").map{ |word| word.gsub(regex, "")}.join(" ")
    blacklist.each do |word|
      if value.downcase.include?(word)
        return true
      end
    end
    return false
  end

end
