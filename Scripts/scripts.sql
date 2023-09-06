CREATE EXTENSION IF NOT EXISTS pgcrypto;
DROP EXTENSION IF EXISTS pgcrypto CASCADE;
drop function "add_photo_to_comment";
CREATE OR REPLACE FUNCTION add_media_to_post(post_id integer, media bytea)
RETURNS void AS
$$
BEGIN
    -- проверяем, что размер файла не больше 1ГБ
    IF octet_length(photo) > 1073741824 THEN
        RAISE EXCEPTION 'File size should not exceed 1GB';
    END IF;
    
    -- вставляем запись в таблицу
    INSERT INTO public."MediaFilesForPosts" ("Media", "Post_id") VALUES (media, post_id);
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_media_to_comment(comment_id integer, media bytea)
RETURNS void AS
$$
BEGIN
    -- проверяем, что размер файла не больше 1ГБ
    IF octet_length(photo) > 1073741824 THEN
        RAISE EXCEPTION 'File size should not exceed 1GB';
    END IF;
    
    -- вставляем запись в таблицу
    INSERT INTO public."MediaFilesForComments" ("Media", "Comment_id") VALUES (media, comment_id);
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_media_from_post(post_id bigint, media_id bigint)
RETURNS void AS
$$
BEGIN
    -- удаляем запись из таблицы
    DELETE FROM public."MediaFilesForPosts" WHERE "Post_id" = post_id AND "Media_id" = media_id;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_media_from_comment(comment_id bigint, media_id bigint)
RETURNS void AS
$$
BEGIN
    -- удаляем запись из таблицы
    DELETE FROM public."MediaFilesForComments" WHERE "Comment_id" = comment_id AND "Media_id" = media_id;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_all_media_for_posts()
RETURNS TABLE (
    "Media_id" integer,
    "Media" bytea,
    "Post_id" integer
) AS
$$
BEGIN
    RETURN QUERY SELECT "MediaFilesForPosts"."Media_id", "MediaFilesForPosts"."Media", "MediaFilesForPosts"."Post_id"
                 FROM "MediaFilesForPosts";
END;
$$
LANGUAGE plpgsql;
drop function get_all_media_for_posts();
select get_all_media_for_posts();
select getusers();

CREATE OR REPLACE FUNCTION get_media_for_post(media_id integer)
RETURNS TABLE (
    "Media_id" integer,
    "Media" bytea,
    "Post_id" integer
) AS
$$
BEGIN
    RETURN QUERY SELECT "MediaFilesForPosts"."Media_id", "MediaFilesForPosts"."Media", "MediaFilesForPosts"."Post_id"
                 FROM public."MediaFilesForPosts"
                 WHERE "MediaFilesForPosts"."Media_id" = media_id;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_media_for_post_by_id(post_id integer)
RETURNS TABLE (
    "Media_id" integer,
    "Media" bytea,
    "Post_id" integer
) AS
$$
BEGIN
    RETURN QUERY SELECT "MediaFilesForPosts"."Media_id", "MediaFilesForPosts"."Media", "MediaFilesForPosts"."Post_id"
                 FROM public."MediaFilesForPosts"
                 WHERE "MediaFilesForPosts"."Post_id" = post_id;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_all_media_for_comments()
RETURNS TABLE (
    "Media_id" integer,
    "Media" bytea,
    "Comment_id" integer
) AS
$$
BEGIN
    RETURN QUERY SELECT "MediaFilesForComments"."Media_id", "MediaFilesForComments"."Media", "MediaFilesForComments"."Comment_id"
                 FROM "MediaFilesForComments";
END;
$$
LANGUAGE plpgsql;
drop function get_all_media_for_posts();
select get_all_media_for_comments();
select getusers();

CREATE OR REPLACE FUNCTION get_media_for_comment(media_id integer)
RETURNS TABLE (
    "Media_id" integer,
    "Media" bytea,
    "Comment_id" integer
) AS
$$
BEGIN
    RETURN QUERY SELECT "MediaFilesForComments"."Media_id", "MediaFilesForComments"."Media", "MediaFilesForComments"."Comment_id"
                 FROM public."MediaFilesForComments"
                 WHERE "MediaFilesForComments"."Media_id" = media_id;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_media_for_comment_by_id(comment_id integer)
