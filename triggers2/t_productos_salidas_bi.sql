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

  -- Selecciona la cantidad disponible del producto que se va a hacer la venta
	SET v_nmcantidad_producto = (SELECT nmcantidad from productos where id = new.producto_id);

  -- Seleccion la cantidad minima del producto elegido
	SET v_preorden = (select preorden from productos where id = new.producto_id);


  -- TO DO : preguntar como queda la base de datos

  -- trae el id del provedor del producto que se va a hacer la venta
	SET v_proveedor_id = (select personas_id from productos where id = new.producto_id);

  -- Verifica si del producto que se va a hacer la compra todavia no llega al limite de preorden
	if v_nmcantidad_producto < v_preorden then

    -- la cantidad que se va pedir es menor que el limite de preorden, verificar si ese producto
    -- hecho algun pedido alguna vez
		SET v_insert_plan = (SELECT producto_id FROM plan_de_compra WHERE producto_id = new.producto_id);

    -- nunca se ha hecho un plan de compra de ese articulo se añade a la lista con los ids
		if v_insert_plan IS NULL then
			insert into plan_de_compra (producto_id, personas_id) values(new.producto_id, v_proveedor_id);
		elseif (v_proveedor_id <> (SELECT personas_id from plan_de_compra where id = new.producto_id)) then
    -- el id del provedor de la compra que se va a hacer es diferente del que ya habia,
    -- entonces actualize el id del proveedor
      update plan_de_compra
				set personas_id = v_proveedor_id
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
