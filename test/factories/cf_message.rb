# -*- coding: utf-8 -*-

FactoryGirl.define do
  factory :cf_message do
    subject "Use the force!"
    content { generate(:random_string) }
    author "Obi-Wan"
    deleted false

    association :thread, :factory => :cf_thread
    association :owner, :factory => :cf_user
    association :forum, :factory => :cf_forum
  end
end


# eof