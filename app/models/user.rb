class User < ActiveRecord::Base
  #has_many :microposts
  has_many :microposts, dependent: :destroy

  # Читаемые пользователи
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  #has_many :followeds, through: :relationships
  has_many :followed_users, through: :relationships, source: :followed

  ## User.first.followed_users.map { |i| i.id }
  ## User.first.followed_users.map(&:id)
  ## User.first.followed_user_ids
  ## => [4, 5, 6, 7, 8, 9,..., 48, 49, 50, 51]

  # Читатели пользователя
  has_many :reverse_relationships, foreign_key: "followed_id",
           class_name:  "Relationship",
           dependent:   :destroy
  has_many :followers, through: :reverse_relationships, source: :follower
  # Стоит также отметить, что мы могли бы в этом случае пропустить :source, используя просто
  # has_many :followers, through: :reverse_relationships
  # поскольку Rails будет автоматически искать внешний ключ follower_id

  before_save { self.email = email.downcase }
  before_create :create_remember_token
  
  # set per_page globally
  #WillPaginate.per_page = 11
  self.per_page = 10
  
  has_secure_password
  validates :password, length: { minimum: 3, maximum: 50 } 
    
  #validates(:name, presence: true)
  #validates :name,  presence: true, length: { maximum: 50 }
  validates :name,  presence: true, length: { maximum: 50 }, uniqueness: true
  
  #validates :email, presence: true  
  #VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  #validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }                 
  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def feed_v1
    # Это предварительное решение. См. полную реализацию в "Following users".
    #Micropost.where("user_id = ?", id)
    #Micropost.where("user_id = ?", self.id)
    microposts
  end

  def feed
    Micropost.from_users_followed_by(self)
  end

  # метод following? принимает пользователя, названного other_user и проверяет,
  # существует ли он в базе данных
  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  # метод follow! вызывает create! через relationships ассоциацию
  # для создания взаимоотношения с читаемым
  def follow!(other_user)
    self.relationships.create!(followed_id: other_user.id)
  end
  # прекратить слежение за сообщениями других пользователей,
  # нужно просто найти взаимоотношение по followed id и уничтожить его
  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy!
  end
  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end