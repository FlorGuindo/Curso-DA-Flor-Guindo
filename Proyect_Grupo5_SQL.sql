USE iron_lab5;
SELECT *
FROM account;
SELECT *
FROM betting;
SELECT *
FROM customer;
SELECT *
FROM product;
-- Pregunta 01: Usando la tabla o pestaña de clientes, por favor escribe una consulta SQL que muestre Título, Nombre y Apellido y Fecha de Nacimiento para cada uno de los clientes. No necesitarás hacer nada en Excel para esta.
SELECT title as 'Titulo', FirstName as 'Nombre', LastName as 'Apellido', DateOfBirth as 'Fecha de Nacimiento'
FROM customer;
-- Pregunta 02: Usando la tabla o pestaña de clientes, por favor escribe una consulta SQL que muestre el número de clientes en cada grupo de clientes (Bronce, Plata y Oro). Puedo ver visualmente que hay 4 Bronce, 3 Plata y 3 Oro pero si hubiera un millón de clientes ¿cómo lo haría en Excel?
SELECT CustomerGroup, COUNT(*) AS TotalCustomers
FROM Customer
GROUP BY CustomerGroup;
-- Pregunta 03: El gerente de CRM me ha pedido que proporcione una lista completa de todos los datos para esos clientes en la tabla de clientes pero necesito añadir el código de moneda de cada jugador para que pueda enviar la oferta correcta en la moneda correcta. Nota que el código de moneda no existe en la tabla de clientes sino en la tabla de cuentas. Por favor, escribe el SQL que facilitaría esto. ¿Cómo lo haría en Excel si tuviera un conjunto de datos mucho más grande?
SELECT c.*, a.CurrencyCode
FROM Customer c
JOIN Account a ON c.CustId = a.CustId;
-- Pregunta 04: Ahora necesito proporcionar a un gerente de producto un informe resumen que muestre, por producto y por día, cuánto dinero se ha apostado en un producto particular. TEN EN CUENTA que las transacciones están almacenadas en la tabla de apuestas y hay un código de producto en esa tabla que se requiere buscar (classid & categoryid) para determinar a qué familia de productos pertenece esto. Por favor, escribe el SQL que proporcionaría el informe. Si imaginas que esto fue un conjunto de datos mucho más grande en Excel, ¿cómo proporcionarías este informe en Excel?
SELECT b.BetDate, p.product, SUM(b.Bet_Amt) AS TotalBet
FROM Betting b
JOIN Product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
GROUP BY b.BetDate, p.product
ORDER BY p.product, b.BetDate;

-- Pregunta 05: Acabas de proporcionar el informe de la pregunta 4 al gerente de producto, ahora él me ha enviado un correo electrónico y quiere que se cambie. ¿Puedes por favor modificar el informe resumen para que solo resuma las transacciones que ocurrieron el 1 de noviembre o después y solo quiere ver transacciones de Sportsbook. Nuevamente, por favor escribe el SQL abajo que hará esto. Si yo estuviera entregando esto vía Excel, ¿cómo lo haría?
SELECT b.BetDate, p.product, SUM(b.Bet_Amt) AS TotalBet
FROM Betting b
JOIN Product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
WHERE b.BetDate >= '2012-11-01' AND p.product = 'Sportsbook'
GROUP BY b.BetDate
ORDER BY b.BetDate;

-- Pregunta 06: Como suele suceder, el gerente de producto ha mostrado su nuevo informe a su director y ahora él también quiere una versión diferente de este informe. Esta vez, quiere todos los productos pero divididos por el código de moneda y el grupo de clientes del cliente, en lugar de por día y producto. También le gustaría solo transacciones que ocurrieron después del 1 de diciembre. Por favor, escribe el código SQL que hará esto.
SELECT a.CurrencyCode, c.CustomerGroup, p.product, SUM(b.Bet_Amt) AS TotalBet
FROM Betting b
JOIN Product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
JOIN Account a ON b.AccountNo = a.AccountNo
JOIN Customer c ON a.CustId = c.CustId
WHERE b.BetDate > '2012-12-01'
GROUP BY a.CurrencyCode, c.CustomerGroup, p.product
ORDER BY a.CurrencyCode, c.CustomerGroup, p.product;

-- Pregunta 07: Nuestro equipo VIP ha pedido ver un informe de todos los jugadores independientemente de si han hecho algo en el marco de tiempo completo o no. En nuestro ejemplo, es posible que no todos los jugadores hayan estado activos. Por favor, escribe una consulta SQL que muestre a todos los jugadores Título, Nombre y Apellido y un resumen de su cantidad de apuesta para el período completo de noviembre.
SELECT c.Title, c.FirstName, c.LastName, COALESCE(SUM(b.Bet_Amt), 0) AS TotalBet
FROM Customer c
LEFT JOIN Account a ON c.CustId = a.CustId
LEFT JOIN Betting b ON a.AccountNo = b.AccountNo AND b.BetDate BETWEEN '2012-11-01' AND '2012-11-30'
GROUP BY c.Title, c.FirstName, c.LastName;

