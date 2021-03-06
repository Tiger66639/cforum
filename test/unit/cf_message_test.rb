# -*- coding: utf-8 -*-

require 'test_helper'

class CfMessageTest < ActiveSupport::TestCase
  test "validations" do
    m = CfMessage.new
    assert !m.save

    m.subject = 'Down with the Imperium!'
    assert !m.save

    m.content = Faker::Lorem.paragraphs.join("\n\n")
    assert !m.save

    m.author = 'Luke'
    assert !m.save

    t = FactoryGirl.create(:cf_thread)
    m.thread_id = t.thread_id

    assert !m.save

    m.subject = nil
    m.forum_id = t.forum_id
    assert !m.save

    m.subject = 'a'
    assert !m.save

    m.subject = 'Down with the Imperium!'
    m.author = 'a'
    assert !m.save

    m.author = 'Luke'
    m.content = 'a'
    assert !m.save

    m.content = Faker::Lorem.paragraphs.join("\n\n")
    m.email = '24234'
    assert !m.save

    m.email = 'a'
    assert !m.save

    m.email = 'luke@rebellion.gov'
    m.homepage = 'a'
    assert !m.save

    m.homepage = 'wefwef'
    assert !m.save

    m.homepage = 'http://heise.de/'
    assert m.save
  end

  test "thread association" do
    m = FactoryGirl.create(:cf_message)
    assert_not_nil m.thread
  end

  test "forum association" do
    m = FactoryGirl.create(:cf_message)
    assert_not_nil m.forum
  end

  test "owner association" do
    m = FactoryGirl.create(:cf_message)
    assert_not_nil m.owner
  end

  test "delete and restore" do
    m = FactoryGirl.create(:cf_message)
    m1 = FactoryGirl.create(:cf_message, forum: m.forum, thread: m.thread, parent_id: m.message_id)

    t = CfThread.preload(:messages).find(m.thread.thread_id)
    t.gen_tree

    t.sorted_messages[0].delete_with_subtree
    assert m.reload.deleted
    assert m1.reload.deleted

    t.sorted_messages[0].restore_with_subtree
    assert !m.reload.deleted
    assert !m.reload.deleted

    t.sorted_messages[1].delete_with_subtree
    assert !m.reload.deleted
    assert m1.reload.deleted

    t.sorted_messages[1].restore_with_subtree
    assert !m.reload.deleted
    assert !m.reload.deleted
  end

  test "tags associations" do
    msg = FactoryGirl.create(:cf_message)
    tag = CfTag.create!(tag_name: 'death star', forum_id: msg.forum_id)

    assert_equal 0, msg.messages_tags.count()
    assert_equal 0, msg.tags.count()

    ctt = CfMessageTag.create!(tag_id: tag.tag_id, message_id: msg.message_id)
    assert_equal 1, msg.messages_tags.count()
    assert_equal 1, msg.tags.count()

    assert msg.tags.clear
    assert_equal 0, msg.tags.count()
    assert_equal 0, msg.messages_tags.count()
    assert_not_nil CfTag.find_by_tag_id tag.tag_id
  end

end


# eof
