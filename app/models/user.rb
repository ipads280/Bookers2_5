class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_many :relationships,                                        foreign_key: :following_id
  has_many :followings, through: :relationships, source: :follower
  
  has_many :reverse_of_relationships, class_name: "Relationship", foreign_key: :follower_id
  has_many :followers, through: :reverse_of_relationships, source: :following

  has_many :books
  has_many :book_comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_one_attached :profile_image

  validates :name, length: { minimum: 2, maximum: 20 }, uniqueness: true
  validates :introduction, length: { maximum: 50 }
  
  
  def get_profile_image
    (profile_image.attached?) ? profile_image : 'no_image.jpg'
  end
  
  def is_followed_by?(user)
    reverse_of_relationships.find_by(following_id: user.id).present?
  end
  
  def self.search_for(content, method)
    if method == 'perfect'
      User.where(name: content)
    else
      User.where('name LIKE ?', '%' + content + '%')
    end
  end
end
