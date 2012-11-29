# -*- coding: utf-8 -*-

class FixUpdateMessagesTrigger < ActiveRecord::Migration
  def up
    execute %q{
      ALTER TABLE cforum.threads ADD COLUMN deleted BOOLEAN NOT NULL DEFAULT false;
--
-- UPDATE: add one dataset with difference = +/- 1 if row is deleted/restored for each row
--
CREATE OR REPLACE FUNCTION cforum.count_messages_update_trigger() RETURNS trigger LANGUAGE plpgsql AS $body$
DECLARE
  is_del_thread BOOLEAN;
BEGIN
  IF OLD.deleted = false AND NEW.deleted = true THEN
    INSERT INTO
      cforum.counter_table (table_name, difference, group_crit)
    VALUES
      ('messages', -1, NEW.forum_id);
  END IF;

  IF OLD.deleted = true AND NEW.deleted = false THEN
    INSERT INTO
      cforum.counter_table (table_name, difference, group_crit)
    VALUES
      ('messages', +1, NEW.forum_id);
  END IF;

  IF OLD.forum_id != NEW.forum_id THEN
    INSERT INTO
      cforum.counter_table (table_name, difference, group_crit)
    VALUES
      ('messages', -1, OLD.forum_id);

    INSERT INTO
      cforum.counter_table (table_name, difference, group_crit)
    VALUES
      ('messages', +1, NEW.forum_id);
  END IF;

  SELECT EXISTS(SELECT message_id FROM cforum.messages WHERE thread_id = NEW.thread_id AND deleted = false) INTO is_del_thread;
  IF is_del_thread THEN
    UPDATE cforum.threads SET deleted = false WHERE thread_id = NEW.thread_id;
  ELSE
    UPDATE cforum.threads SET deleted = true WHERE thread_id = NEW.thread_id;
  END IF;

  RETURN NULL;
END;
$body$;
    }

    execute %q{
--
-- UPDATE: add one dataset with difference = +/- 1 if row is deleted/restored for each row
--
CREATE OR REPLACE FUNCTION cforum.count_threads_update_trigger() RETURNS trigger LANGUAGE plpgsql AS $body$
BEGIN
  IF OLD.deleted = false AND NEW.deleted = true THEN
    INSERT INTO
      cforum.counter_table (table_name, difference, group_crit)
    VALUES
      ('threads', -1, NEW.forum_id);
  END IF;

  IF OLD.deleted = true AND NEW.deleted = false THEN
    INSERT INTO
      cforum.counter_table (table_name, difference, group_crit)
    VALUES
      ('threads', +1, NEW.forum_id);
  END IF;

  IF OLD.forum_id != NEW.forum_id THEN
    INSERT INTO
      cforum.counter_table (table_name, difference, group_crit)
    VALUES
      ('threads', -1, OLD.forum_id);

    INSERT INTO
      cforum.counter_table (table_name, difference, group_crit)
    VALUES
      ('threads', +1, NEW.forum_id);
  END IF;

  RETURN NULL;
END;
$body$;
    }
  end

  def down
  end
end

# eof