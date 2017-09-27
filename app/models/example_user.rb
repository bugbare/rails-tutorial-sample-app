class User
  attr_accessor :first_name, :surname, :email

  def initialize(attributes = {})
    @first_name  = attributes[:first_name]
    @surname = attributes[:surname]
    @email = attributes[:email]
  end
  
  def fullname
      "#{@first_name} #{@surname}"
  end

  def formatted_email
    "#{self.fullname} <#{@email}>"
  end
end
