BEGIN
	/*Muevo la cantidad a la disponible*/
	set new.nmcantidad_disponible = new.nmcantidad;

  DECLARE v_precio_menor DECIMAL(10,2);
  DECLARE v_persona_id INT(11);
  DECLARE v_precio_modificado BOOLEAN DEFAULT FALSE;
  DECLARE v_nmcantidad_minima INT(11);
  DECLARE v_cant_tot_disponible DECIMAL(10,2);
  DECLARE v_precio_menor_old DECIMAL(10,2);


  /*Actualizar precio de compra y proveedor*/

  -- seleccione el precio menor que tiene el articulo que se va añadir
  SET v_precio_menor_old = (SELECT precio_menor FROM productos WHERE id = new.producto_id);
  IF new.psvalor_unitario < v_precio_menor_old THEN
    -- como el precio de venta del nuevo producto es menor entonces guardelo en la variable
    -- con el nuevo valor y guarde el id del proveedor que me ofrece ese precio
    SET v_precio_menor = new.psvalor_unitario;
    SET v_persona_id = (SELECT persona_id FROM entradas WHERE id = new.entrada_id);
    SET v_precio_modificado = TRUE;
  END IF;

  /*Eliminar plan de compras del producto*/

	--  si el numero de unidades [nmcantidad_disponible] que quedo
	--  esta por encima del punto de reorden se debe eliminar de la tabla de plan de compras

  -- Selecciona la cantidad minima del producto que se va a agregar
  SET v_nmcantidad_minima = (SELECT nmcantidad_minima  FROM productos WHERE id = new.producto_id);
  -- seleccione todas las entradas del mismo producto y sume las cantidades disponibles
  -- mas la nueva cantidad que se va a agregar
  SET v_cant_tot_disponible = (SELECT SUM(nmcantidad_disponible) FROM entradas_productos WHERE producto_id = new.producto_id) + new.nmcantidad_disponible;

  IF v_cant_tot_disponible > v_nmcantidad_minima  THEN
    -- como la cantidad que se va a agregar es mayor que la que se necesita borre de la
    -- lista de compras este producto porque ya no supero el limite de reorden
    DELETE FROM planes_compras
    WHERE producto_id = new.producto_id;
  END IF;

	/*Actualizo la tabla de productos con cantidades y valores
	calculados para el costo promedio*/
	update productos
  set nmcantidad = nmcantidad + new.nmcantidad,
      nmsuma_total_productos = nmsuma_total_productos + new.nmcantidad,
      pssuma_total_valores = pssuma_total_valores +
		( new.nmcantidad * new.psvalor_unitario ),
      psventa = if(psventa < 	new.psvalor_unitario * 1.2,
		new.psvalor_unitario * 1.2,
		psventa),
      pscompra = IF(v_precio_modificado = TRUE, v_precio_menor, pscompra),
      persona_id = IF(v_precio_modificado = TRUE, v_persona_id, persona_id)
  where id = new.producto_id;

END
