BEGIN
	/*--- var trabajo ---*/
	 declare no_more_rows boolean default false;
	 /*Control productos*/
	 declare v_nmcantidad int;
	 declare v_psventa dec(10,2);
	 /*Control fifo*/
	 declare v_entrada_producto_id int;
	 declare v_feentrada datetime;
	 declare v_nmcantidad_disponible int;
	 DECLARE v_pendiente INT;
	/*--- cursores ---*/
	 declare cursor1 cursor for
           select entradas_productos.id, nmcantidad_disponible, feentrada
		from entradas_productos, entradas
		where entradas.id = entradas_productos.entrada_id and
			producto_id = new.producto_id and
			nmcantidad_disponible > 0
		order by 3 asc;
	/*--- control ---*/
	declare continue handler for not found
            set no_more_rows := true;
	/*-------- 1-Validar Inventario ---------*/
	SELECT nmcantidad, psventa
		into v_nmcantidad,v_psventa
		FROM productos
		WHERE id = new.producto_id;

	if new.nmcantidad > v_nmcantidad then
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'No hay cantidad suficiente en el inventario';
	end if;
        IF new.psvalor_venta < v_psventa THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Valor venta inferior al permitido';
	END IF;
	/*-------- 2-Restar de Inventario ---------*/
	update productos
		set nmcantidad = nmcantidad - new.nmcantidad
		where id = new.producto_id;

  /*---- Insertar en tabla de compras-----*/

	SET v_nmcantidad_producto = (SELECT nmcantidad from productos where id = new.producto_id);
	SET v_preorden = (select preorden from productos where id = new.producto_id);
	SET v_proveedor_id = (select persona_id from productos where id = new.producto_id);
	if v_nmcantidad_producto < v_preorden then
		SET v_insert_plan = (SELECT COUNT(*) FROM planes_compras WHERE producto_id = new.producto_id group by producto_id);

		if v_insert_plan IS NULL then
			insert into planes_compras (producto_id, persona_id) values(new.producto_id, v_proveedor_id);
		elseif (v_proveedor_id <> (SELECT persona_id from planes_compras where id = new.producto_id)) then
			update planes_compras
				set persona_id = v_proveedor_id
				where producto_id = new.producto_id;
		end if;
	end if;

	/*-------- 3-FIFO ---------*/
        open cursor1;
	set v_pendiente = new.nmcantidad; /*Todo esta pendiente*/
        LOOP1: loop
            fetch cursor1 into v_entrada_producto_id,v_nmcantidad_disponible,v_feentrada;
            if no_more_rows then
                close cursor1;
                leave LOOP1;
            end if;
        if v_pendiente > v_nmcantidad_disponible then
		/*Queda pendientes*/
		set v_pendiente = v_pendiente - v_nmcantidad_disponible;
		update entradas_productos
			set nmcantidad_disponible = 0
			where id = v_entrada_producto_id;
        else
		UPDATE entradas_productos
			SET nmcantidad_disponible = nmcantidad_disponible - v_pendiente
			WHERE id = v_entrada_producto_id;

		CLOSE cursor1;
                LEAVE LOOP1;
        end if;
        end loop LOOP1;
    END