-- Pregunta 08: Nuestros equipos de marketing y CRM quieren medir el número de jugadores que juegan más de un producto. ¿Puedes por favor escribir 2 consultas, una que muestre el número de productos por jugador y otra que muestre jugadores que juegan tanto en Sportsbook como en Vegas?
-- 8.1
SELECT c.Title, CONCAT(c.FirstName, ' ', c.LastName) as 'Nombre y apellido', COUNT(DISTINCT b.product) AS ProductCount
FROM customer c
JOIN Account a ON c.CustId = a.CustId
JOIN Betting b ON a.AccountNo = b.AccountNo
GROUP BY c.Title, c.FirstName, c.LastName
ORDER BY ProductCount DESC, c.LastName;
-- 8.2
SELECT c.Title, CONCAT(c.FirstName, ' ', c.LastName) as 'Nombre y apellido'
FROM betting b
JOIN product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
JOIN account a ON b.AccountNo = a.AccountNo
JOIN customer c ON a.CustId = c.CustId
WHERE b.Product IN ('Sportsbook', 'Vegas')
GROUP BY c.Title, c.FirstName, c.LastName
HAVING COUNT(DISTINCT b.Product) = 2;

-- Pregunta 09: Ahora nuestro equipo de CRM quiere ver a los jugadores que solo juegan un producto, por favor escribe código SQL que muestre a los jugadores que solo juegan en sportsbook, usa bet_amt > 0 como la clave. Muestra cada jugador y la suma de sus apuestas para ambos productos.
SELECT c.Title, CONCAT(c.FirstName, ' ', c.LastName) as 'Nombre y apellido', SUM(b.Bet_Amt) AS TotalBet
FROM betting b
JOIN account a ON b.AccountNo = a.AccountNo
JOIN customer c ON a.CustId = c.CustId
WHERE b.Product = 'Sportsbook' AND b.bet_amt > 0
GROUP BY c.Title, c.FirstName, c.LastName
HAVING COUNT(DISTINCT b.Product) = 1
ORDER BY TotalBet DESC;

-- Pregunta 10: La última pregunta requiere que calculemos y determinemos el producto favorito de un jugador. Esto se puede determinar por la mayor cantidad de dinero apostado. Por favor, escribe una consulta que muestre el producto favorito de cada jugador

SELECT c.Title, CONCAT(c.FirstName, ' ', c.LastName) as Nombre, p.product, SUM(b.Bet_Amt) AS TotalBet
FROM betting b
JOIN product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
JOIN account a ON b.AccountNo = a.AccountNo
JOIN customer c ON a.CustId = c.CustId
WHERE b.bet_amt > 0
GROUP BY Nombre, p.product
ORDER BY Nombre, TotalBet DESC;

WITH RankedBets AS (
    SELECT c.Title, CONCAT(c.FirstName, ' ', c.LastName) AS Nombre, p.product, SUM(b.Bet_Amt) AS TotalBet,
           ROW_NUMBER() OVER (PARTITION BY CONCAT(c.FirstName, ' ', c.LastName) ORDER BY SUM(b.Bet_Amt) DESC) AS Ranking
    FROM betting b
    JOIN product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
    JOIN account a ON b.AccountNo = a.AccountNo
    JOIN customer c ON a.CustId = c.CustId
    WHERE b.Bet_Amt > 0
    GROUP BY c.Title, c.FirstName, c.LastName, p.product
)
SELECT Title, Nombre, product, TotalBet
FROM RankedBets
WHERE ranking = 1
ORDER BY TotalBet DESC;

-- Pregunta 11: Escribe una consulta que devuelva a los 5 mejores estudiantes basándose en el GPA

SELECT *
FROM student;

SELECT student_id, student_name, RANK() OVER(ORDER BY GPA DESC) AS 'Rank', gpa
FROM student_school
LIMIT 5;

-- Pregunta 12: Escribe una consulta que devuelva el número de estudiantes en cada escuela. (¡una escuela debería estar en la salida incluso si no tiene estudiantes!)

SELECT sc.school_id, COUNT(st.student_id)
FROM school sc
LEFT JOIN student st ON sc.school_id = st.school_id
GROUP BY school_id
HAVING sc.school_id <> '-----------';

-- Pregunta 13: Escribe una consulta que devuelva los nombres de los 3 estudiantes con el GPA más alto de cada universidad.

SELECT sc.school_id, st.student_name,
ROW_NUMBER() OVER(PARTITION BY sc.school_id ORDER BY GPA DESC) AS 'Rank', gpa
FROM school sc
LEFT JOIN student st ON sc.school_id = st.school_id
WHERE st.gpa IS NOT NULL
HAVING sc.school_id <> '-----------' AND 'Rank' <= 3
ORDER BY school_id, 'Rank';

