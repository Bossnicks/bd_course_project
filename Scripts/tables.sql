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