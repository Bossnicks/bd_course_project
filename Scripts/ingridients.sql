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

CREATE OR REPLACE FUNCTION create_ingridient(name text, unit_of_measurement text, protein real, fat real, carbonhydrates real)
RETURNS void AS
$$
BEGIN
    INSERT INTO public."Ingridients" ("Name", "Unit_of_measurement", "Protein", "Fat", "Carbonhydrates")
    VALUES (name, unit_of_measurement, protein, fat, carbonhydrates);
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

CREATE OR REPLACE FUNCTION delete_ingridient(ingridient_id integer)
RETURNS void AS
$$
BEGIN
    DELETE FROM public."Ingridients" WHERE "Ingridient_id" = ingridient_id;
END;
$$
LANGUAGE plpgsql;

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