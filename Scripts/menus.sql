-- Функция для создания нового меню
CREATE OR REPLACE FUNCTION create_menu(
    start_date date,
    end_date date,
    dish_id bigint,
    day_of_week integer,
    user_id bigint
)
    RETURNS bigint AS $$
DECLARE
    menu_id bigint;
BEGIN
    INSERT INTO public."Menu" ("Start_date", "End_date", "Dish_id", "Day_of_week", "User_id")
    VALUES (start_date, end_date, dish_id
	, day_of_week, user_id)
RETURNING "Menu_id" INTO menu_id;
RETURN menu_id;
END;
$$ LANGUAGE plpgsql;


-- Функция для получения информации о меню
CREATE OR REPLACE FUNCTION get_menu(menu_id bigint)
RETURNS TABLE (
"Menu_id" bigint,
"Start_date" date,
"End_date" date,
"Dish_id" bigint,
"Day_of_week" integer,
"Created_at" timestamp with time zone,
"Updated_at" timestamp with time zone,
"User_id" bigint
) AS $$
BEGIN
RETURN QUERY
SELECT *
FROM public."Menu"
WHERE "Menu_id" = menu_id;
END;
$$ LANGUAGE plpgsql;
-- Функция для обновления информации о меню

CREATE OR REPLACE FUNCTION update_menu(
menu_id bigint,
start_date date,
end_date date,
dish_id bigint,
day_of_week integer
)
RETURNS void AS $$
BEGIN
UPDATE public."Menu"
SET "Start_date" = start_date,
"End_date" = end_date,
"Dish_id" = dish_id,
"Day_of_week" = day_of_week,
"Updated_at" = CURRENT_TIMESTAMP
WHERE "Menu_id" = menu_id;
END;
$$ LANGUAGE plpgsql;