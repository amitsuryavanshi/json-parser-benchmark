require 'benchmark/ips'
require 'fast_jsonapi'
require 'json'
require 'pry'

# fastjsonapi serializers


class SerializablePost
  include FastJsonapi::ObjectSerializer
  set_type 'posts'

  attributes :title, :body
  has_many(:comments)
  belongs_to :author, record_type: :user

end

class SerializablePostCommentSerializer
  include FastJsonapi::ObjectSerializer

  set_type 'comments'

  attributes(:body)
  belongs_to :post
  belongs_to :author, record_type: :user
end

class SerializablePostUserSerializer
  include FastJsonapi::ObjectSerializer

  set_type 'users'

  attributes :first_name, :last_name
  has_many(:posts)
end

require_relative 'fixtures'

GC.disable

time = 15
warmup = 3

puts SerializablePost.new(@post, include: [:comments, :author]).serialized_json

Benchmark.ips do |x|
  x.config time: time, warmup: warmup
  x.report('fastjson-api') do |times|
    i = 0
    while i < times
      SerializablePost.new(@post, include: [:comments, :author]).serialized_json
      # JSONAPI::Serializable::Renderer.new.render(
      #   @post, class: {Post: SerializablePost, Comment: SerializableComment, User: SerializableUser}, include: [:author, comments: [:author]]
      # )
      i += 1
    end
  end
end