RETURNS TABLE (
    "Media_id" integer,
    "Media" bytea,
    "Comment_id" integer
) AS
$$
BEGIN
    RETURN QUERY SELECT "MediaFilesForComments"."Media_id", "MediaFilesForComments"."Media", "MediaFilesForComments"."Comment_id"
                 FROM public."MediaFilesForComments"
                 WHERE "MediaFilesForComments"."Comment_id" = comment_id;
END;
$$
LANGUAGE plpgsql;

select get_media_for_post(1);

CREATE TABLE public."Posts"
(
    "Post_id" serial NOT NULL primary key,
    "Name" text NOT NULL,
    "Description" text NOT NULL,
    "CookingTime" int,
    “Count” int,
    "Created_at" timestamp with time zone default CURRENT_TIMESTAMP NOT NULL,
    "Updated_at" timestamp with time zone default CURRENT_TIMESTAMP NOT NULL,
    "Instructions" text NOT NULL,
    "AuthorID" bigint not null,
    "Kitchen" text
);
CREATE TABLE public."TagsRecipe"
(
	"TagsRecipeId" serial primary key not null,
	"Post_id" bigint not null,
	"Tag" text not null
);
CREATE TABLE public."Tag"
(
	"Tag" text not null primary key,
	"Description" text not null
);

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

CREATE OR REPLACE FUNCTION get_ingridient_description(ingridient_name text)
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

select get_tag_description('dr');


select get_all_tags();
delete from "Tag";


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

SELECT add_tag('example', 'This is an example tag');

select * from "Tag";

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

