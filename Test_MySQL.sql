SET GLOBAL log_bin_trust_function_creators = 1;
/*
Ejercicio 1
*/
use `test-mysql`;

drop trigger if exists documentTypeNew;

DELIMITER //
create trigger documentTypeNew
    after insert on documenttypes
    for each row
begin
    INSERT INTO documentnumbers (lastNumber, documentType) VALUES (CAST(50 as CHAR(50)), new.id);
end; //
DELIMITER ;

/* 2 estructrura función: crear factura
    - nombre del cliente
    - nombre del tipo de documento
*/
drop function if exists guardarFactura;

DELIMITER //

CREATE function guardarFactura(_persona VARCHAR(50), _tipoDocumento VARCHAR(50)) RETURNS VARCHAR(250)
BEGIN
    
    DECLARE IdNew int; -- esta variable es para asiganar el id de la factura que se guardó
    DECLARE salida varchar(250); -- variable de respuesta
    DECLARE d_type_id int;
    DECLARE n_docum int;
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIn
       RETURN  'Error al tratar de guarda la factura';
    END;
    SELECT d.id INTO d_type_id FROM documenttypes d WHERE name=_tipoDocumento;
    
    IF (d_type_id IS NULL) THEN
		INSERT INTO documenttypes(name) VALUES (_tipoDocumento);
    END IF;
    SELECT d.id INTO d_type_id FROM documenttypes d WHERE name=_tipoDocumento;
    SELECT CAST(lastNumber as UNSIGNED) INTO n_docum FROM documentnumbers WHERE id=d_type_id;
    INSERT INTO invoices (documentNumber, documentTypeId, person) VALUES (CAST((n_docum+1) as CHAR(50)), d_type_id, _persona);
    SELECT LAST_INSERT_ID() INTO IdNew;
    SET salida = concat('La factura se almacenó correctamente con el ID: ', CONVERT(IdNew, CHAR(50)));
    RETURN salida;
END
//

-- =============================================================

/* 3 agregar productos 
    - nombre del producto
    - valor del producto
    - id de la factura
*/
drop function if exists agregarProductos;

DELIMITER //

CREATE function agregarProductos(_producto VARCHAR(50), _valor DECIMAL(16, 4), _idFactura int) RETURNS VARCHAR(250)
BEGIN
    DECLARE salida varchar(250);
    DECLARE total_factura decimal(16, 4);

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIn
       RETURN  'Error al tratar de agregar productos a la factura';
    END;

    INSERT INTO invoicesdetails(itemName, invoiceId, value) VALUES (_producto, _idFactura,_valor);
    
    SELECT sum(value) INTO total_factura FROM invoicesdetails WHERE invoiceId=_idFactura GROUP BY invoiceId;
    
	UPDATE invoices SET total=total_factura WHERE id=_idFactura;
    
    SET salida = concat('El producto: ', _producto, ', fue agregado correctamente.');
    RETURN salida;
END
//

-- ===================================================================

/* 4 modificar o quitar productos de la factura
    - nombre del producto
    - valor del producto
    - id de la factura
    - acción: U = Modificar / D = Eliminar
*/
drop function if exists modificarQuitarProductos;

DELIMITER //

CREATE function modificarQuitarProductos(_producto VARCHAR(50), _valor DECIMAL(16, 4), _idFactura int, _action char(1)) RETURNS VARCHAR(250)
BEGIN
    DECLARE salida varchar(250);
    DECLARE nuevoValor DECIMAL(16, 4) default 0;

    IF (_action = 'U') THEN 
		UPDATE invoicesdetails SET value=_valor;
	ELSE
		DELETE FROM invoicesdetails WHERE itemName=_producto;
    END IF;
    
    SELECT sum(value) INTO nuevoValor FROM invoicesdetails WHERE invoiceId=_idFactura GROUP BY invoiceId;
    
	UPDATE invoices SET total=nuevoValor WHERE id=_idFactura;

    SET salida = concat('El producto: ', _producto, ', fue ', if(_action = 'U', 'modificado', 'eliminado'), ' correctamente.');
    RETURN salida;
END
//


/* 5. Crear una vista llamada reports
- fecha de la factura
- numero de la factura
- persona o cliente de la factura
- tipo de factura
- producto
- valor del producto
 */

create or replace view reports as
	SELECT i.date, i.documentNumber, i.person, dt.name, ide.itemName, ide.value 
    FROM invoices i INNER JOIN documenttypes dt ON i.documentTypeId=dt.id INNER JOIN invoicesdetails ide ON ide.invoiceId=i.id;
    
    
SELECT guardarFactura('Andres Baragan','pago') as Resultado;
SELECT agregarProductos('Pago de servicio', 113000, 1) as Resultado;
SELECT modificarQuitarProductos('Pago de servicio', 0, 1, 'D') as Resultado;
SELECT * FROM documentnumbers;
SELECT * FROM documenttypes;
SELECT * FROM invoices;
SELECT * FROM invoicesdetails;


