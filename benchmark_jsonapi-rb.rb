require 'benchmark/ips'
require 'jsonapi/serializable'
require 'json'
require 'pry'

# jsonapi-rb serializers

class SerializablePost < JSONAPI::Serializable::Resource
  type 'posts'

  attributes :title, :body
  has_many(:comments) { linkage always: true }
  belongs_to(:author) { linkage always: true }

  link(:foo) { 'http://api.example.com/foo' }

  meta do
    { foo: 'bar' }
  end
end

class SerializableComment < JSONAPI::Serializable::Resource
  type 'comments'

  attributes(:body) { linkage always: true }
  belongs_to(:post) { linkage always: true }
  belongs_to(:author) { linkage always: true }
end

class SerializableUser < JSONAPI::Serializable::Resource
  type 'users'

  attributes :first_name, :last_name
  has_many(:posts) { linkage always: true }
end

require_relative 'fixtures'

GC.disable

time = 15
warmup = 3
puts JSONAPI::Serializable::Renderer.new.render(
        @post, class: {Post: SerializablePost, Comment: SerializableComment, User: SerializableUser}, include: [:author, comments: [:author]]
      )
Benchmark.ips do |x|
  x.config time: time, warmup: warmup
  x.report('jsonapi-rb') do |times|
    i = 0
    while i < times
      JSONAPI::Serializable::Renderer.new.render(
        @post, class: {Post: SerializablePost, Comment: SerializableComment, User: SerializableUser}, include: [:author, comments: [:author]]
      )
      i += 1
    end
  end
end