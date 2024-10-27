CREATE OR REPLACE FUNCTION get_all_tags()
RETURNS TABLE ("Tag" text, "Description" text) AS
$$
BEGIN
    RETURN QUERY SELECT "Tag"."Tag", "Tag"."Description" FROM "Tag";
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_tag_description(tag_name text)
RETURNS text AS
$$
DECLARE
    tag_description text;
BEGIN
    SELECT "Tag"."Description" INTO tag_description FROM "Tag" WHERE "Tag"."Tag" = tag_name;
	if tag_description is null then
        RAISE EXCEPTION 'There is no this tag';
	end if;
    RETURN tag_description;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_tag(tag_name text, tag_description text)
RETURNS void AS $$
BEGIN
    -- проверяем, что тэг с таким названием еще не существует
    IF EXISTS (SELECT 1 FROM public."Tag" WHERE "Tag"."Tag" = tag_name) THEN
        RAISE EXCEPTION 'Tag already exists';
    END IF;

    -- добавляем новый тэг
    INSERT INTO public."Tag" ("Tag", "Description") VALUES (tag_name, tag_description);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_tag(tag_name text)
RETURNS void AS $$
BEGIN
    -- проверяем, что тэг с таким названием существует
    IF NOT EXISTS (SELECT 1 FROM public."Tag" WHERE "Tag"."Tag" = tag_name) THEN
        RAISE EXCEPTION 'Tag does not exist';
    END IF;

    -- удаляем тэг
    DELETE FROM public."Tag" WHERE "Tag"."Tag" = tag_name;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE procedure update_tag_description(tag_name text, new_description text)
AS $$
BEGIN
    UPDATE public."Tag" SET "Description" = new_description WHERE "Tag" = tag_name;
END;
$$ LANGUAGE plpgsql;