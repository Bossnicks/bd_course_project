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

EXPLAIN ANALYZE SELECT "Text" FROM "Comments" WHERE "Text" ILIKE '%Comment%';