-- Получение всех ингредиентов
CREATE OR REPLACE FUNCTION get_all_ingridients()
RETURNS TABLE (
    "Ingridient_id" integer,
    "Name" text,
    "Unit_of_measurement" text,
    "Protein" integer,
    "Fat" integer,
    "Carbonhydrates" integer
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM public."Ingridients";
END;
$$ LANGUAGE plpgsql;

-- Получение ингредиента по названию
CREATE OR REPLACE FUNCTION get_ingridient_by_name(name text)
RETURNS TABLE (
    "Ingridient_id" integer,
    "Name" text,
    "Unit_of_measurement" text,
    "Protein" real,
    "Fat" real,
    "Carbonhydrates" real
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM public."Ingridients" WHERE "Ingridients"."Name" = name;
END;
$$ LANGUAGE plpgsql;

drop function get_ingridient_by_name;

-- Создание нового ингредиента
CREATE OR REPLACE procedure create_ingridient(name text, unit_of_measurement text, protein integer, fat integer, carbonhydrates integer)
AS $$
BEGIN
    INSERT INTO public."Ingridients" ("Name", "Unit_of_measurement", "Protein", "Fat", "Carbonhydrates")
    VALUES (name, unit_of_measurement, protein, fat, carbonhydrates);
END;
$$ LANGUAGE plpgsql;
Drop FUNCTION create_ingridient(text, text,  integer,integer,integer);

-- Обновление ингредиента
CREATE OR REPLACE PROCEDURE update_ingridient(ingridient_id integer, name text, unit_of_measurement text, protein integer, fat integer, carbonhydrates integer)
AS $$
BEGIN
    UPDATE "Ingridients" SET "Name" = name, "Unit_of_measurement" = unit_of_measurement,
        "Protein" = protein, "Fat" = fat, "Carbonhydrates" = carbonhydrates
    WHERE "Ingridient_id" = ingridient_id;
END;
$$ LANGUAGE plpgsql;

-- Удаление ингредиента по ID
CREATE OR REPLACE PROCEDURE delete_ingridient_by_id(ingridient_id integer)
AS $$
BEGIN
    DELETE FROM public."Ingridients" WHERE "Ingridients"."Ingridient_id" = ingridient_id;
END;
$$ LANGUAGE plpgsql;

SELECT create_ingridient('СОЛЬ', 'ГР', 0.0, 0.0, 0.0);
select get_ingridient_by_name('СОЛЬ');
SELECT * FROM "Ingridients";

DELETE FROM "Ingridients";

CREATE OR REPLACE FUNCTION create_ingridient(name text, unit_of_measurement text, protein real, fat real, carbonhydrates real)
RETURNS void AS
$$
BEGIN
    INSERT INTO public."Ingridients" ("Name", "Unit_of_measurement", "Protein", "Fat", "Carbonhydrates")
    VALUES (name, unit_of_measurement, protein, fat, carbonhydrates);
END;
$$
LANGUAGE plpgsql;


CALL update_ingridient(1, 'соль', 'гр', 0, 0, 0);

SELECT delete_tag('example');

call update_tag_description('example', 'example');

delete from "Users";

CREATE OR REPLACE FUNCTION insert_tag_recipe()
  RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO "TagsRecipe" ("Post_id", "Tag") 
  VALUES (NEW."Post_id", NEW."Tag");
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_tag_recipe_trigger
AFTER INSERT ON "Posts"
FOR EACH ROW
EXECUTE FUNCTION insert_tag_recipe();

CREATE OR REPLACE FUNCTION calculate_nutrition(post_id int)
RETURNS TABLE (protein real, fat real, carbohydrates real) AS $$
BEGIN
  RETURN QUERY
    SELECT 
      SUM(ip."Count" * i."Protein") / SUM(ip."Count") AS protein,
      SUM(ip."Count" * i."Fat") / SUM(ip."Count") AS fat,
      SUM(ip."Count" * i."Carbonhydrates") / SUM(ip."Count") AS carbohydrates
    FROM "IngridientsPost" ip
    JOIN "Ingridients" i ON i."Ingridient_id" = ip."Ingridient_id"
    WHERE ip."Post_id" = calculate_nutrition.post_id;
END;
$$ LANGUAGE plpgsql;

CREATE or replace FUNCTION get_product_weight(post_id int, product_name text) RETURNS real
    LANGUAGE plpgsql
AS $$
DECLARE
    product_weight real;
BEGIN
    SELECT ip."Count" INTO product_weight
    FROM public."IngridientsPost" ip
    JOIN public."Ingridients" i ON ip."Ingridient_id" = i."Ingridient_id"
    WHERE ip."Post_id" = post_id AND i."Name" = product_name;

    RETURN product_weight;
END;
$$;
call register_user('Nikon', 'Chigoya', 'nikon.chigoya1@mail.ru', 'Nikon02052023', null);
----------------------------Экспорт БД---------------------
call export_json('C:\PostgreSQL\15\backup')
CREATE OR REPLACE PROCEDURE export_json(pathToSave TEXT) AS $$ BEGIN 
EXECUTE format(
		'COPY (SELECT COALESCE(cast(json_agg(to_json(t)) as text),''[]'') FROM "Users" t) TO %L',
		pathToSave || '\users.json'
	);
EXECUTE format(
	'COPY (SELECT COALESCE(cast(json_agg(to_json(t)) as text),''[]'') FROM "Posts" t) TO %L',
	pathToSave || '\posts.json'
);
EXECUTE format(
	'COPY (SELECT COALESCE(cast(json_agg(to_json(t)) as text),''[]'') FROM "Menu" t) TO %L',
	pathToSave || '\menu.json'
);
EXECUTE format(
	'COPY (SELECT COALESCE(cast(json_agg(to_json(t)) as text),''[]'') FROM "IngridientsPost" t) TO %L',
	pathToSave || '\ingridientsposts.json'
);
EXECUTE format(
	'COPY (SELECT COALESCE(cast(json_agg(to_json(t)) as text),''[]'') FROM "Favourites" t) TO %L',
	pathToSave || '\favourites.json'
);
EXECUTE format(
	'COPY (SELECT COALESCE(cast(json_agg(to_json(t)) as text),''[]'') FROM "Comments" t) TO %L',
	pathToSave || '\comments.json'
);
EXECUTE format(
	'COPY (SELECT COALESCE(cast(json_agg(to_json(t)) as text),''[]'') FROM "MediaFilesForComments" t) TO %L',
	pathToSave || '\mediafilesforcomments.json'
);
EXECUTE format(
	'COPY (SELECT COALESCE(cast(json_agg(to_json(t)) as text),''[]'') FROM "MediaFilesForPosts"  t) TO %L',
	pathToSave || '\mediafilesforposts.json'
);
EXECUTE format(
	'COPY (SELECT COALESCE(cast(json_agg(to_json(t)) as text),''[]'') FROM "History" t) TO %L',
	pathToSave || '\browsinghistory.json'
);
EXECUTE format(
	'COPY (SELECT COALESCE(cast(json_agg(to_json(t)) as text),''[]'') FROM "Subscriptions" t) TO %L',
	pathToSave || '\subscriptions.json'
);
EXECUTE format(
	'COPY (SELECT COALESCE(cast(json_agg(to_json(t)) as text),''[]'') FROM "TagsRecipe" t) TO %L',
	pathToSave || '\tagsrecipe.json'
);
EXECUTE format(
	'COPY (SELECT COALESCE(cast(json_agg(to_json(t)) as text),''[]'') FROM "Tag" t) TO %L',
	pathToSave || '\tags.json'
);
EXECUTE format(
	'COPY (SELECT COALESCE(cast(json_agg(to_json(t)) as text),''[]'') FROM "Likes" t) TO %L',
	pathToSave || '\likes.json'
);
EXECUTE format(
	'COPY (SELECT COALESCE(cast(json_agg(to_json(t)) as text),''[]'') FROM "Ingridients" t) TO %L',
	pathToSave || '\ingridients.json'
);
EXECUTE format(
	'COPY (SELECT COALESCE(cast(json_agg(to_json(t)) as text),''[]'') FROM "Tokens" t) TO %L',
	pathToSave || '\tokens.json'
);
END;
$$ LANGUAGE plpgsql;
-------------------------------------Импорт в БД--------------------------
call import_json('C:\PostgreSQL\15\backup');
delete from "Users";
create or REPLACE procedure import_json(pathToGet text) as $body$
declare usersJson json;
postsJson json;
menuJson json;
ingridientsRecipeJson json;
favouritesJson json;
commentsJson json;
mediafilesforpostsJson json;
mediafilesforcommentsJson json;
historyJson json;
subscriptionsJson json;
tagspostsJson json;
tagJson json;
likesJson json;
ingridientsJson json;
tokensJson json;
BEGIN
SELECT pg_read_file(pathToGet || '/users.json') INTO usersJson;
SELECT pg_read_file(pathToGet || '/posts.json') INTO postsJson;
SELECT pg_read_file(pathToGet || '/menu.json') INTO menuJson;
SELECT pg_read_file(pathToGet || '/ingridientsposts.json') INTO ingridientsRecipeJson;
SELECT pg_read_file(pathToGet || '/favourites.json') INTO favouritesJson;
SELECT pg_read_file(pathToGet || '/comments.json') INTO commentsJson;
SELECT pg_read_file(pathToGet || '/mediafilesforposts.json') INTO mediafilesforpostsJson;
SELECT pg_read_file(pathToGet || '/mediafilesforcomments.json') INTO mediafilesforcommentsJson;
SELECT pg_read_file(pathToGet || '/browsinghistory.json') INTO historyJson;
SELECT pg_read_file(pathToGet || '/subscriptions.json') INTO subscriptionsJson;
SELECT pg_read_file(pathToGet || '/tagsrecipe.json') INTO tagspostsJson;
SELECT pg_read_file(pathToGet || '/tags.json') INTO tagJson;
SELECT pg_read_file(pathToGet || '/likes.json') INTO likesJson;
SELECT pg_read_file(pathToGet || '/ingridients.json') INTO ingridientsJson;
SELECT pg_read_file(pathToGet || '/tokens.json') INTO tokensJson;
INSERT into "Users"
select *
from json_populate_recordset(null::"Users", usersJson);
INSERT into "Posts"
select *
from json_populate_recordset(null::"Posts", postsJson);
INSERT into "Menu"
select *
from json_populate_recordset(null::"Menu", menuJson);
INSERT into "IngridientsPost"
select *
from json_populate_recordset(null::"IngridientsPost", ingridientsRecipeJson);
INSERT into "Favourites"
select *
from json_populate_recordset(null::"Favourites", favouritesJson);
INSERT into "Comments"
select *
from json_populate_recordset(null::"Comments", commentsJson);
INSERT into "MediaFilesForPosts"
select *
from json_populate_recordset(null::"MediaFilesForPosts", mediafilesforpostsJson);
INSERT into "MediaFilesForComments"
select *
from json_populate_recordset(null::"MediaFilesForComments", mediafilesforcommentsJson);
INSERT into "History"
select *
from json_populate_recordset(null::"History", historyJson);
INSERT into "Subscriptions"
select *
from json_populate_recordset(null::"Subscriptions", subscriptionsJson);
INSERT into "TagsRecipe"
select *
from json_populate_recordset(null::"TagsRecipe", tagspostsJson);
INSERT into "Tag"
select *
from json_populate_recordset(null::"Tag", tagJson);
INSERT into "Likes"
select *
from json_populate_recordset(null::"Likes", likesJson);
INSERT into "Ingridients"
select *
from json_populate_recordset(null::"Ingridients", ingridientsJson);
INSERT into "Tokens"
select *
from json_populate_recordset(null::"Tokens", tokensJson);
end;
$body$ LANGUAGE plpgsql;


--..............
select * from "Users";

CREATE EXTENSION IF NOT EXISTS pg_trgm;
DROP EXTENSION IF EXISTS pg_trgm CASCADE;

SELECT * FROM "Users" WHERE levenshtein("Name", 'Nikolay') < 4;

CREATE INDEX "idx_users_name_age" ON "Users" ("Name");
drop index "idx_users_name_age";
CREATE INDEX "idx_posts_name" on "Posts" ("Name");
CREATE INDEX "idx_ingridients_name" on "Ingridients" ("Name");
CLUSTER "Ingridients" USING idx_ingridients_name;
CREATE INDEX "idx_tag_tag" on "Tag" ("Tag");
CLUSTER "Tag" USING idx_tag_tag;



CREATE EXTENSION fuzzystrmatch;
DROP EXTENSION IF EXISTS fuzzystrmatch CASCADE;

--///////////


CREATE OR REPLACE procedure add_ingridient(
    name text,
    unit_of_measurement text,
    protein real,
    fat real,
    carbonhydrates real
)
AS
$$
BEGIN
    INSERT INTO public."Ingridients" ("Name", "Unit_of_measurement", "Protein", "Fat", "Carbonhydrates")
    VALUES (name, unit_of_measurement, protein, fat, carbonhydrates);
END;
$$
LANGUAGE plpgsql;

delete from "Ingridients";

CREATE OR REPLACE FUNCTION get_ingridients()
RETURNS TABLE (
    "Ingridient_id" integer,
    "Name" text,
    "Unit_of_measurement" text,
    "Protein" real,
    "Fat" real,
    "Carbonhydrates" real
) AS
$$
BEGIN
    RETURN QUERY SELECT * FROM "Ingridients";
END;
$$
LANGUAGE plpgsql;

drop function get_ingridients();

CREATE OR REPLACE FUNCTION delete_ingridient(ingridient_id integer)
RETURNS void AS
$$
BEGIN
    DELETE FROM public."Ingridients" WHERE "Ingridient_id" = ingridient_id;
END;
$$
LANGUAGE plpgsql;

call add_ingridient('Carrot', 'gram', 1, 0, 6);
SELECT * FROM get_ingridients();

CREATE OR REPLACE FUNCTION add_favourite(
    post_id bigint,
    user_id bigint
)
RETURNS void AS
$$
BEGIN
    INSERT INTO public."Favourites" ("Post_id", "User_id")
    VALUES (post_id, user_id);
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_favourites()
RETURNS TABLE (
    "Favourite_id" integer,
    "Post_id" bigint,
    "User_id" bigint
) AS
$$
BEGIN
    RETURN QUERY SELECT * FROM public."Favourites";
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_favourite(favourite_id integer)
RETURNS void AS
$$
BEGIN
    DELETE FROM public."Favourites" WHERE "Favourite_id" = favourite_id;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_to_history(
    user_id bigint,
    post_id bigint
)
RETURNS void AS
$$
BEGIN
    INSERT INTO public."History" ("User_id", "Post_id")
    VALUES (user_id, post_id);
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_user_history(user_id bigint)
RETURNS TABLE (
    "User_id" bigint,
    "Post_id" bigint
) AS
$$
BEGIN
    RETURN QUERY SELECT * FROM public."History" WHERE "User_id" = user_id;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_user_id(user_id bigint) RETURNS boolean AS $$
BEGIN
    RETURN EXISTS (SELECT 1 FROM public."Users" WHERE "User_id" = user_id);
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION add_subscription(
    user_id_follower bigint,
    user_id_followed bigint
)
RETURNS void AS
$$
BEGIN
	IF 
    INSERT INTO public."Subscriptions" ("User_id_follower", "User_id_followed")
    VALUES (user_id_follower, user_id_followed);
END;
$$
LANGUAGE plpgsql;

select add_subscription(31, 1);
select ""
select * from "Users";

CREATE OR REPLACE FUNCTION delete_subscription(
    user_id_follower bigint,
    user_id_followed bigint
)
RETURNS void AS
$$
BEGIN
    DELETE FROM public."Subscriptions"
    WHERE "User_id_follower" = user_id_follower
    AND "User_id_followed" = user_id_followed;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_subscriptions(user_id_followed bigint)
RETURNS TABLE (
    "Subscription_id" bigint,
    "User_id_follower" bigint
) AS
$$
BEGIN
    RETURN QUERY SELECT * FROM public."Subscriptions" WHERE "User_id_followed" = user_id_followed;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_from_history(
    user_id bigint,
    post_id bigint
)
RETURNS void AS
$$
BEGIN
    DELETE FROM public."History"
    WHERE "User_id" = user_id
    AND "Post_id" = post_id;
END;
$$
LANGUAGE plpgsql;

-- Функция добавления лайка
CREATE OR REPLACE FUNCTION add_like(p_post_id bigint, p_user_id bigint) RETURNS void AS $$
BEGIN
    INSERT INTO public."Likes" ("Post_id", "User_id")
    VALUES (p_post_id, p_user_id);
END;
$$ LANGUAGE plpgsql;


-- Функция получения лайков для определенного поста
CREATE OR REPLACE FUNCTION get_likes_by_post(p_post_id bigint) RETURNS SETOF public."Likes" AS $$
BEGIN
    RETURN QUERY SELECT *
    FROM public."Likes"
    WHERE "Post_id" = p_post_id;
END;
$$ LANGUAGE plpgsql;


-- Функция удаления лайка
CREATE OR REPLACE FUNCTION remove_like(p_like_id bigint) RETURNS void AS $$
BEGIN
    DELETE FROM public."Likes"
    WHERE "Likes_id" = p_like_id;
END;
$$ LANGUAGE plpgsql;

-- Создание функции-триггера
CREATE OR REPLACE FUNCTION add_tags_to_recipe(post_id bigint, tags text[])
    RETURNS VOID AS $$
DECLARE
    tag_value text;
BEGIN
    FOREACH tag_value IN ARRAY tags
    LOOP
        INSERT INTO public."TagsRecipe" ("Post_id", "Tag")
        VALUES (post_id, tag_value);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_tags_in_recipe(post_id bigint, tags text[])
    RETURNS VOID AS $$
DECLARE
    tag_value text;
BEGIN
    -- Удаление существующих строк с тэгами для указанного post_id
    DELETE FROM public."TagsRecipe" WHERE "Post_id" = post_id;
    
    -- Добавление новых строк с обновленными тэгами для указанного post_id
    FOREACH tag_value IN ARRAY tags
    LOOP
        INSERT INTO public."TagsRecipe" ("Post_id", "Tag")
        VALUES (post_id, tag_value);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_tags_for_post(post_id bigint)
    RETURNS text[] AS $$
DECLARE
    tags text[];
BEGIN
    SELECT ARRAY(
        SELECT "Tag" FROM public."TagsRecipe" WHERE "Post_id" = post_id
    ) INTO tags;
    
    RETURN tags;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_ingredients_for_post(
    post_id bigint,
    ingredient_ids bigint[],
    ingredient_counts integer[]
)
    RETURNS void AS $$
DECLARE
    i int;
BEGIN
    FOR i IN 1..array_length(ingredient_ids, 1) LOOP
        INSERT INTO public."IngridientsPost" ("Ingridient_id", "Post_id", "Count")
        VALUES (ingredient_ids[i], post_id, ingredient_counts[i]);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_ingredients_for_post(
    post_id bigint,
    ingredient_ids bigint[],
    ingredient_counts integer[]
)
    RETURNS void AS $$
DECLARE
    i int;
BEGIN
    -- Удаляем существующие строки ингредиентов для данного поста
    DELETE FROM public."IngridientsPost" WHERE "Post_id" = post_id;

    -- Добавляем новые строки ингредиентов для данного поста
    FOR i IN 1..array_length(ingredient_ids, 1) LOOP
        INSERT INTO public."IngridientsPost" ("Ingridient_id", "Post_id", "Count")
        VALUES (ingredient_ids[i], post_id, ingredient_counts[i]);
    END LOOP;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_ingredients_for_post(
    post_id bigint
)
    RETURNS TABLE (
        "Ingridient_id" bigint,
        "Name" text,
        "Unit_of_measurement" text,
        "Count" integer
    ) AS $$
BEGIN
    RETURN QUERY
    SELECT ip."Ingridient_id", i."Name", i."Unit_of_measurement", ip."Count"
    FROM public."IngridientsPost" ip
    INNER JOIN public."Ingridients" i ON i."Ingridient_id" = ip."Ingridient_id"
    WHERE ip."Post_id" = post_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE register_user(Name text, Surname text, Email TEXT, PasswordHash TEXT, Avatar BYTEA) AS $$
DECLARE
User_id BIGINT;
BEGIN
IF LENGTH(PasswordHash) < 8 OR NOT (PasswordHash ~ '.\d.' AND PasswordHash ~ '.[A-Za-z].') THEN
RAISE EXCEPTION 'Password must be at least 8 characters long and contain both letters and numbers';
END IF;
IF octet_length(Avatar) > 10485760 THEN
RAISE EXCEPTION 'Avatar size exceeds the maximum allowed size of 10 MB';
END IF;
INSERT INTO Users (Name, Surname, Email, PasswordHash, Avatar) VALUES (Name, Surname, Email, crypt(PasswordHash, gen_salt('bf')), Avatar) RETURNING User_id INTO User_id;
INSERT INTO Tokens (User_id, Token) VALUES (User_id, generate_token(User_id));
END;
$$ LANGUAGE plpgsql;


-- Функция для создания нового поста
CREATE OR REPLACE FUNCTION create_post(
    name text,
    description text,
    cooking_time int,
    count int,
    instructions text,
    author_id bigint,
    kitchen text
)
    RETURNS bigint AS $$
DECLARE
    post_id bigint;
BEGIN
    INSERT INTO public."Posts" ("Name", "Description", "CookingTime", "Count", "Instructions", "AuthorID", "Kitchen")
    VALUES (name, description, cooking_time, count, instructions, author_id, kitchen)
    RETURNING "Post_id" INTO post_id;
    
    RETURN post_id;
END;
$$ LANGUAGE plpgsql;


-- Функция для получения информации о посте
CREATE OR REPLACE FUNCTION get_post(post_id bigint)
    RETURNS TABLE (
        "Post_id" bigint,
        "Name" text,
        "Description" text,
        "CookingTime" int,
        "Count" int,
        "Created_at" timestamp with time zone,
        "Updated_at" timestamp with time zone,
        "Instructions" text,
        "AuthorID" bigint,
        "Kitchen" text
    ) AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public."Posts"
    WHERE "Post_id" = post_id;
END;
$$ LANGUAGE plpgsql;


-- Функция для обновления информации о посте
CREATE OR REPLACE FUNCTION update_post(
    post_id bigint,
    name text,
    description text,
    cooking_time int,
    count int,
    instructions text,
    kitchen text
)
    RETURNS void AS $$
BEGIN
    UPDATE public."Posts"
    SET "Name" = name,
        "Description" = description,
        "CookingTime" = cooking_time,
        "Count" = count,
        "Instructions" = instructions,
        "Kitchen" = kitchen,
        "Updated_at" = CURRENT_TIMESTAMP
    WHERE "Post_id" = post_id;
END;
$$ LANGUAGE plpgsql;


-- Функция для создания нового комментария
CREATE OR REPLACE FUNCTION create_comment(
    post_id bigint,
    user_id bigint,
    text text
)
    RETURNS bigint AS $$
DECLARE
    comment_id bigint;
BEGIN
    INSERT INTO public."Comments" ("Post_id", "User_id", "Text")
    VALUES (post_id, user_id, text)
    RETURNING "Comment_id" INTO comment_id;
    
    RETURN comment_id;
END;
$$ LANGUAGE plpgsql;


-- Функция для получения комментариев поста
CREATE OR REPLACE FUNCTION get_comments_for_post(post_id bigint)
    RETURNS TABLE (
        "Comment_id" bigint,
        "Post_id" bigint,
        "User_id" bigint,
        "Text" text,
        "Created_at" timestamp with time zone,
        "Updated_at" timestamp with time zone
    ) AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public."Comments"
    WHERE "Post_id" = post_id;
END;
$$ LANGUAGE plpgsql;


-- Функция для создания нового меню
CREATE OR REPLACE FUNCTION create_menu(
    start_date date,
    end_date date,
    dish_id bigint,
    day_of_week integer,
    user_id bigint
)
    RETURNS bigint AS $$
DECLARE
    menu_id bigint;
BEGIN
    INSERT INTO public."Menu" ("Start_date", "End_date", "Dish_id", "Day_of_week", "User_id")
    VALUES (start_date, end_date, dish_id
	, day_of_week, user_id)
RETURNING "Menu_id" INTO menu_id;
RETURN menu_id;
END;
$$ LANGUAGE plpgsql;


-- Функция для получения информации о меню
CREATE OR REPLACE FUNCTION get_menu(menu_id bigint)
RETURNS TABLE (
"Menu_id" bigint,
"Start_date" date,
"End_date" date,
"Dish_id" bigint,
"Day_of_week" integer,
"Created_at" timestamp with time zone,
"Updated_at" timestamp with time zone,
"User_id" bigint
) AS $$
BEGIN
RETURN QUERY
SELECT *
FROM public."Menu"
WHERE "Menu_id" = menu_id;
END;
$$ LANGUAGE plpgsql;
-- Функция для обновления информации о меню
CREATE OR REPLACE FUNCTION update_menu(
menu_id bigint,
start_date date,
end_date date,
dish_id bigint,
day_of_week integer
)
RETURNS void AS $$
BEGIN
UPDATE public."Menu"
SET "Start_date" = start_date,
"End_date" = end_date,
"Dish_id" = dish_id,
"Day_of_week" = day_of_week,
"Updated_at" = CURRENT_TIMESTAMP
WHERE "Menu_id" = menu_id;
END;
$$ LANGUAGE plpgsql;

-- Функция для обновления комментария
CREATE OR REPLACE FUNCTION update_comment(
    comment_id bigint,
    text text
)
    RETURNS void AS $$
BEGIN
    UPDATE public."Comments"
    SET "Text" = text,
        "Updated_at" = CURRENT_TIMESTAMP
    WHERE "Comment_id" = comment_id;
END;
$$ LANGUAGE plpgsql;

select getusers();


call register_user('Nikon', 'chch', 'fhnrhf', 'jdnhndedSWD222', null)
delete from "Users";

call register_user('Nikon', 'Chigoya', 'nikon.chigoya@mail.ru', 'Nikon', )

select * from "Users";

select * from "Posts";

select delete_post(36);

select update_post(33, 'koiwoef', 'feiorjfierojfm', 4040, 39049, 'fweif', 'fiweifoj')

select create_comment(33, 198, 'Great')

select * from "Comments";

select update_comment(1, 'Not great');

CREATE OR REPLACE FUNCTION delete_comment(comment_id INT)
RETURNS VOID
AS $$
BEGIN
    DELETE FROM public."Comments"
    WHERE "Comment_id" = comment_id;
END;
$$ LANGUAGE plpgsql;

select delete_comment(1);



CREATE OR REPLACE FUNCTION generate_random_comments()
RETURNS VOID
AS $$
DECLARE
    i INTEGER := 1;
BEGIN
    WHILE i <= 100000 LOOP
        INSERT INTO public."Comments" ("Post_id", "User_id", "Text")
        VALUES (32, 198, 'Comment ' || i);
        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

select generate_random_comments();
delete from "Comments";
drop index "idx_comments_text";
create index "idx_comments_text" on "Comments" ("Text");
cluster "idx_comments_text" on "Comments";
select * from "Comments";
select * from "TagsRecipe";

EXPLAIN ANALYZE SELECT "Text" FROM "Comments" WHERE "Text" ILIKE '%Comment%';









































