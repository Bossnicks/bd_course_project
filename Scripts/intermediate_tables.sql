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