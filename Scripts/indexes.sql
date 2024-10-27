drop index "idx_comments_text";
create index "idx_comments_text" on "Comments" ("Text");
cluster "idx_comments_text" on "Comments";

CREATE INDEX "idx_users_name_age" ON "Users" ("Name");
drop index "idx_users_name_age";

CREATE INDEX "idx_posts_name" on "Posts" ("Name");

CREATE INDEX "idx_ingridients_name" on "Ingridients" ("Name");
CLUSTER "Ingridients" USING idx_ingridients_name;

CREATE INDEX "idx_tag_tag" on "Tag" ("Tag");
CLUSTER "Tag" USING idx_tag_tag;