using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Npgsql;
using System;
using System.Data;
using Microsoft.Win32;
using System.IO;
using System.Drawing;
using System.Windows.Forms;
using System.Threading;
using System.Diagnostics;


namespace Project1
{
    internal class Program
    {
        private static string token;
        [STAThreadAttribute]
        public static void Main()
        {
            bool exit = false;
            while (!exit)
            {
                Console.WriteLine("Выберите действие:");
                Console.WriteLine("1. Создать пользователя");
                Console.WriteLine("2. Получить список пользователей");
                Console.WriteLine("3. Авторизация");
                Console.WriteLine("4. Создание поста");
                Console.WriteLine("5. Получение тэгов");
                Console.WriteLine("0. Выйти");

                string input = Console.ReadLine();

                switch (input)
                {
                    case "1":
                        CreateUserMenu();
                        break;
                    case "2":
                        getUsers();
                        break;
                    case "3":
                        authUser();
                        break;
                    case "m":
                        PerformAuthorizedOperations();
                        break;
                    case "4":
                        CreatePostMenu();
                        break;
                    case "5":
                        GetTags();
                        break;
                    case "0":
                        exit = true;
                        break;
                    default:
                        Console.WriteLine("Некорректный ввод. Пожалуйста, выберите действие из списка.");
                        break;
                }

                Console.WriteLine();
            }
        }
        static void connectTagWithPost(long postId) {
            string[] tags = GetTags();
            Console.WriteLine("Выберите номера тэгов которые хотите добавить к вашему блюду (,)");
            for (int i = 0; i < tags.Length; i++)
            {
                Console.WriteLine(i + 1 + ") " +  tags[i]);
            }
            string input = Console.ReadLine();
            string[] tagNumbers = input.Split(',');
            string[] newTags = new string[tagNumbers.Length];
            List<int> selectedTags = new List<int>();
            int j = 0;
            foreach (string tagNumber in tagNumbers)
            {
                if (int.TryParse(tagNumber.Trim(), out int number))
                {
                    if (number >= 1 && number <= tags.Length)
                    {
                        newTags[j] = tags[number - 1];
                        j++;
                    }
                    else
                    {
                        Console.WriteLine("Неверный номер тэга: " + tagNumber);
                    }
                }
                else
                {
                    Console.WriteLine("Неверный формат номера тэга: " + tagNumber);
                }
            }

             // Получить идентификатор поста, к которому добавляются тэги
            InsertTagsForPost(postId, newTags);
        }
        static void InsertTagsForPost(long postId, string[] newTags)
        {
            NpgsqlConnection connection = new NpgsqlConnection("Server=localhost;Port=5432;Database=culinary_blog_db;User Id=postgres;Password=1111;");
            connection.Open();

            try
            {
                foreach (string tag in newTags)
                {
                    string queryInsertTag = "INSERT INTO \"TagsRecipe\" (\"Post_id\", \"Tag\") VALUES (@postId, @tagId)"; ;

                    NpgsqlCommand commandInsertTag = new NpgsqlCommand(queryInsertTag, connection);

                    // Получаем TagID по номеру тэга

                    // Добавляем параметры запроса
                    commandInsertTag.Parameters.AddWithValue("@tagId", tag);
                    commandInsertTag.Parameters.AddWithValue("@postId", postId);

                    // Выполняем запрос
                    commandInsertTag.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }

            connection.Close();
        }

        static void authUser()
        {
            Console.Write("Email: ");
            string email = Console.ReadLine();

            Console.Write("Пароль: ");
            string password = Console.ReadLine();

            // Вызовите функцию createUser для регистрации нового пользователя
            Login(email, password);
        }
        static string[] GetTags()
        {
            NpgsqlConnection connection = new NpgsqlConnection("Server=localhost;Port=5432;Database=culinary_blog_db;User Id=postgres;Password=1111;");
            connection.Open();

            List<string> tags = new List<string>();

            try
            {
                string queryGetTags = "SELECT \"Tag\" FROM \"Tag\"";
                NpgsqlCommand commandGetTags = new NpgsqlCommand(queryGetTags, connection);

                using (NpgsqlDataReader reader = commandGetTags.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string tag = reader.GetString(0);
                        tags.Add(tag);
                    }
                }
                foreach (string tag in tags)
                {
                    Console.WriteLine(tag);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }

            connection.Close();

            return tags.ToArray();
        }
        static void PerformAuthorizedOperations()
        {
            // Проверяем наличие токена
            if (!string.IsNullOrEmpty(token))
            {
                // Ваш код для выполнения операций от имени авторизованного пользователя
                // Например, получение информации о пользователе или выполнение других действий в базе данных
                // Используйте токен для аутентификации пользователя при выполнении операций

                NpgsqlConnection connection = new NpgsqlConnection("Server=localhost;Port=5432;Database=culinary_blog_db;User Id=postgres;Password=1111;");
                connection.Open();

                try
                {
                    // Пример выполнения операций от имени авторизованного пользователя
                    string queryGetUserInfo = "SELECT u.* FROM \"Users\" u INNER JOIN \"Tokens\" t ON u.\"User_id\" = t.\"User_id\" WHERE t.\"Token\" = @token;";
                    NpgsqlCommand commandGetUserInfo = new NpgsqlCommand(queryGetUserInfo, connection);
                    commandGetUserInfo.Parameters.AddWithValue("@token", token);

                    // Выполнение операции и получение результатов
                    NpgsqlDataReader reader = commandGetUserInfo.ExecuteReader();

                    // Обработка результатов
                    while (reader.Read())
                    {
                        // Пример чтения данных о пользователе
                        string name = reader.GetString(1);
                        string surname = reader.GetString(2);

                        Console.WriteLine($"Добро пожаловать {name} {surname}");
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                }
                finally
                {
                    connection.Close();
                }
            }
            else
            {
                Console.WriteLine("Пользователь не авторизован.");
            }
        }

        static string Login(string email, string password)
        {
            NpgsqlConnection connection = new NpgsqlConnection("Server=localhost;Port=5432;Database=culinary_blog_db;User Id=postgres;Password=1111;");
            connection.Open();

            try
            {
                // Используем параметры запроса для безопасной передачи значений
                string queryLogin = "SELECT auth_user(@email, @password)";
                NpgsqlCommand commandLogin = new NpgsqlCommand(queryLogin, connection);

                // Добавляем параметры запроса
                commandLogin.Parameters.AddWithValue("@email", email);
                commandLogin.Parameters.AddWithValue("@password", password);

                // Выполняем запрос и получаем токен
                token = commandLogin.ExecuteScalar().ToString();
                PerformAuthorizedOperations();
                return token;

            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return null;
            }
            finally
            {
                connection.Close();
            }
        }
        static void CreatePostMenu()
        {
            if (token == null)
            {
                Console.WriteLine("Необходимо авторизоваться для создания поста!");
                return;
            }
            Console.WriteLine("Создание нового поста");

            Console.Write("Введите название: ");
            string name = Console.ReadLine();

            Console.Write("Введите описание: ");
            string description = Console.ReadLine();

            Console.Write("Введите время приготовления (в минутах): ");
            int cookingTime = int.Parse(Console.ReadLine());

            Console.Write("Введите количество порций: ");
            int count = int.Parse(Console.ReadLine());

            Console.Write("Введите инструкции: ");
            string instructions = Console.ReadLine();

            Console.Write("Введите кухню: ");
            string kitchen = Console.ReadLine();

            // Вызов функции InsertPost с передачей пользовательских данных
            InsertPost(name, description, cookingTime, count, instructions, kitchen);
        }
        static void CreateUserMenu()
        {
            Console.WriteLine("Введите имя пользователя:");
            string name = Console.ReadLine();

            Console.WriteLine("Введите фамилию пользователя:");
            string surname = Console.ReadLine();

            Console.WriteLine("Введите email пользователя:");
            string email = Console.ReadLine();

            Console.WriteLine("Введите пароль пользователя:");
            string password = Console.ReadLine();

            Console.WriteLine("Хотите установить аватарку? (y/n)");
            string input = Console.ReadLine();

            string imagePath = string.Empty;
            if (input.ToLower() == "y")
            {
                // Открываем окно выбора файла
                OpenFileDialog openFileDialog = new OpenFileDialog();
                openFileDialog.Filter = "Изображения (*.jpg, *.jpeg, *.png)|*.jpg;*.jpeg;*.png";
                openFileDialog.Title = "Выберите изображение пользователя";

                DialogResult result = openFileDialog.ShowDialog();
                if (result == DialogResult.OK)
                {
                    imagePath = openFileDialog.FileName;
                }
            }

            //imagePath = null;

            createUser(name, surname, email, password, imagePath);
        }
        static void createUser(string name, string surname, string email, string password, string imagePath)
        {
            NpgsqlConnection connection = new NpgsqlConnection("Server=localhost;Port=5432;Database=culinary_blog_db;User Id=postgres;Password=1111;");
            connection.Open();

            try
            {
                byte[] imageBytes = File.ReadAllBytes(imagePath);

                if (imagePath == null)
                {
                    imagePath = "C:\\Users\\HP\\Desktop\\Рабочий стол\\unknown.jpeg";
                }

                // Используем параметры запроса для безопасной передачи значений
                string queryRegisterUser = "SELECT register_user(@name, @surname, @email, @password, @avatar)";
                NpgsqlCommand commandRegisterUsers = new NpgsqlCommand(queryRegisterUser, connection);

                // Добавляем параметры запроса
                commandRegisterUsers.Parameters.AddWithValue("@name", name);
                commandRegisterUsers.Parameters.AddWithValue("@surname", surname);
                commandRegisterUsers.Parameters.AddWithValue("@email", email);
                commandRegisterUsers.Parameters.AddWithValue("@password", password);
                commandRegisterUsers.Parameters.AddWithValue("@avatar", imageBytes);

                // Выполняем запрос
                commandRegisterUsers.ExecuteNonQuery();
            }
            catch(Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
            connection.Close();
        }

        static void getUsers()
        {
            NpgsqlConnection connection = new NpgsqlConnection("Server=localhost;Port=5432;Database=culinary_blog_db;User Id=postgres;Password=1111;");
            connection.Open();
            try
            {
                string queryGetUsers = "SELECT \"Name\", \"Avatar\", \"Email\" FROM \"Users\"";
                NpgsqlCommand commandGetUsers = new NpgsqlCommand(queryGetUsers, connection);

                // Используем NpgsqlDataAdapter для выполнения запроса и получения результатов
                NpgsqlDataAdapter dataAdapter = new NpgsqlDataAdapter(commandGetUsers);
                DataTable dataTable = new DataTable();
                dataAdapter.Fill(dataTable);
                string directoryPath = @"C:\Users\HP\Desktop\Интерфейс к БД\Project1\images";
                if (Directory.Exists(directoryPath))
                {
                    // Получаем список файлов в папке
                    string[] files = Directory.GetFiles(directoryPath);

                    // Удаляем каждый файл
                    foreach (string file in files)
                    {
                        File.Delete(file);
                    }
                }
                foreach (DataRow row in dataTable.Rows)
                {
                    string name = row["Name"].ToString();
                    byte[] imageBytes = (byte[])row["Avatar"];
                    string email = row["Email"].ToString();

                    if (imageBytes != null)
                    {
                        Directory.CreateDirectory(directoryPath);
                        string filePath = Path.Combine(directoryPath, $"{email}_avatar.jpg");
                        File.WriteAllBytes(filePath, imageBytes);
                    }

                    Console.WriteLine($"Name: {name}, Email: {email}");
                }

            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
            connection.Close();
        }
        static void InsertPost(string name, string description, int cookingTime, int count, string instructions, string kitchen)
        {
            NpgsqlConnection connection = new NpgsqlConnection("Server=localhost;Port=5432;Database=culinary_blog_db;User Id=postgres;Password=1111;");
            connection.Open();

            long postId;

            try
            {
                string queryAuth = $"select get_user_id_by_token('{token}')";
                NpgsqlCommand commandAuth = new NpgsqlCommand(queryAuth, connection);
                commandAuth.Parameters.AddWithValue("@token", token);
                int authorId = (int)commandAuth.ExecuteScalar();
                string queryInsertPost = @"select create_post(@name, @description, @cookingTime, @count, @instructions, @authorId, @kitchen)";

                NpgsqlCommand commandInsertPost = new NpgsqlCommand(queryInsertPost, connection);

                commandInsertPost.Parameters.AddWithValue("@name", name);
                commandInsertPost.Parameters.AddWithValue("@description", description);
                commandInsertPost.Parameters.AddWithValue("@cookingTime", cookingTime);
                commandInsertPost.Parameters.AddWithValue("@count", count);
                commandInsertPost.Parameters.AddWithValue("@instructions", instructions);
                commandInsertPost.Parameters.AddWithValue("@authorId", authorId);
                commandInsertPost.Parameters.AddWithValue("@kitchen", kitchen);

                // Выполняем запрос и получаем значение "Post_id" с помощью ExecuteScalar
                postId = (long)commandInsertPost.ExecuteScalar();
                connectTagWithPost(postId);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }

            connection.Close();
        }

    }

}
