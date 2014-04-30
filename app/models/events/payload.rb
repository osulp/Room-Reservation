class Events::Payload < OpenStruct
  def == (other_object)
    return super if other_object.kind_of?(Events::Payload)
    other_object.class == class_name && other_object.try(:id) == id
  end
end
