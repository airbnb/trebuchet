class User < Struct.new(:id, :role)

  def has_role?(role)
    self.role == role
  end

end
