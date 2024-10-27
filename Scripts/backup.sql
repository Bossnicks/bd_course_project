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