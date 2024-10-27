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

CREATE OR REPLACE FUNCTION delete_media_from_comment(comment_id bigint, media_id bigint)
RETURNS void AS
$$
BEGIN
    -- удаляем запись из таблицы
    DELETE FROM public."MediaFilesForComments" WHERE "Comment_id" = comment_id AND "Media_id" = media_id;
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

CREATE OR REPLACE FUNCTION delete_comment(comment_id INT)
RETURNS VOID
AS $$
BEGIN
    DELETE FROM public."Comments"
    WHERE "Comment_id" = comment_id;
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