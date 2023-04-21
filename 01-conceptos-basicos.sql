/* 
Teniendo en cuenta los archivos:
- softpymes_test.png
- script-prueba-1.sql
Generar scripts que realicen las siguientes consultas:
*/
SET GLOBAL log_bin_trust_function_creators = 1;
SET SQL_SAFE_UPDATES = 0;
/* 1. Consultar los items que pertenezcan a la compañia con ID #3 (debe utilizar INNER JOIN) */
SELECT i.id, i.name, i.cost,i.price FROM items i INNER JOIN companies c ON i.companyId=c.id WHERE c.id=3;

/* 2. Mostrar los items para los cuales su precio se encuentre en el rango 70000 a 90000*/
SELECT * FROM items i WHERE i.price BETWEEN 70000 AND 90000;

/* 3. Mostrar los items que en el nombre inicien con la letra "A" */
SELECT * FROM items i WHERE i.name LIKE 'A%';

/* 4. Mostrar los items que tengan relacionado el color Rojo */
SELECT * FROM items i INNER JOIN colors c ON i.colorId=c.id WHERE c.name='ROJO';

/* 5. Se requiere asignar un precio a los items cuyo precio sea NULL, 
el precio a agregar debe ser calculado de la siguiente forma: costo del item + 10.000*/
UPDATE items SET price=cost+10000 WHERE price=0;

/* 6. Incrementar el precio de los items en un 20% */
UPDATE items SET price=price*1.2;

/* 7. Consultar los items por nombre y limitar la consulta para que sea paginada por un 
limite de 5 registros por página */
SELECT i.name FROM items i LIMIT 1,5;
/* 8. Eliminar los items que pertenezcan a la compañía con ID #1  (Debe usar inner join)*/
DELETE i FROM items i INNER JOIN companies c ON i.companyId=c.id WHERE c.id=1;

/* 9. Eliminar los items que tengan el costo menor a 10.000 */
DELETE FROM items WHERE cost < 10000;

/* 10. Cree una función que permita insertar registros en la tabla colores*/

drop function if exists insertarColor;

DELIMITER //

CREATE function test_mysql.insertarColor(_code VARCHAR(3), _name VARCHAR(26)) RETURNS VARCHAR(250)
BEGIN
    DECLARE salida varchar(250);

    INSERT INTO colors (code, name) VALUES (_code, _name);
    
    SET salida = concat('Se registró correctamente', _name);
    RETURN salida;
END
//
SELECT insertarColor('123', 'prueba') as Resultado;
SELECT * FROM colors;

/* 11. Eliminar todos los datos de la tabla colores*/
DELETE FROM colors;

/* 12. Agregar un campo llamado "isdelete" en la tabla items, que no permita ser NULL,
debe tener un valor por defecto = 0 debe ser un campo númerico, tener un comentario que diga
(0=No se borra / 1=Se borra) cantidad permitida de caracteres = 1 */
ALTER TABLE items ADD COLUMN isdelete VARCHAR(1) not NULL default 0 COMMENT '0=No se borra / 1=Se borra';