DELIMITER $$

USE `udem_inventario`$$

DROP TRIGGER /*!50032 IF EXISTS */ `t_productos_salidas_bi`$$

CREATE
    TRIGGER t_productos_salidas_bi BEFORE INSERT ON productos_salidas
    FOR EACH ROW BEGIN

	/*Var Trabajo*/
	DECLARE v_saldo INT;
	DECLARE finished INTEGER DEFAULT 0;
	DECLARE v_feentrada DATETIME;
	DECLARE v_nmcantidad_disponible INT;
	DECLARE v_producto_salida_id INT;
	/*Cursor*/
	DECLARE c_fifo CURSOR FOR
		SELECT E.feentrada, EP.nmcantidad_disponible, EP.id
			FROM entradas E,entradas_productos EP
			WHERE E.id = EP.entrada_id
				AND EP.nmcantidad_disponible > 0
				AND EP.producto_id = new.producto_id
			ORDER BY 1 ASC;

	/*declare NOT FOUND handler*/
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

	/*INICIO TRIGGER*/
	SELECT nmcantidad_disponible
		INTO v_nmcantidad_disponible
		FROM productos
		WHERE id = new.producto_id;
	/*Si NO hay canitdad suficiente */
	IF new.nmcantidad > v_nmcantidad_disponible THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'La cantidad pedida supera el inventario';
	END IF;
	/* se debita de productos*/
	UPDATE productos
		SET nmcantidad_disponible = nmcantidad_disponible - new.nmcantidad
		WHERE id = new.producto_id;
	/*FIFO*/
	OPEN c_fifo;
	SET v_saldo = new.nmcantidad;
	label_c: LOOP
		FETCH c_fifo INTO v_feentrada ,
				v_nmcantidad_disponible,
				v_producto_salida_id;
		IF finished = 1 THEN
			LEAVE label_c;
		END IF;
		IF v_nmcantidad_disponible <= v_saldo THEN
			UPDATE entradas_productos
			  SET nmcantidad_disponible = 0
			  WHERE id = v_producto_salida_id;
		ELSE
			UPDATE entradas_productos
			  SET nmcantidad_disponible = nmcantidad_disponible - v_saldo
			  WHERE id = v_producto_salida_id;

			  LEAVE label_c;
		END IF;
		/*Resto lo entregado*/
		SET v_saldo = v_saldo - v_nmcantidad_disponible;
	END LOOP label_c;
	CLOSE c_fifo;
    END;
$$

DELIMITER ;
