drop function "add_photo_to_comment";
drop function get_all_media_for_posts();
drop function get_ingridient_by_name;
Drop FUNCTION create_ingridient(text, text,  integer,integer,integer);
drop function get_ingridients();

select * from "Comments";
select * from "TagsRecipe";
select * from "Tag";
SELECT * FROM "Ingridients";
select * from "Users";
select * from "Posts";
SELECT * FROM "Users" WHERE levenshtein("Name", 'Nikolay') < 4;

select get_all_media_for_posts();
select getusers();
select get_all_media_for_comments();
select get_media_for_post(1);
select get_tag_description('dr');
select get_all_tags();
SELECT add_tag('example', 'This is an example tag');
SELECT create_ingridient('СОЛЬ', 'ГР', 0.0, 0.0, 0.0);
select get_ingridient_by_name('СОЛЬ');
SELECT delete_tag('example');
select add_subscription(31, 1);
SELECT * FROM get_ingridients();
select delete_post(36);
select update_post(33, 'koiwoef', 'feiorjfierojfm', 4040, 39049, 'fweif', 'fiweifoj')
select create_comment(33, 198, 'Great')
select update_comment(1, 'Not great');
select delete_comment(1);

delete from "Tag";
DELETE FROM "Ingridients";
delete from "Users";
delete from "Ingridients";
delete from "Users";

CALL update_ingridient(1, 'соль', 'гр', 0, 0, 0);
call update_tag_description('example', 'example');
call register_user('Nikon', 'Chigoya', 'nikon.chigoya1@mail.ru', 'Nikon02052023', null);
call register_user('Nikon', 'chch', 'fhnrhf', 'jdnhndedSWD222', null)
call add_ingridient('Carrot', 'gram', 1, 0, 6);









































