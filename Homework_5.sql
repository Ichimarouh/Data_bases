-- Операторы, фильтрация, сортировка и ограничение.

-- 1. Пусть в таблице users поля created_at и updated_at оказались незаполненными. 
-- Заполните их текущими датой и временем.

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME,
  updated_at DATETIME
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at, created_at, updated_at) VALUES
  ('Michael', '1984-07-17', NULL, NULL),
  ('Helga', '1989-10-05', NULL, NULL),
  ('Otto', '1987-02-15', NULL, NULL);
  
UPDATE users SET created_at = NOW(), updated_at = NOW();
  
DESCRIBE users;
  
-- 2. Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом VARCHAR
-- и в них долгое время помещались значения в формате 20.10.2017 8:10. 
-- Необходимо преобразовать поля к типу DATETIME, сохранив введённые ранее значения.

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at VARCHAR(255),
  updated_at VARCHAR(255)
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at, created_at, updated_at) VALUES
  ('Michael', '1984-07-17', '17.07.2018 14:38', '19.07.2019 10:21'),
  ('Helga', '1989-10-05', '10.05.2018 19:08', '11.09.2019 19:55'),
  ('Otto', '1987-02-15', '10.08.2017 15:01', '14.08.2019 11:28');

UPDATE users SET
  created_at = STR_TO_DATE(created_at, '%d.%m.%Y %k:%i'),
  updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %k:%i');

ALTER TABLE users CHANGE created_at created_at DATETIME DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE users CHANGE
  updated_at updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

DESCRIBE users;

-- 3. В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 
-- 0, если товар закончился и выше нуля, если на складе имеются запасы. 
-- Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value. 
-- Однако нулевые запасы должны выводиться в конце, после всех записей.

CREATE TABLE IF NOT EXISTS store (
  id SERIAL PRIMARY KEY,
  store_id INT UNSIGNED,
  product_id INT UNSIGNED,
  value INT UNSIGNED COMMENT 'Запас товара',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Запасы на складе';

INSERT INTO store (store_id, product_id, value) VALUES
  (1, 198, 0),
  (1, 208, 120),
  (1, 151, 14),
  (1, 192, 0),
  (1, 245, 58);
  
SELECT * FROM store ORDER BY IF(value > 0, 0, 1), value;

SELECT * FROM store ORDER BY value = 0, value;
 
-- 4. (по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. 
-- Месяцы заданы в виде списка английских названий (may, august).

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at VARCHAR(255),
  updated_at VARCHAR(255)
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at, created_at, updated_at) VALUES
  ('Michael', '1984-07-17', '17.07.2018 14:38', '19.07.2019 10:21'),
  ('Helga', '1989-10-05', '10.05.2018 19:08', '11.09.2019 19:55'),
  ('Otto', '1987-02-15', '10.08.2017 15:01', '14.08.2019 11:28'),
  ('Hans', '1986-05-11', '11.06.2017 11:01', '15.12.2018 17:34'),
  ('Bruna', '1986-08-23', '15.01.2018 13:33', '14.03.2018 13:02');
  
SELECT name FROM users WHERE DATE_FORMAT(birthday_at, '%M') IN ('may', 'august');

-- Агрегация данных.

-- 1. Подсчитайте средний возраст пользователей в таблице users.

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at VARCHAR(255),
  updated_at VARCHAR(255)
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at, created_at, updated_at) VALUES
  ('Michael', '1984-07-17', '17.07.2018 14:38', '19.07.2019 10:21'),
  ('Helga', '1989-10-05', '10.05.2018 19:08', '11.09.2019 19:55'),
  ('Otto', '1987-02-15', '10.08.2017 15:01', '14.08.2019 11:28'),
  ('Hans', '1986-05-11', '11.06.2017 11:01', '15.12.2018 17:34'),
  ('Bruna', '1986-08-23', '15.01.2018 13:33', '14.03.2018 13:02');

SELECT AVG(TIMESTAMPDIFF(YEAR, birthday_at, NOW())) AS age FROM users;
	  
-- 2. Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
-- Следует учесть, что необходимы дни недели текущего года, а не года рождения.

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at VARCHAR(255),
  updated_at VARCHAR(255)
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at, created_at, updated_at) VALUES
  ('Michael', '1984-07-17', '17.07.2018 14:38', '19.07.2019 10:21'),
  ('Helga', '1989-10-05', '10.05.2018 19:08', '11.09.2019 19:55'),
  ('Otto', '1987-02-15', '10.08.2017 15:01', '14.08.2019 11:28'),
  ('Hans', '1986-05-11', '11.06.2017 11:01', '15.12.2018 17:34'),
  ('Bruna', '1986-08-23', '15.01.2018 13:33', '14.03.2018 13:02');

SELECT DATE_FORMAT(DATE(CONCAT_WS('-', YEAR(NOW()), MONTH(birthday_at), DAY(birthday_at))), '%W') AS day,
  COUNT(*) AS total FROM users GROUP BY day ORDER BY total DESC;
