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
