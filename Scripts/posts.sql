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

CREATE OR REPLACE FUNCTION delete_media_from_post(post_id bigint, media_id bigint)
RETURNS void AS
$$
BEGIN
    -- удаляем запись из таблицы
    DELETE FROM public."MediaFilesForPosts" WHERE "Post_id" = post_id AND "Media_id" = media_id;
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