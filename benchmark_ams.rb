require 'benchmark/ips'
require 'active_model_serializers'

# AMS serializers

class PostSerializer < ActiveModel::Serializer
  type 'posts'

  attributes :title, :body
  has_many :comments
  belongs_to :author

  link(:foo) { 'http://api.example.com/foo' }

  meta do
    { foo: 'bar' }
  end
end

class CommentSerializer < ActiveModel::Serializer
  type 'comments'
  attributes :body
  belongs_to :post
  belongs_to :author
end

class UserSerializer < ActiveModel::Serializer
  type 'users'

  attributes :first_name, :last_name
  has_many :posts
end

# Benchmarking

ActiveModelSerializers.config.adapter = :json_api
class NullLogger < Logger
  def initialize(*)
  end

  def add(*)
  end
end
ActiveModelSerializers.logger = NullLogger.new

require 'active_model_serializers/serialization_context'

require_relative 'fixtures'

GC.disable

time = 15
warmup = 3

Benchmark.ips do |x|
  x.config time: time, warmup: warmup
  x.report('AMS') do |times|
    i = 0
    while i < times
      ActiveModelSerializers::SerializableResource.new(
        @post, include: [:author, comments: [:author]]
      ).to_json
      i += 1
    end
  end
end
