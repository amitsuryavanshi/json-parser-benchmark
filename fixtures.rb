# Models

class Model
  def initialize(hash = {})
    hash.each { |k, v| send("#{k}=", v) }
  end

  def read_attribute_for_serialization(attr)
    send(attr)
  end
end

class Post < Model
  attr_accessor :id, :title, :body, :comments, :author, :comment_ids, :author_id
end

class Comment < Model
  attr_accessor :id, :body, :post, :author, :post_id, :author_id
end

class User < Model
  attr_accessor :id, :first_name, :last_name, :posts, :post_ids
end

# Fixtures

@post = Post.new(id: 1, title: 'Post Title', body: 'Post body', author: nil)

@users = (0..100).map do |i|
  User.new(id: i, first_name: "First name #{i}", last_name: "Last name #{i}",
           posts: [])
end

@comments = (0..100).map do |i|
  c = Comment.new(id: i, body: "Comment body #{i}", post: @post, author: @users[i], author_id: @users[i].id, post_id: @post.id)
  c.author_id = @users[i].id
  c
end

@post.comments = @comments
@post.comment_ids = @comments.map(&:id)